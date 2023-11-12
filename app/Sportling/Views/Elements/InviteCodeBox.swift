//
//  InviteCodeBox.swift
//  Sportling
//
//  Created by Ruben Mkrtumyan on 11.11.2023.
//

import Foundation
import SwiftUI

struct InviteCodeBox: View  {
    var code: String
    var body: some View {
        HStack(spacing: 9) {
            Text(code).textSelection(.enabled).font(.bold(.title2)()).padding(9).overlay(
                RoundedRectangle(cornerRadius: 14)
                    .inset(by: 1) // inset value should be same as lineWidth in .stroke
                    .stroke(Color(UIColor.label), lineWidth: 3.5)
            )
            Button(action: {
                UIPasteboard.general.setValue(code, forPasteboardType: "public.plain-text")
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
            }) {
                Image(systemName: "doc.on.doc").resizable().scaledToFit().frame(height: 22)
            }.buttonStyle(PlainButtonStyle())
            

        }

    }
}

#Preview {
 InviteCodeBox(code: "123")
}
