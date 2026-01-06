//
//  ImageLoader.swift
//  LearningAndExercise
//
//  Created by hb on 06/01/26.
//

import Foundation
import SwiftUI

//https://medium.com/@chandra.welim/image-loading-in-ios-handle-1000-images-without-crashing-a3caef169cd7

// MARK: Async loading of image:
// SwiftUI's AsyncImage handles async loading by default:

// Async Loading
// Benifits:
/**
 ➡️  Async Loading
 ➡️ Built-in error handling
 ➡️ Simple to use
 ➡️ No main thread blocking.
 */
struct AsyncImageView: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(0.6))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure(let error):
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(0.6))
            @unknown default:
                EmptyView()
            }
        }

    }
}


// MARK: Basic Caching with NSCache
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
        // Configure cache limits
        // Limit number of images
        cache.countLimit = 50
        
        // Limit total memory (in bytes)
        cache.totalCostLimit = 100 * 1024 * 1024     // 50
        
        // Clear cache on memory warning
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(handleMemoryWarning),
                name: UIApplication.didReceiveMemoryWarningNotification,
                object: nil
            )
    }
    
    @objc private func handleMemoryWarning() {
        cache.removeAllObjects()
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as NSString)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let cost = caluclateCost(image)     // Rough memeory cost
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: Int(cost))
    }
    
    func caluclateCost(_ image: UIImage) -> Int {
        // Rough estimate: width * height * 4 bytes (RGBA)
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        return Int(width * height * 4)
    }
}

// MARK: Image load using Cahce:
struct CachedImageView: View {
    let url: URL
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        // We can use Group as type erasure instead of any view.
        // SwiftUI limits containers like VStack to 10 direct children. So to avoid that we can add elements in group.
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.gray)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    @MainActor
    private func loadImage() async {
        // Check cache first
        if let cached = ImageCache.shared.image(for: url) {
            image = cached
            return
        }
        
        // Load from Network
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                // Cache the image
                ImageCache.shared.setImage(uiImage, for: url)
                image = uiImage
            }
        } catch {
            // Handle Error
            image = nil
        }
        // Hold the loader.
        isLoading = false
    }
}


// MARK: List Loading
// Beifits of lazy loading
/**
 ➡️ Only loads visible images
 ➡️ Reduces memory usage
 ➡️ Better performance
 ➡️ Prevents crashes.
 */
struct ImageListView: View {
    let urls: [URL]
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(Array(urls.enumerated()), id: \.element.absoluteString) { index, url in
                        CachedImageView(url: url)
                            .frame(height: 200)
                            .onAppear {
                                // Preload next few images
                                preloadNearbyImages(from: index)
                            }
                    }
                }
            }
        }
    }
    
    private func preloadNearbyImages(from index: Int) {
        let startIndex = index + 1
        let endIndex = min(index + 5, urls.count)
        let urlsToPreload = Array(urls[startIndex..<endIndex])
        ImagePreloader.shared.preload(urls: urlsToPreload)
    }
}



// MARK: Custom Image Loader:
// For more control, Create a custom image loader:

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var task: Task<Void, Never>?
    private let cache = ImageCache.shared
    
    func load(from url: URL) {
        isLoading = true
        error = nil
        task?.cancel()
        
        // Check cache first
        if let cache = cache.image(for: url) {
            image = cache
            isLoading = false
            return
        }
        
        task = Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard !Task.isCancelled else { return }
                
                if let uiImage = UIImage(data: data) {
                    // cache the image
                    cache.setImage(uiImage, for: url)
                    
                    await MainActor.run {
                        self.image = uiImage
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
}


struct LoadedImageView: View {
    let url: URL
    @StateObject private var loader = ImageLoader()
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if loader.isLoading {
                ProgressView()
            } else if let error = loader.error {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            loader.load(from: url)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}


// MARK: Image Preloading
class ImagePreloader {
    static let shared = ImagePreloader()
    private let cache = ImageCache.shared
    
    func preload(urls: [URL]) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for url in urls {
                    group.addTask {
                        await self.preloadImage(from: url)
                    }
                }
            }
        }
    }
    
    private func preloadImage(from url: URL) async {
        // Skip if already cached
        if cache.image(for: url) != nil {
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                cache.setImage(uiImage, for: url)
            }
        } catch {
            // Silently fail for preloading
        }
    }
}


// MARK: Disk Caching
// Memory cache is fast but limited. Disk cache persists across app lunches.

class DiskImageCache {
    static let shared = DiskImageCache()
    private let cacheDirectory: URL
    
    init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func image(for url: URL) -> UIImage? {
        let fileName = url.absoluteString // Use hash as filename
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let fileName = url.absoluteString
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        try? data.write(to: fileURL)
    }
    
    func clearCache() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

//MARK: Two-Level Caching
// Combine memory and disk cache:


class TwoLevelImageCache {
    static let shared = TwoLevelImageCache()
    private let memoryCache = ImageCache.shared
    private let diskCache = DiskImageCache.shared
    
    func image(for url: URL) -> UIImage? {
        // Check memory cache first
        if let cached = memoryCache.image(for: url) {
            return cached
        }
        
        // Check disk cache
        if let diskCached = diskCache.image(for: url) {
            // Load into memory cache
            memoryCache.setImage(diskCached, for: url)
            return diskCached
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        // Store in both caches
        memoryCache.setImage(image, for: url)
        diskCache.setImage(image, for: url)
    }
}


// 1000 Image view
struct ImageSource {
    static let urls: [URL] = (1...100).compactMap {
        URL(string: "https://picsum.photos/id/\($0)/800/1200")
    }
}


import SwiftUI

// MARK: Final Setup

struct ImageGridView: View {
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ImageSource.urls, id: \.self) { url in
                    CachedAsyncImage(
                        url: url,
                        size: CGSize(width: 100, height: 100)
                    )
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}


struct CachedAsyncImage: View {
    let url: URL
    let size: CGSize

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var task: Task<Void, Never>?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.gray)
            }
        }
        .task(id: url) {
            await load()
        }
        .onDisappear {
            task?.cancel()
        }
    }

    @MainActor
    private func load() async {
        if image != nil { return }

        isLoading = true

        task = Task {
            guard !Task.isCancelled else { return }

            let result = await CacheImageLoader.shared.loadImage(
                from: url,
                targetSize: size,
                scale: UIScreen.main.scale
            )

            self.image = result
            self.isLoading = false
        }
    }
}




struct MasonryGridView: View {
    let urls = ImageSource.urls

    private let spacing: CGFloat = 12
    private let screenWidth = UIScreen.main.bounds.width

    private var columnWidth: CGFloat {
        (screenWidth - spacing * 3) / 2
    }

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: spacing) {

                // Left Column
                LazyVStack(spacing: spacing) {
                    ForEach(leftColumnURLs, id: \.self) { url in
                        CachedAsyncImageDynamicHeight(
                            url: url,
                            fixedWidth: columnWidth
                        )
                        .cornerRadius(8)
                    }
                }

                // Right Column
                LazyVStack(spacing: spacing) {
                    ForEach(rightColumnURLs, id: \.self) { url in
                        CachedAsyncImageDynamicHeight(
                            url: url,
                            fixedWidth: columnWidth
                        )
                        .cornerRadius(8)
                    }
                }
            }
            .padding(spacing)
        }
    }

    private var leftColumnURLs: [URL] {
        urls.enumerated()
            .filter { $0.offset.isMultiple(of: 2) }
            .map(\.element)
    }

    private var rightColumnURLs: [URL] {
        urls.enumerated()
            .filter { !$0.offset.isMultiple(of: 2) }
            .map(\.element)
    }
}

// MARK: Full screen image viewer:
struct FullscreenImageView: View {
    let url: URL

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image {
                ZoomableImageView(image: image)
            } else {
                ProgressView()
                    .tint(.white)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .task {
            await loadOriginalImage()
        }
    }

    private func loadOriginalImage() async {
        // Load ORIGINAL image (no downsampling)
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            image = UIImage(data: data)
        } catch {
            image = nil
        }
    }
}

struct ZoomableImageView: View {
    let image: UIImage

    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { scale = max(1, $0) },
                    DragGesture()
                        .onChanged { offset = $0.translation }
                        .onEnded { _ in
                            if scale == 1 {
                                offset = .zero
                            }
                        }
                )
            )
    }
}




struct CachedAsyncImageDynamicHeight: View {
    let url: URL
    let fixedWidth: CGFloat     // Dynamic height
    @State private var height: CGFloat?
    let maxDecodeHeight = UIScreen.main.bounds.height * 0.8

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var task: Task<Void, Never>?
    @State private var showFullscreen = false
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: fixedWidth, height: height)       // Only dynamic height, remove height in case of original image height.
                    .onTapGesture {
                        showFullscreen = true
                    }
            } else if isLoading {
                ProgressView()
                    .frame(width: fixedWidth, height: fixedWidth)
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.gray)
                    .frame(width: fixedWidth, height: fixedWidth)
            }
        }
        .task(id: url) {
            await load()
        }
        .onDisappear {
            task?.cancel()
        }
        .sheet(isPresented: $showFullscreen) {
            FullscreenImageView(url: url)
        }
    }
    
    @MainActor
    private func load() async {
        if image != nil { return }
        
        isLoading = true
        
        task = Task {
            guard !Task.isCancelled else { return }

            let result = await CacheImageLoader.shared.loadImage(
                from: url,
                targetSize: CGSize(width: fixedWidth, height: maxDecodeHeight) /*size*/,
                scale: UIScreen.main.scale
            )
            
//            self.image = result
            self.isLoading = false
            
            // Dynamic height:  Comment in case you need original image height.
            guard let result, !Task.isCancelled else { return }
            let aspectRatio = result.size.height / result.size.width
            self.height = fixedWidth * aspectRatio
            self.image = result
        }
    }
}












//MARK:  Caching and Downloading:
import UIKit
import ImageIO

actor CacheImageLoader {
    static let shared = CacheImageLoader()
    
    private var ongoingTasks: [URL: Task<UIImage?, Never>] = [:]
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 4
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
    
    func loadImage(
        from url: URL,
        targetSize: CGSize,
        scale: CGFloat
    ) async -> UIImage? {
        
        // Memory cache
        if let cached = ImageCache.shared.image(for: url) {
            return cached
        }
        
        // Disk cache
        if let diskImage = DiskCache.shared.image(for: url) {
            ImageCache.shared.setImage(diskImage, for: url)
            return diskImage
        }
        
        // Deduplicate requests
        if let task = ongoingTasks[url] {
            return await task.value
        }
        
        let task = Task<UIImage?, Never> {
            defer { ongoingTasks[url] = nil }
            
            do {
                let (data, _) = try await session.data(from: url)
                
                guard !Task.isCancelled else { return nil }
                
                // without autoreleasepool, it will be critical for tall images
                let image = autoreleasepool {
                    downsample(
                        data: data,
                        to: targetSize,
                        scale: scale
                    )
                }
                
                guard let image else { return nil }
                
                ImageCache.shared.setImage(image, for: url)
                DiskCache.shared.save(image, for: url)
                
                return image
            } catch {
                return nil
            }
        }
        
        ongoingTasks[url] = task
        return await task.value
    }
    
    func downsample(
        data: Data,
        to pointSize: CGSize,
        scale: CGFloat
    ) -> UIImage? {
        
        // Use MAX dimension instead of MIN for better tall image handling
        let maxDimension = max(pointSize.width, pointSize.height) * scale
        
        let sourceOptions = [
            kCGImageSourceShouldCache: false
        ] as CFDictionary
        
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return nil
        }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(
            source,
            0,
            downsampleOptions
        ) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}


final class DiskCache {
    static let shared = DiskCache()

    private let directory: URL

    private init() {
        directory = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache")

        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    func image(for url: URL) -> UIImage? {
        let fileURL = directory.appendingPathComponent(url.cacheKey)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    func save(_ image: UIImage, for url: URL) {
        // With adaptive compression:
        let compression: CGFloat = image.size.height > image.size.width * 1.5 ? 0.6 : 0.8
        let fileURL = directory.appendingPathComponent(url.cacheKey)
        guard let data = image.jpegData(compressionQuality: compression) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
    
    func clearCache() {
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}

private extension URL {
    var cacheKey: String {
        absoluteString
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        ?? UUID().uuidString
    }
}
