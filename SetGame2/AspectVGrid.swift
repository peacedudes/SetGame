//
//  AspectVGrid.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI

#if true
//
//  AspectVGrid.swift
//  Memorize
//
//  Created by CS193p Instructor on 4/14/21.
//  Copyright Stanford University 2021
//

import SwiftUI

struct AspectVGrid<Item, ItemView>: View where ItemView: View, Item: Identifiable {
    var items: [Item]
    var aspectRatio: CGFloat
    var content: (Item) -> ItemView
    var minCapacity: Int
    
    init(items: [Item], aspectRatio: CGFloat, minCapacity: Int = 12, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
        self.minCapacity = minCapacity
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                let width: CGFloat = widthThatFits(itemCount: max(items.count, minCapacity), in: geometry.size, itemAspectRatio: aspectRatio)
                LazyVGrid(columns: [adaptiveGridItem(width: width)], spacing: 0) {
                    ForEach(items) { item in
                        content(item).aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        var columnCount = 1
        var rowCount = itemCount
        repeat {
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            if  CGFloat(rowCount) * itemHeight < size.height {
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        if columnCount > itemCount {
            columnCount = itemCount
        }
        return floor(size.width / CGFloat(columnCount))
    }

}

//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}



#else
struct AspectVGrid<Item: Identifiable, ItemView: View>: View {
    var items: [Item]
    var aspectRatio: CGFloat
    @ViewBuilder var content: (Item) -> ItemView
    
    var body: some View {
        GeometryReader { geometry in
            let width = widthThatBestFits(itemCount: items.count, size: geometry.size)
            LazyVGrid(columns: [aspectVGridItem(width: width)], spacing: 0) {
                ForEach(items) { item in
                    content(item).aspectRatio(aspectRatio, contentMode: .fit)
                }
            }
        }
    }
    
    private func aspectVGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    /* Divide the total space by number of cards to get per card acerage.
     Find lengths of sides of given aspect ratio that would fit perfectly.
     
     */
    private func widthThatBestFits(itemCount: Int, size: CGSize) -> CGFloat {
        let perCardArea = size.height * size.width / CGFloat(itemCount)
        let optimalWidth = sqrt(perCardArea * aspectRatio)
        let optimalHeight = optimalWidth / aspectRatio
        let maxRows = max(1, Int(size.height / optimalHeight))
        
        let widthLimit = size.height / CGFloat(maxRows) * aspectRatio
        let maxColumns = (itemCount + maxRows - 1) / maxRows
        let optimal = min(size.width / CGFloat(maxColumns), widthLimit)
        return optimal
    }
}
#endif

struct AspectVGrid_Previews: PreviewProvider {
    static var previews: some View {
        let pieces = 18
        let someViews = (0..<pieces).map {
            SampleView(id: $0, hue: Double($0) / Double(pieces))}

        AspectVGrid(items: someViews, aspectRatio: Style.cardAspectRatio) {
            $0 .padding(1)
        }
        .padding()
    }

    struct SampleView: View, Identifiable {
        let id: Int
        let hue: Double
        var body: some View {
            Color(hue: hue, saturation: 0.6, brightness: 0.6)
        }
    }
}
