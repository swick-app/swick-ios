//
//  AddTipView.swift
//  Customer
//
//  Created by Andrew Jiang on 10/20/20.
//

import SwiftUI

struct AddTipView: View {
    // Initial
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isWaiting = false
    // Alerts
    @State var showAlert = false
    @State var alertMessage = ""
    @State var showCustomTip = false
    // Properties
    @State var attemptTip = false
    @State var paramsWrapper: PaymentParamsWrapper?
    @State var tipState: TipState = .low
    @State var tipAmount = ""
    @Binding var order: Order
    var subtotal: Decimal
    var restaurantId: Int
    
    func getTip() -> Decimal {
        // if non-zero custom tip
        if tipState == .custom {
            return Decimal(string: tipAmount) ?? 0
        }
        let tip = Decimal(tipState.percent!) / 100 * subtotal
        return Helper.roundDecimal(tip)
    }
    
    func handleResponse(successful: Bool, message: String) {
        if successful {
            presentationMode.wrappedValue.dismiss()
        }
        else {
            attemptTip = false
            alertMessage = message
            showAlert = true
        }
        isWaiting = false
    }
    
    var body: some View {
        NavigationView {
            VStack{
                TipPicker(showCustomTip: $showCustomTip, tipState: $tipState, removeLater: true)
                    .padding()
                SecondaryButton(text: "Send \(Helper.formatPrice(getTip()))") {
                    if getTip() < 0.50 {
                        alertMessage = "Tip must be at least $0.50"
                        showAlert = true
                    }
                    else {
                        paramsWrapper = PaymentParamsWrapper(AddTipParams(restaurantId, order.id, getTip()))
                        isWaiting = true
                        attemptTip = true
                    }
                }
                .padding(.horizontal)
                Spacer()
                // Wrapper view around payment caller view controller
                PaymentCaller(attempt: $attemptTip, paramsWrapper: $paramsWrapper, onStripeResponse: handleResponse)
                    .frame(width: 0, height: 0)
            }
            .navigationBarTitle("Add tip")
            .waitingView($isWaiting)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage))
            }
            .textFieldAlert(
                isShowing: $showCustomTip,
                text: $tipAmount,
                title: "Set tip",
                placeholder: "0",
                keyboardType: .decimalPad,
                isPrice: true
            )
        }
    }
}

struct AddTipView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddTipView(order: .constant(testOrder1), subtotal: Decimal(1), restaurantId: 1)
    }
}
