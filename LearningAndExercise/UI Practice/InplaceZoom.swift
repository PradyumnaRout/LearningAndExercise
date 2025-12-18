//
//  InplaceZoom.swift
//  LearningAndExercise
//
//  Created by hb on 18/12/25.
//

import Foundation
import SwiftUI

//struct GalleryPagerVertical: View {
//
//    let links: [String]
//
//    @State var selection: Int
//    @State private var images: [String: UIImage] = [:]
//    @State private var zoomedImageIndex: Int? = nil
//    @State private var zoomedImageScale: CGFloat = 1.0
//    @State private var zoomedImageOffset: CGSize = .zero
//    @State private var imageFrame: CGRect = .zero
//
//    var screenWidth: CGFloat { UIScreen.main.bounds.width }
//
//    var body: some View {
//        ZStack {
//            ScrollViewReader { proxy in
//                ScrollView(.vertical, showsIndicators: true) {
//                    VStack(spacing: 0) {
//                        ForEach(0..<links.count, id: \.self) { index in
//                            let link = links[index]
//
//                            ZStack {
//                                if let img = images[link] {
//                                    Image(uiImage: img)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: screenWidth)
//                                        .contentShape(Rectangle())
//                                        .opacity(zoomedImageIndex == index ? 0 : 1)
//                                        .background(
//                                            GeometryReader { geo in
//                                                Color.clear
//                                                    .onAppear {
//                                                        if zoomedImageIndex == index {
//                                                            imageFrame = geo.frame(in: .global)
//                                                        }
//                                                    }
//                                                    .onChangeCompat(of: zoomedImageIndex) { oldVal, newVal in
//                                                        if newVal == index {
//                                                            imageFrame = geo.frame(in: .global)
//                                                        }
//                                                    }
//                                            }
//                                        )
//                                        .gesture(
//                                            MagnificationGesture()
//                                                .onChanged { value in
//                                                    if zoomedImageIndex == nil {
//                                                        zoomedImageIndex = index
//                                                    }
//                                                    zoomedImageScale = max(1.0, value)
//                                                }
//                                                .onEnded { _ in
//                                                    withAnimation(.easeInOut(duration: 0.8)) {
//                                                        zoomedImageScale = 1.0
//                                                        zoomedImageOffset = .zero
//                                                    }
//                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                                                        zoomedImageIndex = nil
//                                                    }
//                                                }
//                                        )
//                                } else {
//                                    ProgressView()
//                                        .frame(width: screenWidth, height: 200)
//                                }
//                            }
//                            .id(index)
//                            .task {
//                                if images[link] == nil {
//                                    do {
//                                        images[link] = try await loadImage(link)
//                                    } catch {
//                                        print("Error loading \(link):", error)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                .background(Color.black)
//                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        withAnimation {
//                            proxy.scrollTo(selection, anchor: .top)
//                        }
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//            if let zoomedIndex = zoomedImageIndex, let link = (zoomedIndex < links.count ? links[zoomedIndex] : nil), let img = images[link] {
//                ZStack {
//                    Color.black.opacity(0.4 * min(Double(zoomedImageScale - 1) / 1.5, 1.0))
//                        .ignoresSafeArea()
//                        .onTapGesture {
//                            withAnimation(.easeInOut(duration: 0.8)) {
//                                zoomedImageScale = 1.0
//                                zoomedImageOffset = .zero
//                            }
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                                zoomedImageIndex = nil
//                            }
//                        }
//
//                    // Position zoomed image at original frame location
//                    VStack(spacing: 0) {
//                        Spacer()
//                            .frame(height: max(0, imageFrame.minY))
//                        
//                        Image(uiImage: img)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: screenWidth)
//                            .scaleEffect(zoomedImageScale, anchor: imagePositionAnchor())
//                            .offset(zoomedImageOffset)
//                            .gesture(
//                                SimultaneousGesture(
//                                    MagnificationGesture()
//                                        .onChanged { value in
//                                            zoomedImageScale = max(1.0, value)
//                                        }
//                                        .onEnded { _ in
//                                            withAnimation(.easeInOut(duration: 0.8)) {
//                                                zoomedImageScale = 1.0
//                                                zoomedImageOffset = .zero
//                                            }
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//                                                zoomedImageIndex = nil
//                                            }
//                                        },
//                                    DragGesture()
//                                        .onChanged { value in
//                                            if zoomedImageScale > 1.0 {
//                                                zoomedImageOffset = value.translation
//                                            }
//                                        }
//                                        .onEnded { _ in
//                                            withAnimation(.easeInOut(duration: 0.8)) {
//                                                zoomedImageOffset = .zero
//                                            }
//                                        }
//                                )
//                            )
//                        
//                        Spacer()
//                    }
//                }
//                .ignoresSafeArea()
//            }
//        }
//    }
//
//    private func loadImage(_ urlString: String) async throws -> UIImage {
//        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
//        let (data, _) = try await URLSession.shared.data(from: url)
//        guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeRawData) }
//        return image
//    }
//    
//    private func imagePositionAnchor() -> UnitPoint {
//            let screenHeight = UIScreen.main.bounds.height
//            let imageMidY = imageFrame.midY
//            let screenMidY = screenHeight / 2
//            let tolerance: CGFloat = 35 // 20-30 pixel tolerance
//            
//            // If image is near the middle (within tolerance), use .center anchor
//            if abs(imageMidY - screenMidY) <= tolerance {
//                return .center
//            }
//            // If image is more towards top, use .top anchor; otherwise use .bottom
//            else if imageMidY < screenMidY {
//                return .top
//            } else {
//                return .bottom
//            }
//        }
//}
