//
//  BookKayaksViewController.swift
//  PaddleStationApp
//
//  Created by Jamie Mills on 2017-12-05.
//  Copyright © 2017 PaddleStation. All rights reserved.
//

import UIKit

class BookKayaksViewController: UIViewController {
    var bookingDetails: Booking!
    var bookingID: String = ""
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtPostalCode: UITextField!
    @IBOutlet weak var swtTOS: UISwitch!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishedBookingTouched(_ sender: UIButton) {
        let custName = txtName.text ?? ""
        let custEmail = txtEmail.text ?? ""
        let custPhone = txtPhone.text ?? ""
        let custAddress = txtAddress.text ?? ""
        let custCity = txtCity.text ?? ""
        let custCountry = txtCountry.text ?? ""
        let custPostalCode = txtPostalCode.text ?? ""
        let custTOS = swtTOS.isOn
        
        let canProceed = (custName != "") && (custEmail != "") && (custPhone != "") && (custAddress != "") && (custCity != "") && (custCountry != "") && (custPostalCode != "") && (custTOS != false)
        
        if canProceed == false {
            //TODO message or gray out button or something
            return
        } else {
            bookingDetails.custName = custName
            bookingDetails.custEmail = custEmail
            bookingDetails.custPhone = custPhone
            bookingDetails.custAddress = custAddress
            bookingDetails.custCity = custCity
            bookingDetails.custCountry = custCountry
            bookingDetails.custPostalCode = custName
            bookingDetails.agreeTOS = custTOS
            
            bookingID = bookingDetails.finishBooking()
            
            //let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "StripeViewController") as! StripeViewController
            let stripeViewController = StripeViewController(product: "Kayak",
                                                                price: 10000)
            self.navigationController?.pushViewController(stripeViewController, animated: true)
            
            //performSegue(withIdentifier: "backToHomeAfterBook", sender: view)
        }
    }
    
    /*
    @IBAction func finishBookingTouched(_ sender: UIButton!) {
        let custName = txtName.text ?? ""
        let custEmail = txtEmail.text ?? ""
        let custPhone = txtPhone.text ?? ""
        let custAddress = txtAddress.text ?? ""
        let custCity = txtCity.text ?? ""
        let custCountry = txtCountry.text ?? ""
        let custPostalCode = txtPostalCode.text ?? ""
        let custTOS = swtTOS.isOn
        
        let canProceed = (custName != "") && (custEmail != "") && (custPhone != "") && (custAddress != "") && (custCity != "") && (custCountry != "") && (custPostalCode != "") && (custTOS != false)
        
        if canProceed == false {
            //TODO message or gray out button or something
            return
        } else {
            bookingDetails.custName = custName
            bookingDetails.custEmail = custEmail
            bookingDetails.custPhone = custPhone
            bookingDetails.custAddress = custAddress
            bookingDetails.custCity = custCity
            bookingDetails.custCountry = custCountry
            bookingDetails.custPostalCode = custName
            bookingDetails.agreeTOS = custTOS
            
            bookingID = bookingDetails.finishBooking()
            
            //performSegue(withIdentifier: "backToHomeAfterBook", sender: view)
        }
    }
    */
    
    //MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        
        
//   }
    

}
