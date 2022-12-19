//
//  QuizApp.swift
//  Quiz
//
//  Created by Torroba on 11/11/22.
//

import SwiftUI

@main
struct QuizApp: App {
    
    @StateObject var quizzesModel:QuizzesModel = QuizzesModel();
    @StateObject var scoresModel:ScoresModel = ScoresModel();
    
    var body: some Scene {
        WindowGroup {
            QuizzesView()
                .environmentObject(quizzesModel)
                .environmentObject(scoresModel)
        }
    }
}
