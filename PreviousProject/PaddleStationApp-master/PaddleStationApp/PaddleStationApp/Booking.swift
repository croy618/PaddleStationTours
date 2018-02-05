//
//  Booking.swift
//  PaddleStationApp
//
//  Created by Jamie Mills on 2017-12-04.
//  Copyright © 2017 PaddleStation. All rights reserved.
//

import Foundation

class Booking {
    
    var window: UIWindow?
    
    var date: String
    var item: String
    var itemID: String
    var numOfPeople: String
    var startTime: String
    var slip: String
    var session: String
    var custName: String
    var custEmail: String
    var custPhone: String
    var custAddress: String
    var custCity: String
    var custCountry: String
    var custPostalCode: String
    var emailOptIn: String
    var agreeTOS: Bool
    var bookingID: String
    
    func setSlip(_ slip: String) {
        print(slip)
        self.slip = slip
    }
    
    func setSession(_ session: String) {
        print(session)
        self.session = session
    }
    
    func setBookingID(_ bookingID: String) {
        print(bookingID)
        self.bookingID = bookingID
    }
    
    init(date: String, time: String, item: String, numOfPeople: String) {
        self.date = date
        self.startTime = time
        self.item = item
        
        if (item == "Kayak") {
            self.itemID = "29"
        } else {
            self.itemID = "29"
        }
        
        self.numOfPeople = numOfPeople

        slip = ""
        session = ""
        custName = ""
        custEmail = ""
        custPhone = ""
        custAddress = ""
        custCity = ""
        custCountry  = ""
        custPostalCode = ""
        emailOptIn = "false"
        agreeTOS = false
        bookingID = ""
    }
    
    func finishBooking() -> String {
        let request = CheckFrontRequest()
        
        let canProceed = (date != "") && (item != "") && (itemID != "") && (numOfPeople != "") && (startTime != "") && (custName != "") && (custEmail != "") && (custPhone != "") && (custAddress != "") && (custCity != "") && (custCountry != "") && (custPostalCode != "") && (agreeTOS != false)
        
        if canProceed {
            //This part is how production code would work, but we don't want to create real bookings
            
            //request.getSLIP(date: date, item: itemID, numOfPeople: numOfPeople, startTime: startTime) {(slip) in self.setSlip(slip)}
            //print("2: " + self.slip)
            
            //request.startSession(slip: self.slip) {(session) in self.setSession(session)}
            //stripe.start!!!
            
            
            
//            let rootVC = StripeViewController(product: "Kayak", price: 10000)
//            let navigationController = UINavigationController(rootViewController: rootVC)
//            let window = UIWindow(frame: UIScreen.main.bounds)
//            window.rootViewController = navigationController;
//            window.makeKeyAndVisible()
//            self.window = window
            
            //request.createBooking(session: "s1fg8tff2j9t5jcedfboe2j0b1", custName: custName, custEmail: custEmail, custPhone: custPhone, custAddress: custAddress, custCity: custCity, custCountry: custCountry, custPostalCode: custPostalCode, quantity: numOfPeople, emailOptIn: emailOptIn, agreeTOS: "1") {(bookingID) in self.setBookingID(bookingID)}
            
            return bookingID
        } else {
            return "booking failed!"
        }
    }
}
