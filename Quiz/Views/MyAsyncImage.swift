//
//  MyAsyncImage.swift
//  Quiz
//
//  Created by Álvaro Torroba de Linos on 23/11/22.
//

import SwiftUI

struct MyAsyncImage: View {
    
    var url : URL?
    
    var body: some View {
        
        AsyncImage(url:url) { phase in
            if url == nil{
                Image("cruz")
                    .resizable()
            }
            else if let image = phase.image {
                image.resizable() // Devuelve la imagen descargada
            } else if phase.error != nil {
                Color.red // Devuelve lo que hay que mostrar en caso de error.
            } else {
                ProgressView() // Se usa como placeholder durante la descarga.
            }
        }
        .scaledToFill()        
    }
}

//struct MyAsyncImage_Previews: PreviewProvider {
//    static var previews: some View {
//        MyAsyncImage()
//    }
//}
