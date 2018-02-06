//
//  UIScrollView+PDF.swift
//  PathwaystoFaery
//
//  Created by Pat Sluth on 2017-12-19.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





fileprivate typealias UIScrollViewSnapshotSlice = (contentOffset: CGPoint, frame: CGRect)





public extension UIScrollView
{
	@objc func generatePDFDataFor(title: String?, footerViews: [UIView]) -> NSMutableData?
	{
		let slices = self.generateSnapshotSlices()
		guard !slices.isEmpty else { return nil }
		
		
		
		// Save state
		let originalBackgroundColor = self.backgroundColor
		let originalContentOffset = self.contentOffset
		let masksToBounds = self.layer.masksToBounds
		
		
		
		let pdfData = NSMutableData()
		let contentBounds = CGRect(origin: CGPoint.zero, size: self.contentSize)
		
		
		
		UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
		guard let context = UIGraphicsGetCurrentContext() else {
			UIGraphicsEndPDFContext()
			return nil
		}
		
		
		
		// Apply state
		self.backgroundColor = UIColor.clear
		self.setContentOffset(CGPoint.zero, animated: false)
		self.layer.masksToBounds = false
		
		
		
		if let title = title {
			let fontSize: CGFloat = 21.0
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = NSTextAlignment.center
			let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
							  NSAttributedStringKey.foregroundColor: UIColor.black,
							  NSAttributedStringKey.paragraphStyle: paragraphStyle]
			let titleAttributedString = NSAttributedString(string: title, attributes: attributes)
			
			
			
			// Draw title
			let verticalPadding: CGFloat = 20.0
			var titleBounds = CGRect(x: 0.0, y: 0.0, width: contentBounds.width, height: fontSize + verticalPadding)
			UIGraphicsBeginPDFPageWithInfo(titleBounds, nil)
			titleBounds.origin.y += (verticalPadding / 2.0)
			titleBounds.size.height -= verticalPadding
			titleAttributedString.draw(in: titleBounds)
		}
		
		
		
		// Draw content
		UIGraphicsBeginPDFPageWithInfo(contentBounds, nil)
		for slice in slices {
			self.setContentOffset(slice.contentOffset, animated: false)
			self.setNeedsDisplay()
			self.layer.render(in: context)
		}
		
		
		
		// Draw footer views
		for footerView in footerViews {
			UIGraphicsBeginPDFPageWithInfo(footerView.bounds, nil)
			footerView.layer.render(in: context)
		}
		
		
		
		
		UIGraphicsEndPDFContext()
		
		
		
		// Restore state
		self.backgroundColor = originalBackgroundColor
		self.setContentOffset(originalContentOffset, animated: false)
		self.layer.masksToBounds = masksToBounds
		
		
		
		return pdfData
	}
}





fileprivate extension UIScrollView
{
	func generateSnapshotSlices() -> [UIScrollViewSnapshotSlice]
	{
		// get the remainder -> last offset in eacht direction will probably not be an exact multipe of bounds width/height
		//        let xPartial = contentSize.width % bounds.size.width
		//        let yPartial = contentSize.height % bounds.size.height
		let xPartial = self.contentSize.width.truncatingRemainder(dividingBy: self.bounds.size.width)
		let yPartial = self.contentSize.height.truncatingRemainder(dividingBy: self.bounds.size.height)
		
		// get the number of screenshots needed in each direction, without the partials
		let xSlices = Int((self.contentSize.width - xPartial) / self.bounds.size.width)
		let ySlices = Int((self.contentSize.height - yPartial) / self.bounds.size.height)
		
		let zeroOriginBounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
		var sliceContentOffset = CGPoint.zero
		var snapshotFrames = [UIScrollViewSnapshotSlice]()
		
		// total number of slices in x dimention
		var xSlicesWithPartial = xSlices
		if xPartial > 0 {
			xSlicesWithPartial += 1
		}
		
		// total number of slices in y dimention
		var ySlicesWithPartial = ySlices
		if yPartial > 0 {
			ySlicesWithPartial += 1
		}
		
		for y in 0..<ySlicesWithPartial {
			
			sliceContentOffset.x = 0.0
			
			for x in 0..<xSlicesWithPartial {
				
				var sliceFrame: CGRect
				
				// check for partials
				if y == ySlices && x == xSlices {
					sliceFrame = CGRect(x: self.bounds.width - xPartial,
										y: self.bounds.height - yPartial,
										width: xPartial,
										height: yPartial) // double partial
				} else if y == ySlices {
					sliceFrame = CGRect(x: 0.0,
										y: self.bounds.height - yPartial,
										width: self.bounds.width,
										height: yPartial) // y partial
				} else if x == xSlices {
					sliceFrame = CGRect(x: self.bounds.width - xPartial,
										y: 0.0,
										width: xPartial,
										height: self.bounds.height) // x partial
				} else {
					sliceFrame = zeroOriginBounds // not a partial
				}
				
				//				snapshotFrames.append((sliceContentOffset.rounded, sliceFrame.integral))	// add current offset before altering
				snapshotFrames.append((sliceContentOffset, sliceFrame))	// add current offset before altering
				
				if x == xSlices {
					sliceContentOffset.x = self.contentSize.width - self.bounds.size.width // x partial
				} else {
					sliceContentOffset.x = sliceContentOffset.x + self.bounds.size.width // not a partial
				}
			}
			if y == ySlices {
				sliceContentOffset.y = self.contentSize.height - self.bounds.size.height // y partial
			} else {
				sliceContentOffset.y = sliceContentOffset.y + self.bounds.size.height // not a partial
			}
		}
		
		return snapshotFrames
	}
}




