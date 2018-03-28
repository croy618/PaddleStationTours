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
	enum LandmarkViewControllerState: String
	{
		case Map
		case AR
		
		var previous: LandmarkViewControllerState {
			switch self {
			case .Map:		return .AR
			case .AR: 		return .Map
			}
		}
		
		var next: LandmarkViewControllerState {
			switch self {
			case .Map:		return .AR
			case .AR: 		return .Map
			}
		}
	}
	
	
	
	
	
	fileprivate var landmarkViewControllerState: LandmarkViewControllerState!
	
	@IBOutlet fileprivate var landmarkViewControllerToggleButton: UIButton!
	fileprivate var landmarkMapViewController: LandmarkMapViewController!
	fileprivate var landmarkARViewController: LandmarkARViewController!
	
	@IBOutlet fileprivate var settingsButton: UIButton!
	@IBOutlet fileprivate var adContainerView: UIView!
	
	
	
	
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		if self.landmarkViewControllerState == nil {
			self.transitionTo(state: LandmarkViewControllerState.Map, animated: false)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		super.prepare(for: segue, sender: sender)
		
		if segue.identifier == R.segue.mainMenuViewController.landmarkMapViewController.identifier {
			self.landmarkMapViewController = segue.destination as! LandmarkMapViewController
		} else if segue.identifier == R.segue.mainMenuViewController.landmarkARViewController.identifier {
			self.landmarkARViewController = segue.destination as! LandmarkARViewController
		} else if segue.identifier == R.segue.mainMenuViewController.settingsViewController.identifier {
			let popoverController = segue.destination.popoverPresentationController
			popoverController?.delegate = self
			popoverController?.sourceView = self.settingsButton
			popoverController?.sourceRect = self.settingsButton.bounds
		}
	}
	
	@IBAction fileprivate func landmarkViewControllerToggleButtonClicked(_ sender: UIButton)
	{
		sender.isUserInteractionEnabled = false
		self.transitionTo(state: self.landmarkViewControllerState.next, animated: true, completion: { _ in
			sender.isUserInteractionEnabled = true
		})
	}
	
	@IBAction func settingsButtonClicked(_ sender: UIButton)
	{
		let segueIdentifier = R.segue.mainMenuViewController.settingsViewController.identifier
		self.segueManager.performSegue(withIdentifier: segueIdentifier) { (destination: SettingsViewController) in
			
		}
	}
}





fileprivate extension MainMenuViewController
{
	// TODO: dont have 2 children, create and layout each transition
	fileprivate func transitionTo(state: LandmarkViewControllerState, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil)
	{
		guard self.landmarkViewControllerState != state else {
			completion?(false)
			return
		}
		
		self.landmarkViewControllerState = state
		
		var fromViewController: LandmarkViewController!
		var toViewController: LandmarkViewController!
		let duration = (animated) ? 0.5 : 0.0
		var options: UIViewAnimationOptions!
		
		switch self.landmarkViewControllerState! {
		case LandmarkViewControllerState.Map:
			fromViewController = self.landmarkARViewController
			toViewController = self.landmarkMapViewController
			options = UIViewAnimationOptions.transitionFlipFromLeft
			break
		case LandmarkViewControllerState.AR:
			fromViewController = self.landmarkMapViewController
			toViewController = self.landmarkARViewController
			options = UIViewAnimationOptions.transitionFlipFromRight
			break
		}
		
		self.view.bringSubview(toFront: fromViewController.view)
		self.view.bringSubview(toFront: self.landmarkViewControllerToggleButton)
		fromViewController.view.isHidden = false
		toViewController.view.isHidden = false
		
		
		UIView.transition(with: self.landmarkViewControllerToggleButton,
						  duration: duration,
						  options: options,
						  animations: {
							self.landmarkViewControllerToggleButton.setTitle(self.landmarkViewControllerState.previous.rawValue,
																			 for: UIControlState.normal)
		}, completion: nil)
		
		UIView.transition(from: fromViewController.view,
						  to: toViewController.view,
						  duration: duration,
						  options: options) { finished in
							
							fromViewController.viewWillDisappear(animated)
							fromViewController.view.isHidden = true
							fromViewController.viewDidDisappear(animated)
							
							toViewController.viewWillAppear(animated)
							toViewController.view.isHidden = false
							toViewController.viewDidAppear(animated)
							
							completion?(finished)
		}
	}
}





extension MainMenuViewController: UIPopoverPresentationControllerDelegate
{
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
	{
		return UIModalPresentationStyle.none
	}
}




