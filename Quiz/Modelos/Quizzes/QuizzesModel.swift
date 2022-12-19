//
//  QuizzesModel.swift
//  Quiz con SwiftUI
//
//  Created by Álvaro Torroba de Linos on 11/11/22.
//

import Foundation

class QuizzesModel: ObservableObject {
    
    private let  urlBase = "https://core.dit.upm.es"
    private let  quizzesPath = "api/quizzes/random10wa?token"
    private let token = "0df61bb4c98a37ed0a5b"
    private var subscription: AnyObject?
    private let favPath = "api/users/tokenOwner/favourites"
    
    
    
    // Los datos
    @Published private(set) var quizzes = [QuizItem]()
    
    //Mensaje
    @Published var errorMsg : String?
    
    func load() {
        
        if quizzes.count != 0 {
            return
        }
                
        guard let jsonURL = Bundle.main.url(forResource: "quizzes", withExtension: "json") else {
            print("Internal error: No encuentro p1_quizzes.json")
            return
        }
        do {
            let data = try Data(contentsOf: jsonURL)
            let decoder = JSONDecoder()
            let quizzes = try decoder.decode([QuizItem].self, from: data)
            self.quizzes = quizzes

            print("Quizzes cargados")
        } catch {
            print("Algo chungo ha pasado: \(error)")
        }
    }
    
    func endpoint() -> URL?{
        let surl = "\(urlBase)/\(quizzesPath)=\(token)"
        guard let url = URL(string: surl) else {
            print("Internal error 1")
            return nil
        }
        return url
    }
    
    func endpointFav(quizId:Int) -> URL?{
        let surl = "\(urlBase)/\(favPath)/\(quizId)?token=\(token)"
        guard let url = URL(string: surl) else {
            print("Internal error 1")
            return nil
        }
        return url
    }
    
    func download_data() {
        
        guard let url = endpoint() else {return}
        
        print("Iniciando descarga: \(url).")
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let quizzes = try decoder.decode([QuizItem].self, from: data)
                
                DispatchQueue.main.async {
                    self.quizzes = quizzes
                    print("Quizzes cargados")
                }
                
            } catch {
                print("Algo chungo ha pasado: \(error)")
            }
        }
    }
    
    func download_dataTask() {
        
        guard let url = endpoint() else {return}
        
        print("Iniciando descarga: \(url).")
        
        URLSession.shared.dataTask(with: url){ data, response, error in
            
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data
            else{
                print("Fallo en la descarga")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let quizzes = try decoder.decode([QuizItem].self, from: data)
                
           // if let quizzes = try? JSONDecoder().decode([QuizItem].self, from: data){
                
                DispatchQueue.main.async {
                    self.quizzes = quizzes
                    print("Quizzes cargados")
                }
                
            }catch{
                print("Fallo en los datos json corrupto")
            }
        }
        .resume()
    }
    
    func download_async() async{
        
        guard let url = endpoint() else {return}
        
        print("Iniciando descarga: \(url).")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let quizzes =  try JSONDecoder().decode([QuizItem].self, from: data)
            
            DispatchQueue.main.async {
                self.quizzes = quizzes
                print("Quizzes cargados")
            }
        }catch{
            print("Fallo terrible")
            self.errorMsg = "Fallo terrible"
        }
    }
    
    func download_publisher(){
        
        guard let url = endpoint() else {return}
        
        print("Iniciando descarga: \(url).")
        
        subscription = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap{ data, _ in
                try JSONDecoder().decode([QuizItem].self, from: data)
            }
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                if case.failure(let error) = completion {
                    self.errorMsg = error.localizedDescription
                }
            } receiveValue: { quizzes in
                self.quizzes = quizzes
                print("Terminada la descarga")
            }
        print("Acabado")
    }
    
    
    func toggleFav(quizItemId: Int){
      
        guard let index = (quizzes.firstIndex{ quiz in quiz.id == quizItemId})
        else{
            print("No encontrado")
            return
        }
        
        guard let url = endpointFav(quizId: quizItemId)else {return}
        
        var req = URLRequest(url: url)
        req.httpMethod = quizzes[index].favourite ? "DELETE" : "PUT"
        
        
        URLSession.shared.uploadTask(with: req, from: Data()) { _, response, error in
            
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200
            else{
                print("Fallo favorito 1")
                return
            }
            DispatchQueue.main.async {
                self.quizzes[index].favourite.toggle()
            }
        }
        .resume()
    }
    
}
