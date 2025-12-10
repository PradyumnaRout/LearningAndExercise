//
//  ScrollPaging.swift
//  LearningAndExercise
//
//  Created by hb on 03/12/25.
//

import SwiftUI

struct PagingiOS17: View {
    
    let colors: [Color] = [.red, .blue, .green, .purple, .orange]
    @State var currentIndex: Int = 0
    
    private var pageHeight: CGFloat {
        // Use a safe estimate or calculate it based on the container size
        UIScreen.main.bounds.height - 60
    }
    
    private let bottomPadding: CGFloat = 60
    
    var body: some View {
        VStack {
            Text("Paging")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                ForEach(colors.indices, id: \.self) { index in
                                    ColorView(color: colors[index])
                                        .containerRelativeFrame(.vertical)
                                        .overlay {
                                            Text("Page \(index + 1)")
                                                .font(.largeTitle)
                                                .foregroundColor(.white)
                                        }
                                }
                            }
                        }
                        .padding(.bottom, 60)
                        .scrollTargetBehavior(.paging)
                        .scrollTargetLayout()
        }
    }
}


// PreferenceKey to carry the vertical offset
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct BelowiOS17: View {
    
    let colors: [Color] = [.red, .blue, .green, .purple, .orange]
    @State var currentIndex: Int = 0
    
    private var pageHeight: CGFloat {
        // Use a safe estimate or calculate it based on the container size
        UIScreen.main.bounds.height - 60
    }
    
    private let bottomPadding: CGFloat = 60
    
    var body: some View {
        VStack {
            Text("Paging")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            GeometryReader { geo in
                let availableHeight = geo.size.height
                let safeBottom = geo.safeAreaInsets.bottom
                let pageHeight = availableHeight - bottomPadding - safeBottom
                
                PagingScrollViewPages(
                    colors.indices.map { index in
                        AnyView(ColorView(color: colors[index]))
                    },
                    currentIndex: $currentIndex
                )
                // Use the computed height so cells/pages match the visible area
                .frame(height: pageHeight)
                // Position the paging view at the top of the GeometryReader area
                .clipped()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 35)
        }
        .ignoresSafeArea(.all, edges: .bottom)

    }
}
        


#Preview("iOS17Above") {
    PagingiOS17()
}

#Preview("iOS16") {
    BelowiOS17()
}


struct ColorView: View {
    let color: Color
    var body: some View {
        color
    }
}


import SwiftUI
import UIKit

public struct PagingScrollViewPages: UIViewRepresentable {
    public var pages: [AnyView]
    @Binding public var currentIndex: Int

    public init(_ pages: [AnyView], currentIndex: Binding<Int> = .constant(0)) {
        self.pages = pages
        self._currentIndex = currentIndex
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(pages: pages, currentIndex: $currentIndex)
    }

    public func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.isPagingEnabled = true
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(HostingCell.self, forCellReuseIdentifier: HostingCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        return tableView
    }

    public func updateUIView(_ uiView: UITableView, context: Context) {
        context.coordinator.pages = pages
        DispatchQueue.main.async {
            uiView.reloadData()

            let index = max(0, min(currentIndex, pages.count - 1))
            if index < pages.count {
                uiView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
            }
        }
    }

    // MARK: - Coordinator
    public class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var pages: [AnyView]
        @Binding var currentIndex: Int

        init(pages: [AnyView], currentIndex: Binding<Int>) {
            self.pages = pages
            self._currentIndex = currentIndex
            super.init()
        }

        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            pages.count
        }

        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: HostingCell.reuseIdentifier,
                for: indexPath
            ) as! HostingCell
            cell.host(rootView: pages[indexPath.row])
            return cell
        }

        public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            tableView.bounds.height
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            updateIndex(scrollView)
        }

        public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            updateIndex(scrollView)
        }

        private func updateIndex(_ scrollView: UIScrollView) {
            let height = max(scrollView.bounds.height, 1)
            let page = Int(round(scrollView.contentOffset.y / height))
            currentIndex = min(max(page, 0), pages.count - 1)
        }
    }
}

// MARK: - HostingCell
fileprivate final class HostingCell: UITableViewCell {
    static let reuseIdentifier = "HostingCell"
    private var hostingController: UIHostingController<AnyView>?

    func host(rootView: AnyView) {
        if let hostingController = hostingController {
            hostingController.rootView = rootView
        } else {
            let controller = UIHostingController(rootView: rootView)
            controller.view.backgroundColor = .clear
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(controller.view)

            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])

            hostingController = controller
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hostingController?.view.frame = contentView.bounds
    }
}





/**
 HStack(alignment: .top) {
     WebImage(url: url) { image in
         image
             .resizable()
             .scaledToFill()
             .frame(width: width, height: height)
             .contentShape(Rectangle())   // makes ONLY the visible area tappable
             .clipped()
     } placeholder: {
         Image(placeholderName)
             .resizable()
             .scaledToFill()
     }
 }
 */


/**
 ✅ What scrollTargetLayout() Does

 It marks a view (usually each item in a scroll view) as a scroll target so SwiftUI knows exactly where it can snap or scroll to.

 Think of it as telling SwiftUI:

 "This view is an item in the scroll system — you can align, snap, or target this."

 Without it, the scroll system may not know the size or alignment of each item well enough to snap reliably.

 🧩 Why it matters

 It is essential for:

 ✔ Snapping behavior

 (e.g., horizontally scrolling cards that snap to center)

 ✔ Scroll alignment (scrollTargetBehavior)

 .paging

 .viewAligned

 .viewportAligned
 */


