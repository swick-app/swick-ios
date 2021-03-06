//
//  TextFieldAlert.swift
//  Customer
//
//  Created by Andrew Jiang on 10/16/20.
//

import SwiftUI

struct TextFieldAlert<Presenting>: View where Presenting: View {
    // Properties
    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let keyboardType: UIKeyboardType
    let placeholder: String
    let isPrice: Bool
    
    init(
        isShowing: Binding<Bool>,
        text: Binding<String>,
        presenting: Presenting,
        title: String,
        placeholder: String = "",
        keyboardType: UIKeyboardType,
        isPrice: Bool = true
    ) {
        self._isShowing = isShowing
        self._text = text
        self.presenting = presenting
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isPrice = isPrice
    }
    
    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                Rectangle()
                    .fill(Color.black)
                    .opacity(0.7)
                    .if(!isShowing) {
                        $0.hidden()
                    }
                VStack {
                    Text(self.title)
                        .padding(.vertical, 20)
                    HStack {
                        if isShowing {
                            if isPrice {
                                Text("$")
                            }
                            UIKitTextField("0", text: self.$text)
                                .keyboardType(.decimalPad)
                        }
                    }
                    .animation(nil)
                    .frame(width: deviceSize.size.width*0.4)
                    .padding(.horizontal)
                    HStack {
                        RowButton(text: "Ok", action: {
                            self.isShowing.toggle()
                        })
                    }
                }
                .background(Color(UIColor.systemGray5))
                .cornerRadius(5.0)
                .frame(
                    width: deviceSize.size.width * 0.4,
                    height: deviceSize.size.height * 0.2,
                    alignment: .center
                )
                .shadow(radius: 1)
                .animation(.easeInOut(duration: 0.20))
                .position(x: deviceSize.size.width / 2, y: deviceSize.size.height * 0.4)
                .if(!isShowing) {
                    $0.hidden()
                }
            }
        }
    }
}

extension View {
    // Show alert with text input
    func textFieldAlert(
        isShowing: Binding<Bool>,
        text: Binding<String>,
        title: String,
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default,
        isPrice: Bool = false
    ) -> some View {
        TextFieldAlert(
            isShowing: isShowing,
            text: text,
            presenting: self,
            title: title,
            placeholder: placeholder,
            keyboardType: keyboardType,
            isPrice: isPrice
        )
    }
}
