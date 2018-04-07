//
//  CurrencyFormatter.swift
//  SWQuestrade
//
//  Created by Pat Sluth on 2017-08-14.
//  Copyright © 2017 patsluth. All rights reserved.
//

import Foundation





public final class CurrencyFormatter: NumberFormatter
{
	fileprivate let errorString = "!"
	
	
	
	
	
	public override init()
	{
		super.init()
		
		self.numberStyle = NumberFormatter.Style.currency
	}
	
	required public init?(coder aDecoder: NSCoder)
	{
		fatalError(#function + " has not been implemented")
	}
	
	public func string<T: FloatingPointType>(_ value: T?) -> String
	{
		guard let value = value,
			let string = self.string(from: NSNumber(value: Double(value))) else {
				return self.errorString
		}
		return string
	}
}




