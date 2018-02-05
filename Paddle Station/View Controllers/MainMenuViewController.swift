//
//  MainMenuViewController.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2017-12-01.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import UIKit





class MainMenuViewController: BaseViewController
{
	@IBAction fileprivate func landmarkViewControllerTypeButtonClicked(_ sender: Any)
	{
		// TODO: Add child VC with animation FLIP HORIZONTAL
	}
	
	@IBAction fileprivate func openMapView(_ sender: Any)
	{
		let segueIdentifier = R.segue.mainMenuViewController.landmarkMapViewController.identifier
		self.segueManager.performSegue(withIdentifier: segueIdentifier) { (destination: LandmarkMapViewController) in
			
		}
	}
	
	@IBAction fileprivate func openARView(_ sender: Any)
	{
//		self.transition(from: <#T##UIViewController#>,
//						to: <#T##UIViewController#>,
//						duration: <#T##TimeInterval#>,
//						options: UIViewAnimationOptions.flip,
//						animations: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>,
//						completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
		
		
		let segueIdentifier = R.segue.mainMenuViewController.landmarkARViewController.identifier
		self.segueManager.performSegue(withIdentifier: segueIdentifier) { (destination: LandmarkARViewController) in
			
		}
	}
}




