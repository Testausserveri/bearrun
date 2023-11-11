//
//  NameEnterView.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation
import SwiftUI

struct NameEnterView: View {
    @State private var rotationAngle: Double = -100
    @State private var nameField = ""
    @State private var codeField = ""
    @State private var phoneField = ""
    @State private var loading = false
    @State private var error = ""
    @State private var showError = false
    var callback: () -> ()
    
    var body: some View {
        Form {
            Section {
                TextField(.init("Misha Medovovich"), text: $nameField, prompt: Text("Misha Medovovich"))
                TextField(.init("Invite code"), text: $codeField, prompt: Text("Invite code"))
                TextField(.init("+3584xxxxxxxxx"), text: $phoneField, prompt: Text("+3584xxxxxxxxx")).keyboardType(.phonePad)
                if !loading {
                    Button("Continue") {
                        loading = true
                        handleRegister()
                    }
                } else {
                    ProgressView()
                }
                
            }

        }.navigationTitle(Text("Enter your name")).alert(isPresented: $showError) {
            Alert(title: Text("An error occurred"), message: Text(error), dismissButton: .default(Text("Got it!")))
        }
    }
    
    func animate() {
        withAnimation(.interpolatingSpring(duration: 0.5)
                   .speed(0.3)) {
                       rotationAngle = 450.0
           }
    }
    
    func handleRegister() {
        APIClient.register(name: nameField, invite: codeField, phone: phoneField, { result in
            switch(result) {
            case let .register(reg):
                loading = false
                let defaults = UserDefaults.standard
                defaults.set(reg.hue_deg, forKey: "hue")
                defaults.set(reg.my_invite_code, forKey: "invite")
                defaults.set(reg.uid, forKey: "uid")
                print(reg)
                callback()
            case let .error(err):
                loading = false
                showError = true
                error = err.localizedDescription
            }
        })
    }
}


#Preview {
    NavigationView {
        NameEnterView(callback: {})
    }
}
