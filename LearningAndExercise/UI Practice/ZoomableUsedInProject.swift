//
//  ZoomableUsedInProject.swift
//  LearningAndExercise
//
//  Created by hb on 18/12/25.
//

import Foundation

/**
 
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


 struct GalleryPager: View {
     
     let links: [String]
     
     @State var selection: Int
     
     @State private var images: [String: UIImage] = [:]
     @State private var offset: CGFloat = 0
     @State private var currentPage: Int = 0
     @State private var lastOffset: CGFloat = 0
     @State private var scrollTimer: Timer?
     @State private var targetPage: Int = 0
     @State private var shouldSnap: Bool = false
     @State private var offsetCheckCount: Int = 0
     @State private var lastScrollVelocity: CGFloat = 0
     @State private var anyZoomed: Bool = false
     @State private var scrollEnabled: Bool = true
     
     var screenWidth: CGFloat { UIScreen.main.bounds.width }
     let velocityThreshold: CGFloat = 100
     
     var body: some View {
         ZStack {
             ScrollViewReader { proxy in
                 if #available(iOS 17.0, *) {
                     // iOS 17+ with native paging
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack(spacing: 0) {
                             ForEach(0..<links.count, id: \.self) { index in
                                 let link = links[index]
                                 ZStack {
                                     if let img = images[link] {
                                         ZoomableImage(
                                             image: Image(uiImage: img),
                                             intrinsicSize: img.size,
                                             isZoomed: $anyZoomed,
                                             scrollEnabled: $scrollEnabled
                                         )
                                         .frame(width: screenWidth)
                                     } else {
                                         ProgressView()
                                             .frame(width: screenWidth, height: 200)
                                     }
                                 }
                                 .id(index)
                                 .task {
                                     if images[link] == nil {
                                         do {
                                             images[link] = try await loadImage(link)
                                         } catch {
                                             print("Error loading \(link):", error)
                                         }
                                     }
                                 }
                             }
                         }
                         .overlay(
                             GeometryReader { geo in
                                 Color.clear
                                     .preference(
                                         key: HorizontalScrollOffsetPreferenceKey.self,
                                         value: -geo.frame(in: .named("H_scroll")).minX
                                     )
                             }
                         )
                     }
                     .coordinateSpace(name: "H_scroll")
                     .scrollTargetBehavior(.paging)
                     .onPreferenceChange(HorizontalScrollOffsetPreferenceKey.self) { value in
                         currentPage = Int(round(value / screenWidth))
                     }
                     .onAppear {
                         proxy.scrollTo(selection, anchor: .leading)
                         currentPage = selection
                     }
                     .scrollDisabled(anyZoomed)
                 } else {
                     // iOS 16 with manual snap logic
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack(spacing: 0) {
                             ForEach(0..<links.count, id: \.self) { index in
                                 let link = links[index]
                                 ZStack {
                                     if let img = images[link] {
                                         ZoomableImage(
                                             image: Image(uiImage: img),
                                             intrinsicSize: img.size,
                                             isZoomed: $anyZoomed,
                                             scrollEnabled: $scrollEnabled
                                         )
                                         .frame(width: screenWidth)
                                     } else {
                                         ProgressView()
                                             .frame(width: screenWidth, height: 200)
                                     }
                                 }
                                 .id(index)
                                 .task {
                                     if images[link] == nil {
                                         do {
                                             images[link] = try await loadImage(link)
                                         } catch {
                                             print("Error loading \(link):", error)
                                         }
                                     }
                                 }
                             }
                         }
                         .overlay(
                             GeometryReader { geo in
                                 Color.clear
                                     .preference(
                                         key: HorizontalScrollOffsetPreferenceKey.self,
                                         value: -geo.frame(in: .named("H_scroll")).minX
                                     )
                             }
                         )
                     }
                     .coordinateSpace(name: "H_scroll")
                     .onPreferenceChange(HorizontalScrollOffsetPreferenceKey.self) { value in
                         guard scrollEnabled else { return }
                         
                         offset = value
                         
                         let velocity = abs(value - lastOffset)
                         lastScrollVelocity = velocity
                         
                         scrollTimer?.invalidate()
                         scrollTimer = nil
                         offsetCheckCount = 0
                         
                         scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                             let currentVelocity = abs(value - lastOffset)
                             
                             if currentVelocity < velocityThreshold && abs(value - lastOffset) < 5 {
                                 offsetCheckCount += 1
                                 if offsetCheckCount >= 2 {
                                     let closestPage = Int(round(value / screenWidth))
                                     targetPage = max(0, min(closestPage, links.count - 1))
                                     shouldSnap = true
                                     scrollTimer?.invalidate()
                                     scrollTimer = nil
                                 }
                             } else {
                                 offsetCheckCount = 0
                             }
                             lastOffset = value
                         }
                         
                         lastOffset = value
                         currentPage = Int(round(value / screenWidth))
                         
                         print("Offset: \(value), Velocity: \(velocity), Page: \(currentPage)")
                     }
                     .onChange(of: shouldSnap) { newValue in
                         if newValue {
                             withAnimation(.easeInOut(duration: 0.3)) {
                                 proxy.scrollTo(targetPage, anchor: .leading)
                             }
                             shouldSnap = false
                         }
                     }
                     .scrollDisabled(anyZoomed)
                     .onAppear {
                         proxy.scrollTo(selection, anchor: .leading)
                     }
                     .onDisappear {
                         scrollTimer?.invalidate()
                     }
                 }
             }
             .scrollIndicators(.hidden)
             
             VStack {
                 Spacer()
                 VStack(spacing: 12) {
                     Text("\(currentPage + 1) of \(links.count)")
                         .font(.caption)
                         .foregroundColor(.black)
                 }
                 .padding(.horizontal, 20)
                 .padding(.vertical, 12)
                 .background(.thinMaterial)
                 .cornerRadius(8)
                 .padding()
             }
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
     }
     
     private func loadImage(_ urlString: String) async throws -> UIImage {
         guard let url = URL(string: urlString) else { throw URLError(.badURL) }
         let (data, _) = try await URLSession.shared.data(from: url)
         guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeRawData) }
         return image
     }
 }

 // MARK: - ZoomableImage
 struct ZoomableImage: View {
     let image: Image
     let intrinsicSize: CGSize
     let minScale: CGFloat = 1.0
     let maxScale: CGFloat = 6.0

     @Binding var isZoomed: Bool
     @Binding var scrollEnabled: Bool

     @State private var scale: CGFloat = 1.0
     @State private var lastScale: CGFloat = 1.0
     @State private var offset: CGSize = .zero
     @State private var lastOffset: CGSize = .zero

     var body: some View {
         GeometryReader { geo in
             let container = geo.size
             let fittedSize = aspectFitSize(for: intrinsicSize, in: container)
             let scaledWidth = fittedSize.width * scale
             let scaledHeight = fittedSize.height * scale

             ZStack {
                 Rectangle()
                     .fill(.ultraThinMaterial)
                     .edgesIgnoringSafeArea(.all)

                 image
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: scaledWidth, height: scaledHeight)
                     .position(x: container.width / 2, y: container.height / 2)
                     .offset(offset)
                     .gesture(magnificationGesture(fittedSize: fittedSize, container: container))
                     .simultaneousGesture(dragGesture(fittedSize: fittedSize, container: container), isEnabled: isZoomed)
                     .onChange(of: scale) { new in
                         withAnimation(.interactiveSpring) {
                             isZoomed = new > (minScale + 0.2)
                             scrollEnabled = !isZoomed
                         }
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
                             scrollEnabled = !isZoomed
                         }
                     }
                     .contentShape(Rectangle())
                     .animation(.interactiveSpring(), value: scale)
                     .animation(.interactiveSpring(), value: offset)
             }
             .frame(width: container.width, height: container.height)
         }
     }

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

     private func dragGesture(fittedSize: CGSize, container: CGSize) -> some Gesture {
         DragGesture()
             .onChanged { value in
                 if scale > minScale + 0.001 {
                     let proposed = CGSize(width: lastOffset.width + value.translation.width,
                                           height: lastOffset.height + value.translation.height)
                     offset = clampedOffset(for: proposed, scale: scale, fittedSize: fittedSize, container: container)
                 }
             }
             .onEnded { value in
                 if scale > minScale + 0.001 {
                     lastOffset = offset
                 }
             }
     }

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
 }    
 */
