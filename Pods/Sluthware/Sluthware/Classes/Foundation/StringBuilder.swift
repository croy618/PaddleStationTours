//
//  StringBuilder.swift
//  Sluthware
//
//  Created by Pat Sluth on 2018-02-13.
//  Copyright © 2018 Pat Sluth. All rights reserved.
//

import Foundation





public class StringBuilder
{
	fileprivate(set) var lines = [String]()
	public var string: String {
		return self.lines.joined(separator: "\n")
	}
	
	
	
	
	
	public init(string: String)
	{
		_ = self.append(string: string)
	}
	
	public init(line: String)
	{
		_ = self.append(line: line)
	}
	
	public func append(string: String) -> Self
	{
		var lastLine = self.lines.popLast() ?? ""
		lastLine += string
		self.lines.append(lastLine)
		
		return self
	}
	
	public func append(line: String) -> Self
	{
		var lastLine = self.lines.popLast() ?? ""
		lastLine += line + "\n"
		self.lines.append(lastLine)
		
		return self
	}
	
	public func clear() -> Self
	{
		self.lines.removeAll()
		
		return self
	}
}
