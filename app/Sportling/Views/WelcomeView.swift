//
//  WelcomeView.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation
import SwiftUI
import Model3DView

struct WelcomeView: View {
    @State private var rotationAngle: Double = 90
    
    var callback: () -> ()
    
    var body: some View {
        VStack {
            Text("Hello!").font(.bold(.system(size: 70))())
            Model3DView(named: "karhu.glb")
                .transform(
                    rotate: Euler(y: .degrees(rotationAngle)),
                    scale: 0.8
                ).frame(height: 400).onAppear(perform: animate)
           
            NavigationLink(destination: NameEnterView(callback: callback)) {

                    Text("Continue")
                        .frame(width: 200 , height: 50, alignment: .center)
                        //You need to change height & width as per your requirement
                 
            }.background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(5)
           

            .buttonStyle(PlainButtonStyle())
        }
    }
    
    func animate() {
        withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)
                   .speed(0.3)) {
                rotationAngle = 450.0
           }
    }
}


#Preview {
    NavigationView {
        WelcomeView(callback: {})
    }
}
