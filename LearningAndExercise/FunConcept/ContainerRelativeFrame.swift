//
//  ContainerRelativeFrame.swift
//  LearningAndExercise
//
//  Created by hb on 27/10/25.
//

import SwiftUI

/// A modifier for sizing a view relative to the nearest container.
/// The size provided to this modifier is the size of the container subtracting any safe area insets that might be applied to that container.


struct ContainerRelativeDemo: View {
    let spacing: CGFloat = 15
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: spacing) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.opacity(0.8))
//                        .containerRelativeFrame(.vertical)  // Occupie the shape of the container vertically.
                    
                    ///Simply use the containerRelativeFrame(_:count:span:spacing:alignment:) variation to specify
                    ///count: the total number of views, ie: rows or columns, in the specified axis,
                    ///span: the number of rows or columns that the modified view should actually occupy
                    ///spacing: the spacing between each view
                    
                        .aspectRatio(2.0 / 2.0, contentMode: .fit)
                        .containerRelativeFrame(.vertical, count: 3, span: 1, spacing: 24)
                    
                    /// Now you might say, if we have use GeometryReader, we not only get to determine the size of the main axes, vertical in this case, we can also calculate the horizontal size accordingly.
                    /// the size of the opposite axes is most likely determined by the main axes, by that means, we can just use the aspectRatio(_:contentMode:) modifier.
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

#Preview {
    ContainerRelativeDemo()
}
