//
//  ContentView.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 10.11.2023.
//

import SwiftUI
import Model3DView

struct ContentView: View {
    @State private var showWelcome = false
    @State private var error = ""
    @State private var time = "..."
    @State private var streak: Int = 0
    @State private var shareCode = "NOC0DE"
    @State private var showError = false
    @State private var showPerms = false
    @State private var showFriends = false
    @State private var stepsDone: Int = 0
    @State private var hue: Int = 0
    @State private var friendMultipiler = 0
    @State private var friends: [User] = []
    @State private var rotationAngle: Double = 90
    @State private var transition: Double = 400

    static let goal = 10000
    
    
    var body: some View {
        NavigationView {
            if streak == -1 {
                ZStack {
                    VStack {
                        //GAME OVER IT’S TOO LATE NO...
                        Text("GAME OVER\n").font(.custom("Poppins Bold", size: 36)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).tracking(0.37)
                        Text("IT’S TOO LATE NOW.\nYOU’RE DEAD.").font(.custom("Poppins Regular", size: 36)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).tracking(0.37).multilineTextAlignment(.center)
                        
                    }.zIndex(10)
                    Image(uiImage: #imageLiteral(resourceName: "Nallekarhu1"))
                        .resizable()
                        .scaledToFill()
                        .frame(minHeight: 0, maxHeight: .infinity)
                        .offset(x: -15, y: 30)
                        .scaleEffect(CGSize(width: 2.5, height: 3)).onAppear(perform: initApp).alert(isPresented: $showError) {
                            Alert(title: Text("An error occurred"), message: Text(error), dismissButton: .default(Text("Got it!")))
                        }.alert(isPresented: $showPerms) {
                            Alert(title: Text("No Health Permissions"), message: Text("We cannot count your physical activity without Health data. Please accept and try again"), dismissButton: .default(Text("Got it!")))
                        }
                }.animation(.interactiveSpring)
            } else {
                VStack() {
                    if streak > 0 {
                        Text(streak != -1 ? "🔥" : "💀").font(.custom("Poppins Bold", size: 81)).tracking(0.37).multilineTextAlignment(.center).padding([.leading, .trailing], 25)
                        //1337
                        //1337
                        if streak != -1 {
                            Text(String(streak)).font(.custom("Poppins Bold", size: 36)).tracking(0.37).multilineTextAlignment(.center).padding([.leading, .trailing], 25)
                        }
                    }
                    //You have 5 hours to move 4...
                    //You have 5 hours to move 4...
                    if stepsDone >= ContentView.goal {
                        Text("You've done \(stepsDone) steps, good job!").font(.custom("Poppins Regular", size: 36)).tracking(0.37).multilineTextAlignment(.center).padding([.leading, .trailing], 25)
                    } else {
                        Text("You have \(time) to move \(ContentView.goal-stepsDone) steps until I EAT YOU.").font(.custom("Poppins Regular", size: 36)).tracking(0.37).multilineTextAlignment(.center).padding([.leading, .trailing], 25)
                    }

                    
                    Spacer()
                    
                    //Nallekarhu

                    ZStack(alignment: .bottom) {
                            
                        if friendMultipiler > 0 {
                            //FRIENDS MULTIPLIER
                            Text("FRIENDS MULTIPLIER").font(.custom("Poppins Medium", size: 12)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center).zIndex(10).frame(minWidth: 0, maxWidth: .infinity).padding([.bottom], 10).padding([.trailing], stepsDone >= ContentView.goal ? 10: -20)
                            
                            //3x
                            Text("\(friendMultipiler)x").font(.custom("Poppins Bold", size: 36)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).tracking(0.37).multilineTextAlignment(.center).zIndex(10).frame(minWidth: 0, maxWidth: .infinity).padding([.bottom], 18).padding([.trailing], stepsDone >= ContentView.goal ? 10 : -20)
                        }

                            
                            //Nallekarhu
                        Image(uiImage: #imageLiteral(resourceName: (stepsDone >= ContentView.goal ? "Nallekarhu3" : "Nallekarhu1")))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 409, height: 350)
                                .offset(y: 50)
                                .clipped()
                                .frame(width: 409, height: 250)
                    
                        
                        
                    }.ignoresSafeArea(.all).offset(y: transition)
                }.padding().frame(minHeight: 0, maxHeight: .infinity, alignment: .top).sheet(isPresented: $showWelcome) {
                    NavigationView {
                        WelcomeView(callback: {
                            showWelcome = false
                            checkSession()
                        })
                    }.interactiveDismissDisabled()
                }.onAppear(perform: initApp).alert(isPresented: $showError) {
                    Alert(title: Text("An error occurred"), message: Text(error), dismissButton: .default(Text("Got it!")))
                }.alert(isPresented: $showPerms) {
                    Alert(title: Text("No Health Permissions"), message: Text("We cannot count your physical activity without Health data. Please accept and try again"), dismissButton: .default(Text("Got it!")))
                }.toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination:                   LeaderboardView(friends: $friends, shareCode: $shareCode, youDeg: $hue, streak: $streak)) {
                            HStack {
                                Image(systemName: "person.2").resizable().scaledToFit().frame(height: 18)
                                Text("Friends")
                            }.padding([.leading, .trailing], 4).alignmentGuide(HorizontalAlignment.center, computeValue: { d in
                                d[HorizontalAlignment.center]
                              })

                        }.padding(4).multilineTextAlignment(.center)
                            .background(Color(red: 44/255, green: 44/255, blue: 46/255)).foregroundColor(.white).clipShape(Capsule())
                        
                    }
                   
                }
            }
        }
       
    }
    
    func initApp() {
        checkSession()
        withAnimation(.interpolatingSpring(duration: 0.5)) {
            transition = 0
        }
    }
    
    func animate() {
        withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)
                   .speed(0.3)) {
                rotationAngle = 450.0
           }
    }
    
    func updateSteps() {
        let defaults = UserDefaults.standard
        HealthKitUtil.getHealthKitPermission({(result, err) in
            if (!result) {
                if let err = err {
                    error = err.localizedDescription
                    showError = true
                    return
                }
                showPerms = true
                return
            }
            HealthKitUtil.getTodaySteps({steps in
                print(steps)
                stepsDone = Int(steps)
                if let uid = defaults.string(forKey: "uid") {
                    APIClient.sendSteps(name: uid, steps: steps, {resp in
                        switch (resp) {
                        case let .update(resp):
                            print(resp)
                        case let .error(err):
                            error = err.localizedDescription
                            showError = true
                        }
                    })

                }
            })
        })
    }
    
    func checkSession() {
        updateSteps()
        let defaults = UserDefaults.standard
        if let uid = defaults.string(forKey: "uid") {
            APIClient.me(username: uid, {resp in
                switch (resp) {
                case let .me(me):
                    print(me)
                    shareCode = me.my_invite_code
                    friends = me.invited_users
                    hue = me.hue_deg
                    withAnimation {
                        time = me.time_remaining
                        streak = me.streak
                        friendMultipiler = me.invited_users.count
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                        checkSession()
                    })
                case let .error(err):
                    error = err.localizedDescription
                    showError = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                        checkSession()
                    })
                }
                
            })
        } else {
            showWelcome = true
        }
    }
}

#Preview {
    ContentView()
}
