//
//  MessyZStack.swift
//  SetGame2
//
//  Created by robert on 2/17/22.
//

import SwiftUI


struct MessyZStack<Item, ItemView>: View where ItemView: View, Item: Identifiable {
    var items: [Item]
    var pile: StackOrientation
    @ViewBuilder var content: (Item) -> ItemView
    
    init(_ items: [Item], pile: StackOrientation = StackOrientation(), content: @escaping (Item) -> ItemView) {
        self.items = items
        self.pile = pile
        self.content = content
    }
    
    @State private var messyItems: [Item.ID] = []
    
    var body: some View {
        ZStack {
            ForEach(items) { item in
                let _ = srand48(item.id.hashValue)
                content(item)
                    .transition(.asymmetric(insertion: .identity .animation(.none),
                                            removal: .opacity .animation(.none)))
                    .messyStackEffect(messyItems.contains(item.id), pile: pile)
                    .onAppear {
                        messyItems = messyItems.filter { $0 != item.id }
                        // TODO: (1) is wrong.  This should match the timing of the dealt cards.  How?
                        withAnimation(.easeInOut(duration: Style.tick).delay(1) ) {
                            messyItems.append(item.id)
                        }
                    }
            }
        }
    }
}

struct StackOrientation {
    /// degrees; nominal resting rotation
    var rotation: Double // Degrees
    /// max random deviation from normal rotation in degrees
    var maxSlip: Double // Degrees
    /// max random horizontal and vertical displacements from center
    var maxSlide: CGFloat
    

    /**
     Style preferences for MessyZStack

     - Parameter rotation: degrees; nominal resting rotation
     - Parameter maxSilp: max random deviation from normal rotation in degrees
     - Parameter maxSlide: max random horizontal and vertical displacements from center
     */
    init(rotation: Double = 0, maxSlip: Double = 10, maxSlide: CGFloat = 10) {
        self.rotation = rotation
        self.maxSlip = maxSlip
        self.maxSlide = maxSlide
    }
}

extension View {
    // TODO: Shouldn't messyStackEffect be a GeometryEffect??
    /**
     Nudge the view randomly moving it horizontally, vertically, and rotationally
  
    Uses drand48(), which seeded with each card's id will keep cards messy-but-stable.
     ```
     // Example use:
     srand48(card.id) // attach a fixed the jitter to each unique item
     ...
     cardView.messyStackEffect(card.id)
     ```
     */
    func messyStackEffect(_ isEnabled: Bool, pile: StackOrientation) -> some View {
        let angle = Angle.degrees(pile.rotation) + Angle(degrees: (drand48() - 0.5) * 2 * pile.maxSlip)
        let x = CGFloat((drand48() - 0.5) * 2 * pile.maxSlide)
        let y =  CGFloat((drand48() - 0.5) * 2 * pile.maxSlide)
        return self
            .rotationEffect(isEnabled ? angle : Angle.zero)
            .offset(x: isEnabled ? x : 0, y: isEnabled ? y : 0)
    }
}


struct MessyPileView_Previews: PreviewProvider {
    static var previews: some View {
        let cards = [
            SetCard(id: 1, isFaceUp: true),
            SetCard(id: 2, isFaceUp: true),
            SetCard(id: 32, isFaceUp: true),
            SetCard(id: 60, isFaceUp: true),
            SetCard(id: 79, isFaceUp: true),
            SetCard(id: 75, isFaceUp: true)
        ]
        MessyZStack(cards) {
            StdCardView($0)
                .padding(50)
        }
    }
}
