//
//  String.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-19.
//

import Foundation





public extension String
{
	var camelCaseToWords: String {
		return unicodeScalars.reduce("") {
			if CharacterSet.uppercaseLetters.contains($1) == true {
				return ($0 + " " + String($1))
			} else {
				return $0 + String($1)
			}
		}
	}
}




