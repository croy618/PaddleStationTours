//
//  LandmarkNode.swift
//  Paddle Station
//
//  Created by Pat Sluth on 2018-01-31.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation
import SceneKit





class LandmarkNode: SCNNode
{
	let landmark: Landmark
	
	
	
	
	
	required init(landmark: Landmark)
	{
		self.landmark = landmark
		
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError(#function + " has not been implemented")
	}
}




