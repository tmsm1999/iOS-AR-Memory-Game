//
//  BallonAnimationDelegate.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 05/05/2021.
//

import Foundation
import UIKit

class BallonAnimationDelegate: NSObject, CAAnimationDelegate {
    var didFinishAnimation: (() -> Void)?
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didFinishAnimation?()
    }
}
