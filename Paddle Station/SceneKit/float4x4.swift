//
//  float4x4.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-18.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import ARKit





public extension float4x4
{
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
    */
    var translation: float3
    {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}




