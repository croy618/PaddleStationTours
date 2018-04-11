//
//  URL.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-08.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





public extension URL
{
	func isFileTypeOf(_ pathExtension: String) -> Bool
	{
		guard self.isFileURL else { return false }
		return self.pathExtension.localizedCaseInsensitiveCompare(pathExtension) == ComparisonResult.orderedSame
	}
	
	var fileName: String {
		if self.hasDirectoryPath {
			return self.lastPathComponent.removingPercentEncodingSafe
		}
		return self.deletingPathExtension().lastPathComponent.removingPercentEncodingSafe
	}
	
	var fileNameWithExtension: String {
		guard !String.isEmpty(self.pathExtension) else { return self.fileName }
		return self.fileName + "." + self.pathExtension
	}
	
	var isFile: Bool {
		return !self.isDirectory
	}
	
	var isDirectory: Bool {
		return self.hasDirectoryPath
	}
	
	var isReachable: Bool {
		//		guard let _ = try? self.checkResourceIsReachable() else { return false }
		//		return true
		guard let filePath = self.absoluteURL.path.removingPercentEncoding else { return false }
		return FileManager.default.fileExists(atPath: filePath)
	}
	
	// TODO: works?
	var isReachableFile: Bool {
		return self.isFile && self.isReachable
	}
	
	var isReachableDirectory: Bool {
		return self.isDirectory && self.isReachable
	}
}




