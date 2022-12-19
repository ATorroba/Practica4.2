//
//  QuizRowView.swift
//  Quiz
//
//  Created by Álvaro Torroba de Linos on 23/11/22.
//

import SwiftUI

struct QuizRow: View {
    
    var quizItem : QuizItem
    
    var body: some View{
            HStack{
                MyAsyncImage(url: quizItem.attachment?.url)
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                    .shadow(radius: 15)
                VStack{
                    HStack{
                        Image(systemName: quizItem.favourite ? "star.fill": "star")
                            .foregroundColor(Color.yellow)
                            .shadow(radius: 15)
                            
                        Spacer()
                        Text(quizItem.author?.username  ?? "Anónimo")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        MyAsyncImage(url: quizItem.author?.photo?.url)
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .shadow(radius: 15)
                    }
                    Text(quizItem.question)
                        .fontWeight(.heavy)
                }
            }
    }
}

struct QuizRow_Previews: PreviewProvider {
    
    static var qm : QuizzesModel = {
        var qm = QuizzesModel()
        qm.download_data()
        return qm
    }()
    
    static var previews: some View {
        VStack{
            QuizRow(quizItem: qm.quizzes[0])
            
        }
    }
}
