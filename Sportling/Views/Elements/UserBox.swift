//
//  UserBox.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation
import SwiftUI

struct UserBox: View {
    var user: User
    
    var body: some View {
        HStack(spacing: 4) {
            Image(uiImage: #imageLiteral(resourceName: "Nallekarhu2"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .hueRotation(Angle(degrees: Double(user.hue_deg)))
                .frame(width: 52, height: 52)
                .offset(y: 15)
                .clipped()
                .frame(width: 45, height: 45)
                .background(Color(UIColor.systemGray5))
                .clipShape(Circle())
            Text(user.bear_name).font(.title3).padding([.leading], 7)
            Spacer()
            Text(user.streak == -1 ? "💀" : "🔥 \(user.streak)").font(.headline)
        }.frame(minWidth: 0, maxWidth: .infinity)
    }
}

#Preview {
    UserBox(user: User(hue_deg: 139, bear_name: "Bruh", streak: 4))
}
