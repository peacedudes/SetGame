//
//  StandardSetGameView.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI


struct StandardSetGameView: View {
    @ObservedObject var game: StandardSetGame
    var body: some View {
        let items = game.cards.filter { $0.state == .inPlay }
        VStack {
            score
            if items.count > 0 {
                playingField(cards: items)
            } else {
                gameOver
            }
            Spacer()
        }
        .background(Color("background")) // default: (.background)
//        .onAppear { game.deal(12) }
    }

    var soundIcon: String { game.isHushed ? "speaker" : "speaker.wave.1" }

    private var score: some View {
        HStack(alignment: .bottom) {
            Spacer()
            Button("New\nGame") { game.newGame() }
            Spacer()
            Button(action: game.toggleSound,
                   label: { Image(systemName: soundIcon) })
            Spacer()

            Text("score\n\(game.score)")
                .multilineTextAlignment(.center)
            Spacer()

            if game.cards.first(where: { $0.state == .undealt }) != nil {
                Button("Deal 3") { game.deal(3) }
                Spacer()
            }
        }
        .font(.title2)
        .background(.background)
    }

    private func playingField(cards: [SetCard]) -> some View {
        let padForCardsInPlay = CGFloat(81 - cards.count) / 20
        return AspectVGrid(items: cards, aspectRatio: Style.cardAspectRatio) { card in
            StandardCardView(card: card, faceColor: faceColor(for: card))
                .foregroundColor(highlightColor(for: card))
                .onTapGesture {
                    game.choose(card)
                }
                .padding(padForCardsInPlay)
        }
        .padding(padForCardsInPlay)
    }
    
    private var gameOver: some View {
        VStack {
            Text("SHALL  WE  PLAY  A  GAME?")
                .fontWeight(.ultraLight)
                .font(.title2)
                .padding(.vertical, 30)
                .onTapGesture { game.newGame() }
            Text("(play)").cardify(isFaceUp: false)
                .rotationEffect(Angle(degrees: -90))
                .padding(.horizontal, 100)
                .onTapGesture { game.newGame() }
            
            Text("""
                Stanford CS193P SwiftUI assignment.

                This unofficial game uses ideas and designs without permission from
                Marsha Jean Falco (Set's creator) or Set Enterprises Inc.

                Not for sale.
                """)
                .font(.footnote)
                .padding(50)
        }
    }
    
    private func faceColor(for card: SetCard) -> Color {
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
    static var newGame: StandardSetGame {
        let game = StandardSetGame()
        game.deal(12)
//        game.deal(81)
        return game
    }
    
    static var previews: some View {
        let game = newGame
        Group {
            StandardSetGameView(game: game)
                .preferredColorScheme(.dark)
            StandardSetGameView(game: game)
        }
    }
}
