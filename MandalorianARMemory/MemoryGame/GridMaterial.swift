//
//  GridMaterial.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 27/04/2021.
//

import Foundation
import ARKit
import SceneKit

class GridMaterial: SCNMaterial {
    
    override init() {
        super.init()
        
        let gridImage = UIImage(named: "Grid")
        diffuse.contents = gridImage
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        
        let mmPerMeter: Float = 1000
        let mmOfImage: Float = 65
        let repeatAmount: Float = mmPerMeter / mmOfImage
        
        diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x * repeatAmount, anchor.extent.z * repeatAmount, 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
