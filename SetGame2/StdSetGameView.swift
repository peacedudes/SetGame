//
//  StdSetGameView.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI
import simd


struct StdSetGameView: View {
    @ObservedObject var game: StdSetGame
    
    @Namespace private var dealingNamespace
    
    var body: some View {
        let cardsInPlay = game.cards.filter { $0.state == .inPlay }
        ZStack(alignment: .bottom) {
            decks
            VStack(spacing: 0) {
                score
                if cardsInPlay.count > 0 {
                    playingField(cards: cardsInPlay)
                } else {
                    gameOver
                }
                Spacer(minLength: 40)
            }
            Spacer(minLength: 0)
        }
        .background(Color("background").opacity(0.3))
    }

    var soundIcon: String { game.isHushed ? "speaker" : "speaker.wave.1" }

    // MARK: -- score title bar
    private var score: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button("New Game") {
                    withAnimation(.easeInOut(duration: Style.tick)) {
                        game.newGame()
                    }
                }
                Spacer()
                Text("\(game.score)")
                Spacer()
                Button(action: game.toggleSound,
                       label: { Image(systemName: soundIcon).font(.system(size: 39)) })
            }
            .font(.title2)
            HStack {
                Spacer()
                Text(game.hint ?? "_")
            }
            .font(.body)
        }
        .padding(.horizontal)
        .background(.background)
    }

    // MARK: -- playing field
    
    @State private var dealtCardIds: Set<Int> = []
    
//    private func dealAnimation(for card: SetCard) -> Animation {
//        let cardsToDeal = game.cards.filter { $0.state == .inPlay && !dealtCardIds.contains(card.id) }
//        var delay = 0.0
//        if let index = cardsToDeal.firstIndex(where: { $0.id == card.id }) {
//            delay = Double(index) * (Style.totalDealDuration / Double(cardsToDeal.count))
//            print("delay", delay)
//        }
//        return Animation.easeInOut(duration: Style.cardDealDuration).delay(delay)
//    }

    // TODO: do I need this on a card itself?
//    @State private var isInAPile = false
    private func zIndex(for card: SetCard) -> Double {
        -Double(game.cards.firstIndex { $0.id == card.id} ?? 0)
    }
    
    private func playingField(cards: [SetCard]) -> some View {
        let padForCardsInPlay = CGFloat(81 - cards.count) / 20
        let theView = AspectVGrid(items: cards, aspectRatio: Style.cardAspectRatio) { card in
            let _ = srand48(card.id)
            StdCardView(card: card, faceColor: faceColor(for: card))
                .foregroundColor(highlightColor(for: card))
                .zIndex(zIndex(for: card))
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .messyStackEffect(!dealtCardIds.contains(card.id), rotation: Style.deckRotation)
                .transition(.asymmetric(insertion: .identity .animation(.none),
                                        removal: .scale .animation(.none))
                )
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: Style.tick)) {
                        game.toggleFaceUp(card)
                    }
                }
                .onTapGesture(count: 1) {
                    withAnimation(.easeInOut(duration: Style.tick)) {
                        game.choose(card)
                    }
                }
                .onAppear {
                    dealtCardIds.remove(card.id)
                    if card.isFaceUp {
                        game.toggleFaceUp(card)
                    }
                    withAnimation(.easeInOut(duration: Style.tick).delay(dealAnimation[card.id] ?? 0)) {
                        dealtCardIds.insert(card.id)
                        game.toggleFaceUp(card)
                    }

                }
                .padding(padForCardsInPlay)
        }
            .padding(padForCardsInPlay)
        
        //        dealtCardIds = game.cards.filter { $0.state == .inPlay } .map { $0.id }
        return theView
    }

    // MARK: -- messy ZStack
    
    // TODO: cards should be a dont care, this should be MessyZStack
    
    @State private var stackedCards: Set<Int> = []
    
    private func cardPile(_ cards: [SetCard], rotation: Double) -> some View {
        return ZStack {
            ForEach(cards) { card in
                let _ = srand48(card.id)
                StdCardView(card: card, faceColor: faceColor(for: card))
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(for: card))
                    .transition(.opacity .animation(.none))
                    .foregroundColor(highlightColor(for: card))
                    .messyStackEffect(stackedCards.contains(card.id), rotation: rotation)
                    .onAppear { stackedCards.insert(card.id) }
                    .onDisappear { stackedCards.remove(card.id) }
            }
        }
        .frame(idealHeight: 60, maxHeight: 100)
        .zIndex(99999)
    }
    
    private var shuffle: some View {
        Button("mix up") {
            withAnimation(.easeInOut(duration: Style.tick)) {
                game.shuffle()
            }
        }
    }

    @State private var goodCards: [Int] = []
    
    private var showHint: some View {
        Button("hint") {
            goodCards = game.suggestions()
            withAnimation(.linear(duration: Style.tick)) {
                goodCards = []
            }
        }
    }

    @State private var dealAnimation: [Int: Double] = [:]
    /**
     Prepare  to deal the next cardCount cards, setting a launch order timing delay for each.  The cards are not dealt.
     - Parameter cardCount: The number of cards that will be dealt
     - Returns: the actual cards to be dealt

     Cards are dealt from the deck, but turn faceUp in onAppear in playingField, and the timings must match.
     dealAnimation is a scratch pad [card.id: animation delay] for synchronizing these animations.
     */
    @discardableResult
    private func setDealAnimation(for cardCount: Int) -> [SetCard] {
        let cardsToDeal = Array(game.cards.filter { $0.state == .undealt }.prefix(cardCount))
        
        let perCardDelay = min(Style.tick, Style.totalDealDuration / Double(cardCount))
        var delay = 0.0
//        for (i, card) in cardsToDeal.enumerated() {
//            dealAnimation[card.id] = delay
//            delay += perCardDelay
//            delay += (i + 1) % 3 == 0 ? perCardDelay * 3 : 0
//        }
        for card in cardsToDeal {
            dealAnimation[card.id] = delay
            delay += perCardDelay / 2 + Double.random(in: 0...perCardDelay)
        }
        return cardsToDeal
    }
    
    private var decks: some View {
        HStack {
            Spacer()
            cardPile(game.cards.filter { $0.state == .discarded }, rotation: Style.deckRotation)
            Spacer()
            cardPile(game.cards.filter { $0.state == .undealt }, rotation: Style.discardRotation)
                .onTapGesture() {
                    let neededCards = max(game.cardsToDeal, 3) - (game.isMatchedSet ? 2 : 0)
                    let cardsToDeal = setDealAnimation(for: neededCards)
                    for card in cardsToDeal {
                        withAnimation(.easeInOut(duration: Style.cardDealDuration).delay(dealAnimation[card.id] ?? 0)) {
                            game.deal()
                        }
                    }
                }
            Spacer()
            showHint
            Spacer()
            shuffle
            Spacer()
        }
        .background(.background)
    }
    
    private var gameOver: some View {
        VStack {
            Text("SHALL  WE  PLAY  A  GAME?")
                .fontWeight(.light)
                .font(.title2)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: Style.tick)) {
                        dealAnimation = [:]
                        game.newGame()
                    }
                }
            Text("peace").cardify(isFaceUp: false)
                .frame(maxWidth: 120)
                .rotationEffect(Angle(degrees: -90))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: Style.tick)) {
                        game.newGame()
                    }
                }
            Text("""
                Stanford CS193P SwiftUI assignment.
                
                Geneticist Marsha Jean Falco invented SET in 1974. You can buy the real card game from Set Enterprises Inc.  This demo necessarily borrows their ideas without asking, and shamelessly mimics their designs without consent.  It's an homage.
                
                Demo - Not for sale.
                """)
                .font(.body)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private func faceColor(for card: SetCard) -> Color {
        goodCards.contains(card.id) ? Color("cardFaceSelected") :
        !card.isSelected ? Color("cardFace") :
        game.isMatchedSet ? Color("cardFaceMatched") :
        game.isMisMatchedSet ? Color("cardFaceMismatched") :
        Color("cardFaceSelected")
    }
    
    private func highlightColor(for card: SetCard) -> Color {
        !card.isSelected ? .black :
        game.isMatchedSet ? .green :
        game.isMisMatchedSet ? .pink :
            .yellow
    }
}

extension View {
    /**
     Nudge the view randomly moving it horizontally, vertically, and rotationally
     
     - Parameter seed: random number seed so views can be redrawn with the same jitter
     - Parameter rotation: normal center of rotation
     - Parameter maxSlide: max movement in  x and y direction
     - Parameter maxRotate: maximum rotation (degrees)
     
     ```
     // Example use:
     srand48(card.id) // attach a fixed the jitter to each unique item
     ...
     cardView.messyStackEffect(card.id)
     ```
     */
    func messyStackEffect(_ isEnabled: Bool,
                          rotation: Double = 0,
                          maxSlide: Double = Style.deckSlide,
                          maxRotate: Double = Style.deckSlip) -> some View {
        let angle = Angle.degrees(rotation) + Angle(degrees: (drand48() - 0.5) * 2 * maxRotate)
        let x = CGFloat((drand48() - 0.5) * 2 * maxSlide)
        let y =  CGFloat((drand48() - 0.5) * 2 * maxSlide)
        return self
            .rotationEffect(isEnabled ? angle : Angle.zero)
//            .transformEffect(.init(translationX: x, y: y))
            .offset(x: isEnabled ? x : 0, y: isEnabled ? y : 0)
    }
}
// TODO: Shouldn't messyStackEffect be a GeometryEffect??
//struct JitterEffect: GeometryEffect {
//    var offset: CGSize
//    
//    var animatableData: CGSize.AnimatableData {
//        get { CGSize.AnimatableData(offset.width, offset.height) }
//        set { offset = CGSize(width: newValue.first, height: newValue.second) }
//    }
//
//    public func effectValue(size: CGSize) -> ProjectionTransform {
//        return ProjectionTransform(CGAffineTransform(translationX: offset.width, y: offset.height))
//    }
//}
//public extension View {
//    func jitterEffect(_ offset: CGSize) -> some View {
//        return modifier(JitterEffect(offset: offset))
//    }
//}

struct SetGameView_Previews: PreviewProvider {
    static var newGame: StdSetGame {
        let game = StdSetGame()
        withAnimation(.easeInOut(duration: Style.tick)) {
            for _ in 1...12 {
                game.deal()
            }
        }
        return game
    }
    
    static var previews: some View {
        let game = newGame
        Group {
            StdSetGameView(game: game)
                .preferredColorScheme(.dark)
            StdSetGameView(game: game)
        }
    }
}
