//
//  GameScene.swift
//  test
//
//  Created by Pat Sluth on 2018-03-08.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import SpriteKit
import GameplayKit





extension SKLabelNode
{
	func sizeToFit()
	{
		guard let scene = self.scene else { return }
		
//		while self.frame.size.width > scene.size.width {
//			self.fontSize -= 1.0
//		}
		
		while self.frame.size.height > scene.size.height {
			self.fontSize -= 1.0
		}
	}
	
	func fitToWidth(maxWidth: CGFloat)
	{
//		while frame.size.width >= maxWidth {
//			fontSize-=1.0
//		}
	}
	
	func fitToHeight(maxHeight: CGFloat)
	{
//		while frame.size.height >= maxHeight {
//			fontSize-=1.0
//		}
	}
}





class LandmarkNodePinScene: SKScene
{
	var text: String? {
		get
		{
			return self.label?.text
		}
		set
		{
			DispatchQueue.main.async {
				self.label?.text = newValue
				self.updateSize()
			}
		}
	}
	
	var attributedText: NSAttributedString? {
		get
		{
			return self.label?.attributedText
		}
		set
		{
			DispatchQueue.main.async {
				self.label?.attributedText = newValue
				self.updateSize()
			}
		}
	}
	
	fileprivate lazy var background: SKSpriteNode? = {
		return self.childNode(withName: "//background") as? SKSpriteNode
	}()
	
	fileprivate lazy var label: SKLabelNode? = {
		return self.childNode(withName: "//label") as? SKLabelNode
	}()
	
	
	
	
	
	
	fileprivate func updateSize()
	{
		guard let label = self.label else { return }
		
		self.size = CGSize(width: label.frame.size.width * 1.08, height: label.frame.size.height * 1.26)
		self.background?.size = self.size
	}
}




