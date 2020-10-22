//
//  CartView.swift
//  Swick
//
//  Created by Sean Lu on 10/8/20.
//

import SwiftUI


struct CartView: View {
    
    // Initial
    @EnvironmentObject var user: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var viewDidLoad = false
    @Binding var tabIndex: Int
    // Popups
    @State var showRequestActionSheet = false
    @State var showMenu = false
    @State var showPaymentMethods = false
    // Alerts
    enum AlertState { case success, error, leave }
    @State var alertState = AlertState.error
    @State var showAlert = false
    @State var alertMessage = ""
    @State var showCustomTip = false
    // Properties
    @State var requestOptions = [RequestOption]()
    @State var card: Card? = nil
    @State var attemptOrder = false
    @State var paramsWrapper: PaymentParamsWrapper?
    @State var tipAmount = ""
    @State var tipState: TipState = .later
    var restaurant: Restaurant
    var table: Int
    
    func loadRequestOptions() {
        if !viewDidLoad {
            viewDidLoad = true
            API.getRequestOptions(restaurant.id) { json in
                if (json["status"] == "success") {
                    self.requestOptions = []
                    let optionJsonList = json["request_options"].array ?? []
                    for optionJson in optionJsonList {
                        self.requestOptions.append(RequestOption(optionJson))
                    }
                }
            }
        }
    }
    
    func createRequestActionSheet() -> ActionSheet {
        let buttons = requestOptions.map { option in
            Alert.Button.default(Text(option.name)) {
                API.makeRequest(option.id, table: table) { json in
                    if (json["status"] == "request_in_progress") {
                        alertMessage = "Request already sent"
                        alertState = .error
                        showAlert = true
                    }
                }
            }
        }
        return ActionSheet(
            title: Text("Request"),
            buttons: buttons + [Alert.Button.cancel()]
        )
    }
    
    func deleteItem(at offsets: IndexSet) {
        user.cart.remove(atOffsets: offsets)
    }
    
    func getSubtotal() -> Decimal {
        var subtotal: Decimal = 0
        for item in user.cart {
            subtotal += item.total
        }
        return subtotal
    }
    
    func getTax() -> Decimal {
        var tax: Decimal = 0
        for item in user.cart {
            tax += item.total * item.meal.tax / 100
        }
        return tax
    }
    
    func getTip() -> Decimal? {
        // if non-zero custom tip
        if tipState == .custom && Decimal(string: tipAmount) != 0 {
            return Decimal(string: tipAmount)
        }
        // if pre-selected tip type
        if tipState != .later && tipState != .custom {
            return Decimal(tipState.percent!) / 100 * getSubtotal()
        }
        // if .later or 0 custom tip value
        return nil
    }
    
    func getTotal() -> Decimal {
        return getSubtotal() + getTax() + (getTip() ?? 0)
    }
    
    func placeOrder() {
        if (getTotal() < 0.50) {
            alertMessage = "Order total must be at least $0.50"
            showAlert = true
        }
        else if let c = card {
            paramsWrapper = PaymentParamsWrapper(PlaceOrderParams(restaurant.id, table, user.cart, getTip(), c.id))
            attemptOrder = true
        }
        else {
            alertMessage = "Please select a card"
            showAlert = true
        }
    }
    
    // Actions to perform after payment attempt
    func handleResponse(successful: Bool, message: String) {
        if successful {
            user.cart.removeAll()
            tipState = .later
            tipAmount = ""
            alertState = .success
        }
        else {
            alertMessage = message
            alertState = .error
        }
        showAlert = true
    }
    
    var body: some View {
        List {
            // Add items to cart button
            RowButton(
                text: "Add items to cart",
                action: {showMenu = true}
            )
            
            // Only show totals and payment if cart is not empty
            if !user.cart.isEmpty {
                // Items list
                ForEach(user.cart) { item in
                    ItemRow(
                        quantity: item.quantity,
                        mealName: item.meal.name,
                        total: item.total,
                        customizations: item.customizations
                    )
                    .padding(.vertical)
                }
                .onDelete(perform: deleteItem)
                // Tip
                VStack {
                    HStack {
                        Text("Add tip ")
                            .font(SFont.body)
                        Spacer()
                    }
                    TipPicker(showCustomTip: $showCustomTip, tipState: $tipState)
                }.padding(.vertical)
                // Totals
                VStack {
                    TotalsView(
                        subtotal: getSubtotal(),
                        tax: getTax(),
                        tip: getTip(),
                        total: getTotal()
                    )
                }
                
                // Either show 'card' or 'select payment' button
                if let selectedCard = card {
                    Button(action: {
                        self.showPaymentMethods.toggle()
                    }) {
                        CardRow(selectedCard)
                    }
                }
                else {
                    // Select payment button
                    RowButton(text: "Select payment method", action: {
                        self.showPaymentMethods.toggle()
                    })
                }
                
                // Place order button
                PrimaryButton(text: "PLACE ORDER", action: placeOrder)
                    .disabled(attemptOrder)
            }
        }
        .navigationBarTitle(Text("Cart"))
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: loadRequestOptions)
        // Request button
        .navigationBarItems(
            leading: Button("Leave restaurant") {
                alertState = .leave
                showAlert = true
            },
            trailing: Button("Request") {
                showRequestActionSheet = true
            }
        )
        // Request action sheet
        .actionSheet(isPresented: $showRequestActionSheet) {
            createRequestActionSheet()
        }
        // Menu popup
        .sheet(isPresented: $showMenu) {
            NavigationView {
                CategoriesView(
                    restaurant: restaurant,
                    cameFromCart: true
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environmentObject(user)
        }
        // Payment methods popup
        .background(
            EmptyView()
                .sheet(isPresented: $showPaymentMethods) {
                    NavigationView {
                        PaymentMethodsView(
                            selectedCard: $card,
                            cameFromCart: true
                        )
                    }
                }
        )
        // Error alert
        .alert(isPresented: $showAlert) {
            switch alertState {
            case .success:
                return Alert(
                    title: Text("Success"),
                    message: Text("Your order has been placed"),
                    dismissButton: Alert.Button.default (
                        Text("Go to orders"), action: { tabIndex = 2}
                    )
                )
            case .error:
                return Alert(
                    title: Text("Error"),
                    message: Text(alertMessage)
                )
                
            case .leave:
                return Alert(
                    title: Text("Leave restaurant?"),
                    message: Text("Your cart will be cleared"),
                    primaryButton: .default(
                        Text("Ok"),
                        action: {
                            user.cart.removeAll()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    ),
                    secondaryButton: .cancel())
            }
        }
        .textFieldAlert(
            isShowing: $showCustomTip,
            text: $tipAmount,
            title: "Set tip",
            placeholder: "0",
            keyboardType: .decimalPad,
            isPrice: true
        )
        // Wrapper view around payment caller view controller
        PaymentCaller(attempt: $attemptOrder, paramsWrapper: $paramsWrapper, onStripeResponse: handleResponse)
            .frame(width: 0, height: 0)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(tabIndex: .constant(1), restaurant: testRestaurant1, table: 1)
            .environmentObject(UserData())
    }
}