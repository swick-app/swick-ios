//
//  WhiteButtonText.swift
//  Swick
//
//  Created by Sean Lu on 10/21/20.
//

import SwiftUI

struct WhiteButtonText: View {
    // Properties
    var text: String
    
    var body: some View {
        Text(text)
            .font(SFont.body)
            .fontWeight(.bold)
            .foregroundColor(SColor.primary)
            .padding(.vertical, 22.5)
            .frame(maxWidth: .infinity)
            .cornerRadius(40)
    }
}

struct WhiteButtonText_Previews: PreviewProvider {
    static var previews: some View {
        WhiteButtonText(text: "GET STARTED")
    }
}
