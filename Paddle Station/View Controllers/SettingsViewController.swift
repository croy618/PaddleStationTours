//
//  SettingsViewController.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-03-20.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import UIKit
import StoreKit





class SettingsViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
	
	@IBOutlet weak var lblAd: UILabel!
	@IBOutlet weak var lblCoinAmount: UILabel!
	
	@IBOutlet weak var outRemoveAds: UIButton!
	@IBOutlet weak var outAddCoins: UIButton!
	@IBOutlet weak var outRestorePurchases: UIButton!
	
	var coins = 50
	
	override func viewDidLoad() {
		super.viewDidLoad()
		outRemoveAds.isEnabled = false
		outAddCoins.isEnabled = false
		outRestorePurchases.isEnabled = false
		
		
		if(SKPaymentQueue.canMakePayments()) {
			print("IAP is enabled, loading")
			let productID: NSSet = NSSet(objects: "addCoins", "removeAds")
			let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
			request.delegate = self
			request.start()
		} else {
			print("please enable IAPS")
		}
	}
	
	
	
	
	@IBAction func btnRemoveAds(_ sender: Any) {
		print("rem ads")
		for product in list {
			let prodID = product.productIdentifier
			if(prodID == "removeAds") {
				p = product
				buyProduct()
			}
		}
	}
	
	
	@IBAction func btnAddCoins(_ sender: Any) {
		print("add coins")
		for product in list {
			let prodID = product.productIdentifier
			if(prodID == "addCoins") {
				p = product
				buyProduct()
				
				
			}
			
		}
		
	}
	
	// 4
	func removeAdss() {
		lblAd.removeFromSuperview()
	}
	
	// 5
	func addCoinss() {
		coins += 50
		lblCoinAmount.text = "\(coins)"
	}
	
	
	@IBAction func btnRestorePurchases(_ sender: Any) {
		SKPaymentQueue.default().add(self)
		SKPaymentQueue.default().restoreCompletedTransactions()
		
	}
	
	
	
	//1
	var list = [SKProduct]()
	var p = SKProduct()
	
	//2
	func buyProduct() {
		print("buy " + p.productIdentifier)
		let pay = SKPayment(product: p)
		SKPaymentQueue.default().add(self)
		SKPaymentQueue.default().add(pay as SKPayment)
	}
	
	//3
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		print("product request")
		let myProduct = response.products
		for product in myProduct {
			print("product added")
			print(product.productIdentifier)
			print(product.localizedTitle)
			print(product.localizedDescription)
			print(product.price)
			
			list.append(product)
		}
		
		outRemoveAds.isEnabled = true
		outAddCoins.isEnabled = true
		outRestorePurchases.isEnabled = true
	}
	
	//4
	
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		print("transactions restored")
		for transaction in queue.transactions {
			let t: SKPaymentTransaction = transaction
			let prodID = t.payment.productIdentifier as String
			
			switch prodID {
			case "removeAds":
				print("remove ads")
				removeAdss()
			case "addCCoins":
				print("add coins to account")
				addCoinss()
			default:
				print("IAP not found")
			}
		}
	}
	
	// 5
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("add payment")
		
		for transaction: AnyObject in transactions {
			let trans = transaction as! SKPaymentTransaction
			print(trans.error as Any)
			
			switch trans.transactionState {
			case .purchased:
				print("buy ok, unlock IAP HERE")
				print(p.productIdentifier)
				
				let prodID = p.productIdentifier
				switch prodID {
				case "removeAds":
					print("remove ads")
					removeAdss()
				case "addCoins":
					print("add coins to asccount")
					addCoinss()
				default:
					print("IAP not found")
				}
				queue.finishTransaction(trans)
			case .failed:
				print("buy error")
				queue.finishTransaction(trans)
				break
			default:
				print("Default")
				break
			}
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}


