//
//  ContentView.swift
//  Quiz
//
//  Created by Torroba on 11/11/22.
//

import SwiftUI

struct QuizzesView: View {
    
    @EnvironmentObject var quizzesModel : QuizzesModel
    @EnvironmentObject var scoresModel : ScoresModel
    
    @State var showAlert = false
    @State var showAll = true
    
    var body: some View {
        NavigationStack{
            List {
                Toggle(isOn: $showAll.animation(.easeInOut)){
                    Label("Ver todos los quizzes", systemImage:"list.bullet.rectangle.portrait")
                }
                ForEach(quizzesModel.quizzes) { quizItem in
                    if showAll || !scoresModel.acertadas.contains(quizItem.id){
                        NavigationLink{
                            QuizPlayView(quizItem: quizItem)
                        }label: {
                            QuizRow(quizItem: quizItem)
                        }
                    }
                }
            }
            //Text("\(quizItem.count) Quizzes")
            .listStyle(.plain)
            .navigationTitle("Quizzes")
            .navigationBarItems(leading:
                                    Text("Record = \(scoresModel.record.count)"),
                                trailing:
                                    Button(action: {quizzesModel.download_dataTask()},
                                           label: {Label("Descargar", systemImage: "square.and.arrow.down")}))
            .task {
                if quizzesModel.quizzes.count == 0 {
                    await quizzesModel.download_async()
                }
            }
            .onReceive(quizzesModel.$errorMsg){ msg in
                showAlert = msg != nil
            }
            .alert(isPresented: $showAlert){
                Alert(title: Text("Alerta"),
                      message: Text(quizzesModel.errorMsg ?? ""),
                      dismissButton: .default(Text("Cerrar")))
            }
        }
    }
}


struct QuizView_Previews: PreviewProvider {
    
    static var qm : QuizzesModel = {
        var qm = QuizzesModel()
        qm.load()
        return qm
    }()
    
    static var previews: some View {
            QuizzesView()
            .environmentObject(qm)
    }
}
