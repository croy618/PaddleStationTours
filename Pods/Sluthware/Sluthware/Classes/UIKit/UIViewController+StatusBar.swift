//
//  UIViewController+StatusBar.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-03.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





public extension UIViewController
{
	var isStatusBarHidden: Bool {
		set
		{
			UIApplication.shared.isStatusBarHidden = newValue
			
			if self.responds(to: #selector(UIViewController.setNeedsStatusBarAppearanceUpdate)) {
				self.perform(#selector(UIViewController.setNeedsStatusBarAppearanceUpdate))
			}
			
			UIApplication.shared.isStatusBarHidden = newValue
		}
		get
		{
			return UIApplication.shared.isStatusBarHidden
		}
	}
}




