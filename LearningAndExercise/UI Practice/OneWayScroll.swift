//
//  OneWayScroll.swift
//  LearningAndExercise
//
//  Created by hb on 05/12/25.
//

import Foundation
import UIKit
import SwiftUI

struct OneWayScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var scrollOffset: CGFloat
    var allowsUpwardScroll: Bool = false
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.allowsUpwardScroll = allowsUpwardScroll
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scrollOffset: $scrollOffset, allowsUpwardScroll: allowsUpwardScroll)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding var scrollOffset: CGFloat
        var allowsUpwardScroll: Bool
        var lastContentOffset: CGFloat = 0
        
        init(scrollOffset: Binding<CGFloat>, allowsUpwardScroll: Bool) {
            self._scrollOffset = scrollOffset
            self.allowsUpwardScroll = allowsUpwardScroll
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let currentOffset = scrollView.contentOffset.y
            
            // If not allowing upward scroll and user tries to scroll up
            if !allowsUpwardScroll && currentOffset < lastContentOffset {
                // Prevent upward scrolling by reverting to last offset
                scrollView.setContentOffset(CGPoint(x: 0, y: lastContentOffset), animated: false)
                return
            }
            
            lastContentOffset = currentOffset
            DispatchQueue.main.async {
                self.scrollOffset = currentOffset
            }
        }
    }
}
