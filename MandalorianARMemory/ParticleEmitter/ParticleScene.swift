//
//  ParticleScene.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 22/05/2021.
//

import Foundation
import SpriteKit

class ParticleScene: SKScene {
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let particleEmitter = SKEmitterNode(fileNamed: "FireParticles")!
        particleEmitter.position = CGPoint(x: size.width / 2, y: 20)
        addChild(particleEmitter)
    }
}
