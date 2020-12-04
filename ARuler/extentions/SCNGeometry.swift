//
//  SCNGeometry+line.swift
//  ARuler
//
//  Created by Jordy Huijgens on 23/11/2020.
//  Copyright © 2020 Davron. All rights reserved.
//

import Foundation
import SceneKit

extension SCNGeometry {
    class func cylinderLine(from: SCNVector3, to: SCNVector3, segments: Int) -> SCNNode {

            let x1 = from.x
            let x2 = to.x

            let y1 = from.y
            let y2 = to.y

            let z1 = from.z
            let z2 = to.z

            let distance = sqrtf((x2 - x1) * (x2 - x1) +
                                 (y2 - y1) * (y2 - y1) +
                                 (z2 - z1) * (z2 - z1))

            let cylinder = SCNCylinder(radius: 0.002,
                                       height: CGFloat(distance))

            cylinder.radialSegmentCount = segments
        cylinder.firstMaterial?.diffuse.contents = UIColor.red

            let lineNode = SCNNode(geometry: cylinder)

            lineNode.position = SCNVector3(((from.x + to.x)/2),
                                           ((from.y + to.y)/2),
                                           ((from.z + to.z)/2))

            lineNode.eulerAngles = SCNVector3(Float.pi/2,
                                              acos((to.z - from.z)/distance),
                                              atan2(to.y - from.y, to.x - from.x))

            return lineNode
        }
}
