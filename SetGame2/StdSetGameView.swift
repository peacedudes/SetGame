//
//  StdSetGameView.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI

struct StdSetGameView: View {
    @ObservedObject var game: StdSetGame
    
    @Namespace private var dealingNamespace
    var cardsInPlay: [SetCard] { game.cards.filter { $0.isInPlay } }
    var activeSpeed: Double { game.clock }
    var setTick: Animation { .easeInOut(duration: activeSpeed) }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            decks
            VStack(spacing: 0) {
                Spacer(minLength: 60)
                if cardsInPlay.count > 0 {
                    playingField(cards: cardsInPlay)
                } else {
                    gameOver
                }
                Spacer(minLength: 50)
            }
            VStack {
                score
                Spacer()
            }
            Spacer(minLength: 0)
        }
        .background(Color("background").opacity(0.3))
    }

    var soundIcon: String { ["speaker.slash", "speaker", "speaker.wave.1"][game.hintLevel % 3] }
    var speedIcon: String { ["hare", "tortoise"][game.pace % 2]}

    // MARK: -- score title bar
    private var score: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button(game.cards.first(where: { $0.isInPlay}) == nil ? "" : "New") {
                    withAnimation(.easeInOut(duration: activeSpeed * 2/3)) {
                        game.newGame()
                    }
                }
                Spacer()
                Button(action: withAnimation(setTick) { game.toggleSpeed },
                       label: { Image(systemName: speedIcon).font(.system(size: 20)) })
                Spacer()
                Text("\(game.score)")
                Spacer()
                Button(action: withAnimation(setTick) { game.toggleHint },
                       label: { Image(systemName: soundIcon).font(.system(size: 28)) })
            }
            .font(.title2)
            HStack {
                Spacer()
                if game.score >= game.highScore {
                    Text("* hiscore *")
                        .transition(.asymmetric(insertion: .scale.animation(.easeInOut(duration: activeSpeed / 3).repeatCount(5)),
                                                removal: .opacity))
                    Spacer()
                }
                Text(game.hint ?? "").font(.body)
            }
            
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
    @State private var misMatchedCards: [SetCard] = []
    
    private func paddingForCardsInPlay(_ count: Int) -> CGFloat {
        CGFloat(81 - count) / 20
    }
    private func playingField(cards: [SetCard]) -> some View {
        AspectVGrid(items: cards,
                    aspectRatio: Style.cardAspectRatio,
                    minCapacity: minCapacity)
        { card in
            let _ = srand48(card.id.hashValue) // sync randomness to card
            StdCardView(card, faceColor: faceColor(for: card))
                .foregroundColor(highlightColor(for: card))
                .zIndex(zIndex(for: card))
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .messyStackEffect(!dealtCardIds.contains(card.id), pile: Style.deck)
                .transition(.asymmetric(insertion: .identity .animation(.none),
                                        removal: .opacity .animation(.none))
                )
                .onTapGesture(count: 2) {
                    withAnimation(setTick) { game.toggleFaceUp(card) }
                }
                .onTapGesture(count: 1) {
                    game.choose(card)
                }
                .onAppear {
                    dealtCardIds.remove(card.id)
                    if card.isFaceUp { game.toggleFaceUp(card) }
                    withAnimation(setTick .delay(game.dealAnimation[card.id] ?? 0)) {
                        dealtCardIds.insert(card.id)
                        game.toggleFaceUp(card)
                    }
                }
                .onDisappear {
                    dealtCardIds.insert(card.id)
                    withAnimation(setTick .delay(game.dealAnimation[card.id, default: 0])) {
                        _ = dealtCardIds.remove(card.id)
                    }
                }
                .padding(paddingForCardsInPlay(cards.count))
        }
        .padding(paddingForCardsInPlay(cards.count))
    }

    // MARK: -- Bottom bar card piles and buttons
    
    private var decks: some View {
        HStack {
            Spacer()
            let discarded = game.cards.filter { $0.isDiscarded }
            if discarded.count > 0 {
                cardPile(discarded, pile: Style.discard)
                    .onTapGesture {
                        withAnimation(setTick) { game.shuffle() }
                    }
            } else {
                scramble
            }
            Spacer()
            cardPile(game.cards.filter { $0.isUndealt }, pile: Style.deck)
                .onTapGesture() {
                    if !game.isMatchedSet {
                        withAnimation(.easeInOut(duration: activeSpeed * 0.6)) {
                            minCapacity = max(game.cardsToDeal, game.cards.filter { $0.isInPlay }.count + 3)
                        }
                    }
                    withAnimation(setTick) {
                        game.deal(game.isMatchedSet ? 0 : 3)
                    }
                }
            Spacer()
            showHint
            Spacer()
        }
        .background(.background)
    }
    
    private func cardPile(_ cards: [SetCard], pile: StackOrientation) -> some View {
        MessyZStack(cards, pile: pile) { card in
            StdCardView(card, faceColor: faceColor(for: card))
                .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                .zIndex(zIndex(for: card) * (card.isFaceUp ? -1 : 1))
                .foregroundColor(highlightColor(for: card))
        }
        .frame(idealHeight: 60, maxHeight: 100)
    }
    
    private var scramble: some View {
        Button(cardsInPlay.count > 0 ? "scramble" : "") {
            withAnimation(setTick) { game.shuffle() }
        }
    }

    @State private var goodCardIds: [Int] = []
    
    private var showHint: some View {
        Button("hint") {
            let choices = game.suggestions().shuffled()
            for cardId in choices {
                let delay = Double.random(in: 0.0 ... activeSpeed / 3 * Double(choices.count))
                withAnimation(.linear(duration: activeSpeed).delay(delay)) {
                    goodCardIds.append(cardId)
                }
                withAnimation(.linear(duration: 0.01).delay(delay + activeSpeed * 1/4)) {
                    if let index = goodCardIds.firstIndex(of: cardId) {
                        goodCardIds.remove(at: index)
                    }
                }
            }
        }
    }

    
    private var gameOver: some View {
        VStack {
            Text("SHALL  WE  PLAY  A  GAME?")
                .fontWeight(.light)
                .font(.title2)
                .padding()
                .onTapGesture { withAnimation(setTick) { game.newGame() } }
                
            Text("""
                Stanford CS193P SwiftUI assignment.
                
                Geneticist Marsha Jean Falco invented SET in 1974. You can buy the real card game from Set Enterprises Inc.  This demo necessarily borrows their ideas without asking, and shamelessly mimics their designs without consent.  Think of this as an homage.
                
                Demo - Not for sale.
                """)
                .font(.body)
                .padding()
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

struct SetGameView_Previews: PreviewProvider {
    static var newGame: StdSetGame {
        let game = StdSetGame()
        withAnimation(.easeInOut(duration: game.clock)) {
            for _ in 1...game.minimumCardsToShow {
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
