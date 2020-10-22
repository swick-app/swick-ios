//
//  Constants.swift
//  Swick
//
//  Created by Sean Lu on 10/7/20.
//

import SwiftUI

// Set true for development environment, false for production environment
let DEVELOPMENT = true

let BACKEND_URL = DEVELOPMENT ? "http://localhost:8000" : "https://swickapp.herokuapp.com"

let PRIMARY_COLOR = Color("Red")
let PRIMARY_UI_COLOR = UIColor(red: 230/255, green: 57/255, blue: 70/255, alpha: 1)

#if CUSTOMER
// Mock scanned string for QR code scanner while using simulator
let MOCK_SCANNED_STRING = "swick-26-1"

let STRIPE_PUBLIC_KEY = "pk_test_YoEmowu4ykyrOgUO8dfmShpQ00ck79Hp8Q"
#endif