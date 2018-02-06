//
//  SCNNode+SmoothPosition.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-10-18.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit
import ObjectiveC





private var RecentDistancesAssociatedObjectPointer = Selector(("RecentDistancesAssociatedObjectPointer"))

public extension SCNNode
{
    /// Use average of recent distances to avoid rapid changes in object scale.
    fileprivate var recentDistances: [SCNFloat] {
        get
        {
            if let recentDistances = objc_getAssociatedObject(self, &RecentDistancesAssociatedObjectPointer) as? [SCNFloat] {
                return recentDistances
            } else {
                self.recentDistances = [SCNFloat]()
                return self.recentDistances
            }
        }
        set
        {
            objc_setAssociatedObject(self,
									 &RecentDistancesAssociatedObjectPointer,
									 newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    
    
    
    /**
     Set the object's position based on the provided position relative to the `cameraTransform`.
     If `smoothMovement` is true, the new position will be averaged with previous position to
     avoid large jumps.
     */
    func worldPositionFor(targetWorldPosition: simd_float3, relativeTo cameraTransform: matrix_float4x4, smoothMovement: Bool) -> simd_float3
    {
        let cameraWorldPosition = cameraTransform.translation
		let positionOffsetFromCamera: simd_float3 = targetWorldPosition - cameraWorldPosition
        
        /*
         Compute the average distance of the object from the camera over the last ten
         updates. Notice that the distance is applied to the vector from
         the camera to the content, so it affects only the percieved distance to the
         object. Averaging does _not_ make the content "lag".
         */
        if smoothMovement {
            // Add the latest position and keep up to 10 recent distances to smooth with.
            self.recentDistances.append(positionOffsetFromCamera.length)
            self.recentDistances = Array(self.recentDistances.suffix(10))
			
            let averagedDistancePosition = positionOffsetFromCamera.normalized * self.recentDistances.average
            return cameraWorldPosition + averagedDistancePosition
        } else {
            return cameraWorldPosition + positionOffsetFromCamera
        }
    }
}




