//
//  CheckFrontRequests.swift
//  PaddleStationApp
//
//  Created by Aaron Groeneveld on 2017-11-30.
//  Copyright © 2017 PaddleStation. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


////Some test code

//var request = CheckFrontRequest()


////Made Synchronous
//request.getAvailability(date: "20180610", item: "29", numOfPeople: "2", startTime: "1230"){ (available) in print(available) }
//request.getSLIP(date: "20180610", item: "29", numOfPeople: "2", startTime: "1230"){ (slip) in print(slip) }
//request.startSession(slip: "29.20180610X1@12:30X180X180-qty.2"){ (session) in print(session) }
//request.getTOS(){ (policy) in print(policy) }
//request.createBooking(session: "s1fg8tff2j9t5jcedfboe2j0b1", custName: "Aaron Test", custEmail: "TestEmail@test.com", custPhone: "555-555-5555", custAddress: "123 Fake Lane", custCity: "Calgary", custCountry: "CA", custPostalCode: "TTTTTT", quantity: "2", emailOptIn: "1", agreeTOS: "1"){(bookingID) in print(bookingID) }
//


class CheckFrontRequest {
    

    func getAvailability(date: String, item: String, numOfPeople: String, startTime: String, completion: @escaping (Int) -> Void) {
        
        let url = "https://thepaddlestation.checkfront.com/api/3.0/item?date="+date+"&start_time="+startTime+"&item_id="+item+"&param[qty]="+numOfPeople;
        var json = JSON()
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                json = JSON(value)
                if (json["items"][item]["rate"]["available"].exists()){
                    let available = json["items"][item]["rate"]["available"].int!
                    completion(available)
                }
                else{completion(0)}
                
            case .failure(let error):
                print(error)
                completion(-1)
            }
            
        }
        // return available
    }

    func getSLIP(date: String, item: String, numOfPeople: String, startTime: String, completion: @escaping (String) -> Void) {
        
        let url = "https://thepaddlestation.checkfront.com/api/3.0/item?date="+date+"&start_time="+startTime+"&item_id="+item+"&param[qty]="+numOfPeople;
        var json = JSON()
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                json = JSON(value)
                let slip = json["items"][item]["rate"]["slip"].string!
                print("1: " + slip)
                completion(slip)
            case .failure(let error):
                print(error)
                completion("error")
            }
            
        }
        // return available
    }
    
    func startSession(slip: String, completion: @escaping (String) -> Void) {
        
        let url = "https://thepaddlestation.checkfront.com/api/3.0/booking/session?"+slip;
        var json = JSON()
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                json = JSON(value)
                let session = json["booking"]["session"]["id"].string!
                completion(session)
            case .failure(let error):
                print(error)
                completion("error")
            }
            
        }
        // return available
    }
    
    func getTOS( completion: @escaping (String) -> Void) {
        
        let url = "https://thepaddlestation.checkfront.com/api/3.0/booking/form"
        var json = JSON()
        
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                json = JSON(value)
                let policy = json["booking_policy"]["body"].string!
                completion(policy)
            case .failure(let error):
                print(error)
                completion("error")
            }
            
        }
        // return available
    }
    
    func createBooking( session: String, custName: String, custEmail:String, custPhone: String, custAddress: String, custCity: String, custCountry: String, custPostalCode: String, quantity: String, emailOptIn: String, agreeTOS: String, completion: @escaping (String) -> Void) {
        
        let url = "https://thepaddlestation.checkfront.com/api/3.0/booking/create"
        var json = JSON()
        Alamofire.request(url, method: .post, parameters: ["session_id": session, "form[customer_name]": custName,"form[customer_email]":custEmail,"form[customer_phone]":custPhone,"form[customer_address]":custAddress,"form[customer_city]":custCity,"form[customer_country]":custCountry,"form[customer_postal_zip]":custPostalCode,"form[00]":quantity,"form[customer_email_optin]":emailOptIn,"form[customer_tos_agree]":agreeTOS]).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                json = JSON(value)
                let bookingID = json["booking"]["id"].string!
                completion(bookingID)
            case .failure(let error):
                print(error)
                completion("error")
            }
            
        }
        // return available
    }
    
    

}



