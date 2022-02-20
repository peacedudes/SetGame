//
//  Voices.swift
//  SetGame2
//
//  Created by robert on 12/17/21.
//

import Foundation
import AVFoundation


struct Voice {
    // TODO: Make language or voices choosable or localizable
    /// The preferred local voices available for speech synthesis
    static let local = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.prefix(3) == "en-" }

    // a named voice, if it exists
    static func named(_ name: String) -> AVSpeechSynthesisVoice? {
        local.first { $0.name.lowercased() == name.lowercased() }
    }
    static let speechSynth = AVSpeechSynthesizer()
}

extension String {
    
    func speak(voice: AVSpeechSynthesisVoice? = Voice.local.randomElement(), rate: Float = 0.64) {
        DispatchQueue.global(qos: .background).async {
            let utterance = AVSpeechUtterance(string: self)
            utterance.voice = voice
            utterance.pitchMultiplier = 0.5 + Float.random(in: 0..<0.75)    // randomize pitch
            utterance.rate = rate
            utterance.volume = 0.1
            if Voice.speechSynth.isSpeaking {
                Voice.speechSynth.stopSpeaking(at: .immediate)
            }
            Voice.speechSynth.speak(utterance)
        }
    }
}

extension SetGame {
    var feedback: String? {
        let responses: [Outcome: [String]] = [
            .match: [
                "\(score)",
                "awesome, dude",
                "brilliant",
                "easy as pie",
                "good",
                "good one",
                "in the bag",
                "just like that",
                "low hanging fruit",
                "Magnificent!",
                "nailed it",
                "nicely done",
                "perfect",
                "shoots... and scores!",
                "yes",
                "yes that's right",
                "you're on fire",
                "you've got it",
                "way to go",
            ],
            .mismatch: [
                "are you pulling my leg?",
                "awww, that's too bad",
                "back to the drawing board",
                "close, but no cigar",
                "Crivens!",
                "dang nabbit!",
                "Fudge!",
                "Hang in there",
                "He's dead Jim",
                "How do you like them apples?",
                "huh-uh",
                "I thought you had it",
                "I'm sorry, No.",
                "Inconcievable",
                "It's hard, isn't it?",
                "Keep trying",
                "nice try",
                "no",
                "shoots... and misses",
                "son of a bitcoin",
                "that didn't work",
                "Waily, Waily, Waily!",
            ],
            .matchable: [
                "good",
                "ok",
                "Okey-Dokey",
                "that works",
                "yes",
                "yup",
            ],
            .unmatchable: [
                "\(score)",
                "doesn't work",
                "I smell a rat",
                "no",
                "nope",
                "Oh dear, no.",
                "that's going to cost you",
                "try again",
                "are you sure?",
                "you're in a bit of a pickle",
            ]
        ]
        let result = outcome
        guard result != .none else { return hasPlayableMatch([]) ? nil :
            isDeckEmpty ? ["Game overmaan.", "the game is over"].randomElement() :
            "This could be difficult..."
        }
        return responses[outcome]?.randomElement()
    }
}
