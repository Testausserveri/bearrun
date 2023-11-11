//
//  LeaderboardView.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation
import SwiftUI

struct LeaderboardView: View {
    
    @Binding var friends: [User]
    @Binding var shareCode: String
    @Binding var youDeg: Int
    @Binding var streak: Int
    @State private var rotationAngle: Double = 0
    @State private var showError = false
    @State private var error = ""

    
    var body: some View  {
        if friends.isEmpty {
            Form {
                VStack(spacing: 9) {
                    Text("No friends yet").font(.title)
                    Image(uiImage: #imageLiteral(resourceName: "Nallekarhu2"))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .hueRotation(Angle(degrees: rotationAngle))
                        .frame(width: 102, height: 102)
                        .rotationEffect(.degrees(40))
                        .offset(x: -20, y: 20)
                        .clipped()
                        .frame(width: 99, height: 99)
                        .background(Color(UIColor.systemGray5))
                        .clipShape(Circle()).onAppear(perform: animate)
                    Text("Share your invite code with friends, and join on the mission together! Each invited friend multiplies your XP.").font(.headline)
                    InviteCodeBox(code: shareCode).padding([.top], 5)
                }.padding().alert(isPresented: $showError) {
                    Alert(title: Text("An error occurred"), message: Text(error), dismissButton: .default(Text("OK")))
                }
            }.refreshable {
                updateFriends()
            }
        } else {
            HStack {
                Text("Invite your friends to join our mission, and boost your progress!").font(.headline).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                InviteCodeBox(code: shareCode)
            }.padding().frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            List {
                Section {
                    UserBox(user: User(hue_deg: youDeg, bear_name: "You", streak: streak))
                }
                ForEach(friends.sorted {$0.streak > $01.streak}) { friend in
                    UserBox(user: friend)
                }
                
            }.navigationTitle(Text("Friends")).alert(isPresented: $showError) {
                Alert(title: Text("An error occurred"), message: Text(error), dismissButton: .default(Text("Got it!")))
            }.refreshable {
                try? await updateFriendsAsync()
            }
        }
    }
    
    func updateFriendsAsync() async throws -> Void {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                do {
                    let defaults = UserDefaults.standard
                    if let uid = defaults.string(forKey: "uid") {
                        APIClient.me(username: uid, {resp in
                            switch (resp) {
                            case let .me(me):
                                print(me)
                                withAnimation {
                                    shareCode = me.my_invite_code
                                    friends = me.invited_users
                                }
                                continuation.resume()
                            case let .error(err):
                                error = err.localizedDescription
                                showError = true
                                continuation.resume(throwing: err)
                            }
                            
                        })
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func updateFriends() {
        let defaults = UserDefaults.standard
        if let uid = defaults.string(forKey: "uid") {
            APIClient.me(username: uid, {resp in
                switch (resp) {
                case let .me(me):
                    print(me)
                    withAnimation {
                        shareCode = me.my_invite_code
                        friends = me.invited_users
                    }
                case let .error(err):
                    error = err.localizedDescription
                    showError = true
                }
                
            })
        }
    }
    
    func animate() {
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)
                   .speed(0.3)) {
                rotationAngle = 360
           }
    }
}

#Preview {
    LeaderboardView(friends: .constant([]), shareCode: .constant("MsdKss"), youDeg: .constant(0), streak: .constant(0))
}
