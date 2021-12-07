//
//  SetGameView.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI


struct SetGameView: View {
    @ObservedObject var game: StandardSetGame
    
    var body: some View {
        let items = game.cards.filter { $0.state == .inPlay }
        VStack {
            score
            AspectVGrid(items: Array(items), aspectRatio: Style.cardAspectRatio) { card in
                StandardCardView(card: card, faceColor: faceColor(for: card))
                    .foregroundColor(highlightColor(for: card))
                    .onTapGesture {
                        game.choose(card)
                    }
                    .padding(1)
            }
            .padding()
            Spacer()
        }
        .background(Color("background"))//(.background)
        .onAppear {
            game.deal(12)
        }
    }

    var score: some View {
        HStack {
            Spacer()
            Button("New Game") { game.newGame() }
            Spacer()
            Text("score 0")
            Spacer()
            if game.cards.first(where: { $0.state == .undealt }) != nil {
                Button("Deal 3") { game.deal(3) }
                Spacer()
            }
        }
        .background(.background)
    }
    private func faceColor(for card: SetCard) -> Color {
        guard card.isSelected else { return Color("cardFace") }
        if game.isMatchedSet { return Color("cardFaceMatched") }
        if game.isMisMatchedSet { return Color("cardFaceMismatched") }
        return Color("cardFaceSelected")
    }

    private func highlightColor(for card: SetCard) -> Color {
        guard card.isSelected else { return .black }
        if game.isMatchedSet { return .green }
        if game.isMisMatchedSet { return .pink }
        return .yellow
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var newGame: StandardSetGame {
        let game = StandardSetGame()
        game.shuffle()
        game.deal(0)
        return game
    }
    
    static var previews: some View {
        let game = newGame
        Group {
            SetGameView(game: game)
                .preferredColorScheme(.dark)
            SetGameView(game: game)
        }
    }
}
