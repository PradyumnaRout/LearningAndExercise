//
//  AnimationANDTransition1.swift
//  LearningAndExercise
//
//  Created by hb on 24/11/25.
//

import Foundation
import SwiftUI

struct ExampleFullZoomView: View {
    @State private var path = NavigationPath()
    @Namespace private var nameSpace

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 24) {
                Text("Home")
                    .font(.largeTitle)

                Button {
                    // push "detail" into the navigation path
                    path.append("detail")
                } label: {
                    Text("Go to detail")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                        )
                }
                // source element participates in the matched/zoom animation
                .matchedTransitionSource(id: "detailView", in: nameSpace)

                Spacer()
            }// Vstack
            .padding()
            .navigationTitle("Home")
            // register the destination on the NavigationStack
            .navigationDestination(for: String.self) { value in
                if value == "detail" {
                    // pass the binding + namespace into the destination
                    FullZoomDetailView(path: $path, namespace: nameSpace)
                        .navigationTransition(.zoom(sourceID: "detailView", in: nameSpace))
                } else {
                    // fallback (not used here)
                    EmptyView()
                }
            }
        }
    }
}

// Destination that hides the system nav bar and draws its own top bar
struct FullZoomDetailView: View {
    @Binding var path: NavigationPath
    let namespace: Namespace.ID

    init(path: Binding<NavigationPath>, namespace: Namespace.ID) {
        self._path = path
        self.namespace = namespace
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom top bar — part of the destination's view hierarchy
//            HStack {
//                Button {
//                    // immediate pop
//                    path.removeLast()
//                } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "chevron.left")
//                        Text("Back")
//                    }
//                }
//
//                Spacer()
//
//                Text("Detail")
//                    .font(.headline)
//                    .bold()
//
//                Spacer()
//
//                // placeholder to balance the header
//                Color.clear.frame(width: 70, height: 1)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 10)
//            .background(.ultraThinMaterial)
//            .zIndex(1)
//
            Spacer()

            // The main content that participates in the matched transition target.
            // This is the element that maps to the button label in the source.
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red)
                    .frame(width: 260, height: 260)
//                     matchedTransitionTarget ties the source -> destination element

                Text("Detail View")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()
        }
        // Hide the system navigation bar so our custom bar is used instead
//        .navigationBarBackButtonHidden(true)
//        .navigationBarHidden(true)
//        .edgesIgnoringSafeArea(.bottom) // optional, for full-screen feel
    }
}



#Preview {
    ExampleFullZoomView()
}



struct ContentView1: View {
    @Namespace private var namespace
    @State private var path = NavigationPath()

    let imageUrls = [
        "https://picsum.photos/id/10/300/300",
        "https://picsum.photos/id/11/300/300",
        "https://picsum.photos/id/12/300/300",
        "https://picsum.photos/id/13/300/300",
        "https://picsum.photos/id/14/300/300",
        "https://picsum.photos/id/15/300/300",
        "https://picsum.photos/id/16/300/300",
        "https://picsum.photos/id/17/300/300",
        "https://picsum.photos/id/18/300/300",
        "https://picsum.photos/id/19/300/300",
        "https://picsum.photos/id/20/300/300",
        "https://picsum.photos/id/21/300/300"
    ]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        // <-- bind the NavigationStack to $path
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(imageUrls.indices, id: \.self) { index in
                        ImageCellView(
                            index: index,
                            urlString: imageUrls[index],
                            namespace: namespace,
                            path: $path
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Gallery")

            // register destination once at the NavigationStack level
            .navigationDestination(for: String.self) { value in
                // compute the index of the tapped image from the value
                let idx = imageUrls.firstIndex(of: value) ?? 0

                // supply both matched target and navigationTransition using that index
                DetailView(imageUrl: value)
                    .navigationTransition(
                        .zoom(sourceID: "image-\(idx)", in: namespace)
                    )
            }
        }
    }
}


struct ImageCellView: View {
    let index: Int
    let urlString: String
    let namespace: Namespace.ID
    @Binding var path: NavigationPath

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .empty:
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                    .overlay { ProgressView() }
            case .failure:
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                    .overlay { Image(systemName: "photo") }
            @unknown default:
                RoundedRectangle(cornerRadius: 2)
            }
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .matchedTransitionSource(id: "image-\(index)", in: namespace)
        .onTapGesture {
            // append the unique url string — the NavigationStack's destination matches on String.self
            path.append(urlString)
        }
    }
}



#Preview {
    ContentView1()
}


struct DetailView: View {
    
   let imageUrl: String
   @State private var dragOffset: CGFloat = 0
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        print("Init")
    }
   
   var body: some View {
       ScrollView {
           VStack(spacing: 0) {
               AsyncImage(url: URL(string: imageUrl)) { image in
                   image
                       .resizable()
                       .aspectRatio(contentMode: .fill)
               } placeholder: {
                   RoundedRectangle(cornerRadius: 2)
                       .fill(.gray.opacity(0.2))
               }
               .frame(height: 400)
               
               VStack(alignment: .leading, spacing: 16) {
                   Text("Lorem ipsum dolor sit amet")
                       .font(.title)
                       .fontWeight(.bold)
                   
                   Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                       .font(.body)
                       .foregroundStyle(.secondary)
               }
               .padding()
           }
       }
   }
}
