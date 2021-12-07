//
//  SetGame2App.swift
//  SetGame2
//
//  Created by robert on 12/2/21.
//

import SwiftUI

@main
struct SetGame2App: App {
    var body: some Scene {
        let game = StandardSetGame()
        WindowGroup {
            SetGameView(game: game)
        }
    }
}
