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
        let cardsInPlay = game.cards.filter { $0.isInPlay }
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

    var soundIcon: String { ["speaker.slash", "speaker", "speaker.wave.1",][game.hintLevel] }

    // MARK: -- score title bar
    private var score: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button("New Game") {
                    withAnimation(.easeInOut(duration: Style.tick * 2/3)) {
                        game.newGame()
                    }
                }
                Spacer()
                Text("\(game.score)")
                Spacer()
                Button(action: game.toggleHint,
                       label: { Image(systemName: soundIcon).font(.system(size: 32)) })
            }
            .font(.title2)
            HStack {
                Spacer()
                Text(game.hint ?? "")
            }
            .font(.body)
        }
        .padding(.horizontal)
        .background(.background)
    }

    // MARK: -- playing field
    
    @State private var dealtCardIds: Set<Int> = []

    private func zIndex(for card: SetCard) -> Double {
        -Double(game.cards.firstIndex { $0.id == card.id} ?? 0)
    }
    
    @State private var minCapacity = 12

    private func playingField(cards: [SetCard]) -> some View {
        AspectVGrid(items: cards,
                    aspectRatio: Style.cardAspectRatio,
                    minCapacity: minCapacity)
        { card in
            // squeeze padding when more cards are in play
            let padForCardsInPlay = CGFloat(81 - cards.count) / 20
            let _ = srand48(card.id)
            StdCardView(card: card, faceColor: faceColor(for: card))
                .foregroundColor(highlightColor(for: card))
                .zIndex(zIndex(for: card))
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .messyStackEffect(!dealtCardIds.contains(card.id), orientation: Style.deckRotation)
                .transition(.asymmetric(insertion: .identity .animation(.none),
                                        removal: .opacity .animation(.none))
                )
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: Style.tick)) {
                        game.toggleFaceUp(card)
                    }
                }
                .onTapGesture(count: 1) {
                    withAnimation(.easeInOut(duration: Style.tick / 5)) {
                        game.choose(card)
                    }
                }
                .onAppear {
                    dealtCardIds.remove(card.id)
                    if card.isFaceUp { game.toggleFaceUp(card) }
                    withAnimation(.easeInOut(duration: Style.tick)
                                    .delay(game.dealAnimation[card.id] ?? 0)) {
                        dealtCardIds.insert(card.id)
                        game.toggleFaceUp(card)
                    }
                }
                .padding(padForCardsInPlay)
        }
        .padding(.horizontal)
    }

    // MARK: -- messy ZStack
    
    @State private var stackedCards: Set<Int> = []
    
    // TODO: cards should be a dont care, this should be MessyZStack
    private func cardPile(_ cards: [SetCard], orientation: Double) -> some View {
        ZStack {
            ForEach(cards) { card in
                let _ = srand48(card.id)
                StdCardView(card: card, faceColor: faceColor(for: card))
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .zIndex(zIndex(for: card))
                    .transition(.opacity .animation(.none)) // onAppear handles transition
                    .foregroundColor(highlightColor(for: card))
                    .messyStackEffect(stackedCards.contains(card.id), orientation: orientation)
                    .onAppear {
                        stackedCards.remove(card.id)
                        withAnimation(.easeInOut(duration: Style.tick).delay(game.dealAnimation[card.id] ?? 0)) {
                            _ = stackedCards.insert(card.id)
                        }
                    }
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

    @State private var goodCardIds: [Int] = []
    
    private var showHint: some View {
        Button("hint") {
            let choices = game.suggestions().shuffled()
            for card in choices {
                let delay = Double.random(in: 0.0 ... Style.tick / 3 * Double(choices.count))
                withAnimation(.linear(duration: Style.tick).delay(delay)) {
                    goodCardIds.append(card)
                }
                withAnimation(.linear(duration: 0.001).delay(delay + Style.tick * 1/4)) {
                    if let index = goodCardIds.firstIndex(of: card) {
                        goodCardIds.remove(at: index)
                    }
                }
            }
        }
    }
    private var decks: some View {
        HStack {
            Spacer()
            let discarded = game.cards.filter { $0.isDiscarded }
            if discarded.count > 0 {
                cardPile(discarded, orientation: Style.discardRotation)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: Style.tick)) {
                            game.shuffle()
                        }
                    }
            } else {
                shuffle
            }
            Spacer()
            cardPile(game.cards.filter { $0.isUndealt }, orientation: Style.deckRotation)
                .onTapGesture() {
                    if !game.isMatchedSet {
                        withAnimation(.easeInOut(duration: Style.tick * 2/3)) {
                            minCapacity = max(12, game.cards.filter { $0.isInPlay }.count + 3)
                        }
                    }
                    withAnimation(.easeInOut(duration: Style.tick)) {
                        game.deal(game.isMatchedSet ? 0 : 3)
                    }
                }
            Spacer()
            showHint
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
    
    var randomColor: Color {
        Color.init(hue: Double.random(in: 0...1), saturation: 0.66, brightness: 0.99, opacity: 1.0)
    }
    
    private func faceColor(for card: SetCard) -> Color {
        goodCardIds.contains(card.id) ? Color("cardFaceMatched") : //Color("cardFaceSelected") :
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
    // TODO: Shouldn't messyStackEffect be a GeometryEffect??
    /**
     Nudge the view randomly moving it horizontally, vertically, and rotationally
     
     - Parameter rotation: normal center of rotation
     - Parameter maxSlide: max movement in  x and y direction
     - Parameter maxRotate: maximum rotation (degrees)
     
    Uses drand48(), which seeded with each card's id will keep cards messy-but-stable.
     ```
     // Example use:
     srand48(card.id) // attach a fixed the jitter to each unique item
     ...
     cardView.messyStackEffect(card.id)
     ```
     */
    func messyStackEffect(_ isEnabled: Bool,
                          orientation: Double = 0,
                          maxSlide: Double = Style.deckSlide,
                          maxRotate: Double = Style.deckSlip) -> some View {
        let angle = Angle.degrees(orientation) + Angle(degrees: (drand48() - 0.5) * 2 * maxRotate)
        let x = CGFloat((drand48() - 0.5) * 2 * maxSlide)
        let y =  CGFloat((drand48() - 0.5) * 2 * maxSlide)
        return self
            .rotationEffect(isEnabled ? angle : Angle.zero)
            .offset(x: isEnabled ? x : 0, y: isEnabled ? y : 0)
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var newGame: StdSetGame {
        let game = StdSetGame()
        withAnimation(.easeInOut(duration: Style.tick)) {
            for _ in 1...12 {
                game.deal()
            }
        }
        game.choose(game.cards[0])
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
