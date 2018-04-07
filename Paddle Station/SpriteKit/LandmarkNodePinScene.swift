//
//  GameScene.swift
//  test
//
//  Created by Pat Sluth on 2018-03-08.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import SpriteKit





class LandmarkNodePinScene: SKScene
{
	var text: String? {
		get
		{
			return self.label?.text
		}
		set
		{
			self.label.text = newValue
			
			if let newValue = newValue {
				let lines = newValue.components(separatedBy: CharacterSet.newlines).count
				let targetHeight = self.size.height / 1.45
				let fontSize = targetHeight / CGFloat(lines)
				self.label.fontSize = fontSize
			}
			
			
			
			
//			self.adjustLabelFontSizeToFitRect(labelNode: self.label, size: self.background.size)
			
			
			
			
//			if let label = self.label {
//				label.text = newValue
//				print(label.frame)
//			} else {
//				self.label = {
//					let label = SKLabelNode(text: newValue)
//					label.fontSize = 100.0
//					label.fontColor = UIColor.black
//					label.numberOfLines = 0
//					label.lineBreakMode = NSLineBreakMode.byWordWrapping
//					self.addChild(label)
//					print(label.frame)
//					return label
//				}()
//			}
			
//			if let background = self.background {
////				print(background.frame)
////				print(background.size)
//			} else {
//				self.background = {
//					let background = SKSpriteNode(imageNamed: R.image.pinBackground.name)
//					background.color = UIColor.clear
////					background.size = self.size
//					background.anchorPoint = CGPoint(x: 0.5, y: 0.55)
//					self.addChild(background)
//					return background
//				}()
//			}
			
			
			
			
			
//			DispatchQueue.main.async {
			
//				guard let label = self.label else { return }
//				let s = label.frame
//			print(self.label?.parent)
//				self.label?.text = newValue
			
			// Disable restart for a while in order to give the session time to restart.
//			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//				print(self.label?.calculateAccumulatedFrame())
//			}
//				print(s, label.frame)
			self.updateSize()
//			}
		}
	}
	
	func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, size:CGSize) {
		
		// Determine the font scaling factor that should let the label text fit in the given rectangle.
		let scalingFactor = min(size.width / labelNode.frame.width, size.height / labelNode.frame.height)
		
		// Change the fontSize.
		labelNode.fontSize *= scalingFactor
		
		// Optionally move the SKLabelNode to the center of the rectangle.
//		labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
	}
	
	var attributedText: NSAttributedString? {
		get
		{
			return self.label?.attributedText
		}
		set
		{
//			DispatchQueue.main.async {
				self.label?.attributedText = newValue
//				self.updateSize()
//			}
		}
	}
	
	fileprivate var background: SKSpriteNode!
	fileprivate var label: SKLabelNode!
	
	
	
	
	
	override func sceneDidLoad()
	{
		super.sceneDidLoad()
		
		self.background = self.childNode(withName: "//background") as! SKSpriteNode
		self.label = self.childNode(withName: "//label") as! SKLabelNode
		
//		self.label.preferredMaxLayoutWidth = self.size.width / 1.08
	}
	
	fileprivate func updateSize()
	{
//		guard let label = self.label else { return }
//		guard let background = self.background else { return }
//
//		// Padding for pinImage
//		let currentSize = self.size
//		let newSize = CGSize(width: label.frame.size.width * 1.08, height: label.frame.size.height * 1.26)
//
//		guard currentSize != newSize else { return }
//
////		self.size = newSize
//		background.size = newSize
	}
}




