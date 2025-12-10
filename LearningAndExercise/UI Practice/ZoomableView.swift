//
//  ZoomableView.swift
//  LearningAndExercise
//
//  Created by hb on 04/12/25.
//
import SwiftUI
import UIKit

final class UIImageLoader: ObservableObject {
    @Published var uiImage: UIImage? = nil

    private var task: URLSessionDataTask?
    private var currentURL: URL?

    private let placeholderName: String
    private var placeholderImage: UIImage? {
        UIImage(named: placeholderName)
    }

    // Store which keys were used so we can clean them later
    private var loadedKeys: [NSString] = []

    // MARK: - Shared Cache
    private static let cache: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.totalCostLimit = 50 * 1024 * 1024
        return c
    }()

    init(placeholder: String) {
        self.placeholderName = placeholder

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        cancel()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Load Image

    func load(from url: URL) {
        let key = url.absoluteString as NSString

        // Keep track of what this loader used
        if !loadedKeys.contains(key) {
            loadedKeys.append(key)
        }

        // return cached instantly
        if let cached = UIImageLoader.cache.object(forKey: key) {
            self.uiImage = cached
            return
        }

        currentURL = url
        task?.cancel()
        uiImage = nil

        let req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)

        task = URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            guard let self = self else { return }
            defer { DispatchQueue.main.async { self.task = nil } }

            guard let data = data, let img = UIImage(data: data) else {
                DispatchQueue.main.async { self.uiImage = self.placeholderImage }
                return
            }

            // cache
            let cost = Int(img.size.width * img.size.height * img.scale * img.scale * 4)
            UIImageLoader.cache.setObject(img, forKey: key, cost: cost)

            DispatchQueue.main.async {
                if self.currentURL == url {
                    self.uiImage = img
                }
            }
        }
        task?.resume()
    }

    // MARK: - Cancel + Remove Cache

    func cancel() {
        task?.cancel()
        task = nil
        currentURL = nil
    }

    /// Call this when the view disappears
    func clearCacheForThisLoader() {
        for key in loadedKeys {
            UIImageLoader.cache.removeObject(forKey: key)
        }
        loadedKeys.removeAll()
    }

    @objc private func handleMemoryWarning() {
        UIImageLoader.cache.removeAllObjects()
    }
}


// MARK: - ZoomableImage (frame grows with zoom)
struct ZoomableImage: View {
    let image: Image
    let intrinsicSize: CGSize
    let minScale: CGFloat = 1.0
    let maxScale: CGFloat = 6.0

    @Binding var isZoomed: Bool
    var onPageSwipe: ((Int) -> Void)?

    // transform state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let container = geo.size

            // compute the "fitted" size of the image inside the container (aspect-fit) using intrinsicSize
            let fittedSize = aspectFitSize(for: intrinsicSize, in: container)

            // displayed size after scaling
            let scaledWidth = fittedSize.width * scale
            let scaledHeight = fittedSize.height * scale

            ZStack {
                // background material
                RoundedRectangle(cornerRadius: 0)
                    .foregroundStyle(Material.ultraThinMaterial)
                    .ignoresSafeArea()

                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: scaledWidth, height: scaledHeight)
                    .position(x: container.width / 2, y: container.height / 2)
                    .offset(offset)
                    .gesture(magnificationGesture(fittedSize: fittedSize, container: container))
                    .highPriorityGesture(dragGesture(fittedSize: fittedSize, container: container))
                    .onChange(of: scale) { new in
                        isZoomed = new > (minScale + 0.001)
                    }
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            if scale > minScale + 0.01 {
                                scale = minScale
                                lastScale = scale
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.5
                                lastScale = scale
                                offset = .zero
                                lastOffset = .zero
                            }
                            isZoomed = scale > (minScale + 0.001)
                        }
                    }
                    .animation(.interactiveSpring(), value: scale)
            }
            .frame(width: container.width, height: container.height)
        }
    }

    // MARK: Magnification
    private func magnificationGesture(fittedSize: CGSize, container: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                let clamped = min(max(newScale, minScale), maxScale)
                scale = clamped
                offset = clampedOffset(for: offset, scale: scale, fittedSize: fittedSize, container: container)
            }
            .onEnded { _ in
                lastScale = scale
                offset = clampedOffset(for: offset, scale: scale, fittedSize: fittedSize, container: container)
                lastOffset = offset
            }
    }

    // MARK: Drag (panning when zoomed, page swipe when at 1.0)
    private func dragGesture(fittedSize: CGSize, container: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > minScale + 0.001 {
                    // zoomed: pan the image
                    let proposed = CGSize(width: lastOffset.width + value.translation.width,
                                          height: lastOffset.height + value.translation.height)
                    offset = clampedOffset(for: proposed, scale: scale, fittedSize: fittedSize, container: container)
                }
            }
            .onEnded { value in
                if scale > minScale + 0.001 {
                    // zoomed: finalize pan
                    lastOffset = offset
                } else {
                    // at 1.0: detect swipe for page change (no animation, let TabView handle it)
                    let swipeThreshold: CGFloat = 30
                    let translation = value.translation.width
                    
                    if translation > swipeThreshold {
                        onPageSwipe?(-1)
                    } else if translation < -swipeThreshold {
                        onPageSwipe?(1)
                    }
                }
            }
    }

    // MARK: clamp offset based on scaled image size
    private func clampedOffset(for proposed: CGSize, scale: CGFloat, fittedSize: CGSize, container: CGSize) -> CGSize {
        let dispW = fittedSize.width * scale
        let dispH = fittedSize.height * scale

        let maxOffsetX = max((dispW - container.width) / 2, 0)
        let maxOffsetY = max((dispH - container.height) / 2, 0)

        let clampedX = min(max(proposed.width, -maxOffsetX), maxOffsetX)
        let clampedY = min(max(proposed.height, -maxOffsetY), maxOffsetY)

        return CGSize(width: clampedX, height: clampedY)
    }

    private func aspectFitSize(for source: CGSize, in container: CGSize) -> CGSize {
        guard source.width > 0 && source.height > 0 && container.width > 0 && container.height > 0 else {
            return container
        }

        let imgRatio = source.width / source.height
        let boxRatio = container.width / container.height

        if imgRatio > boxRatio {
            let width = container.width
            let height = width / imgRatio
            return CGSize(width: width, height: height)
        } else {
            let height = container.height
            let width = height * imgRatio
            return CGSize(width: width, height: height)
        }
    }

    func reset() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }
}

// MARK: Fullscreen page using ZoomableImage
struct FullscreenImagePage: View {
    let url: URL
    @Binding var isZoomed: Bool
    var onPageSwipe: ((Int) -> Void)?

    @StateObject private var loader = UIImageLoader(placeholder: "FemalePlaceholder")

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundStyle(Material.ultraThinMaterial)
                .ignoresSafeArea()
            
            Group {
                if let ui = loader.uiImage {
                    GeometryReader { geo in
                        ZoomableImage(
                            image: Image(uiImage: ui),
                            intrinsicSize: ui.size,
                            isZoomed: $isZoomed,
                            onPageSwipe: onPageSwipe
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                        .id(url) // Force view recreation on URL change
                    }
                } else {
                    ProgressView()
                }
            }
            .onAppear { loader.load(from: url) }
            .onDisappear {
                loader.cancel()
                loader.clearCacheForThisLoader()
            }
            .onChange(of: url) { newUrl in
                loader.load(from: newUrl)
            }
        }
    }
}


struct HorizontalImagePager: View {
    let photoUrls: [String]
    @State private var selection: Int = 0
    @State private var anyZoomed: Bool = false

    // Drag state
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    var body: some View {
        GeometryReader { geo in
            let pageWidth = geo.size.width

            HStack(spacing: 0) {
                ForEach(Array(photoUrls.enumerated()), id: \.offset) { idx, s in
                    Group {
                        if let url = URL(string: s) {
                            FullscreenImagePage(
                                url: url,
                                isZoomed: Binding(
                                    get: { anyZoomed },
                                    set: { new in anyZoomed = new }
                                ),
                                onPageSwipe: { direction in
                                    // keep the same behavior you had — but use programmatic change
                                    let newSelection = selection + direction
                                    if newSelection >= 0 && newSelection < photoUrls.count {
                                        // animate programmatic change (this will trigger the offset animation below)
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selection = newSelection
                                        }
                                    }
                                }
                            )
                        } else {
                            Color.gray
                        }
                    }
                    .frame(width: pageWidth, height: UIScreen.main.bounds.height)
                    .clipped()
                    .ignoresSafeArea()
                }
            }
            .offset(x: -CGFloat(selection) * pageWidth + dragOffset)
            // animate when `selection` changes programmatically
            .animation(.easeInOut(duration: 0.3), value: selection)
            .gesture(
                // only allow dragging when not zoomed
                DragGesture()
                    .onChanged { value in
                        guard !anyZoomed else { return }
                        isDragging = true
                        // track translation but clamp a bit so it feels natural
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        guard !anyZoomed else {
                            // reset drag state
                            dragOffset = 0
                            isDragging = false
                            return
                        }

                        let threshold = pageWidth * 0.2 // swipe threshold
                        let translation = value.translation.width
                        var newSelection = selection

                        if translation < -threshold {
                            newSelection = min(selection + 1, photoUrls.count - 1)
                        } else if translation > threshold {
                            newSelection = max(selection - 1, 0)
                        }

                        // animate to the chosen page
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selection = newSelection
                            dragOffset = 0
                        }

                        isDragging = false
                    }
            )
        }
    }
}

// Preview
struct HorizontalImagePager_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalImagePager(photoUrls: [
            "https://picsum.photos/id/237/900/600",
            "https://picsum.photos/id/238/900/700",
            "https://picsum.photos/id/239/900/1200"
        ])
    }
}
