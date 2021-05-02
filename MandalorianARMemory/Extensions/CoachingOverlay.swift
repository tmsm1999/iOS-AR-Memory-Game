//
//  CoachingOverlay.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 02/05/2021.
//

import Foundation
import ARKit

extension ARMemoryGameUI: ARCoachingOverlayViewDelegate {
    
    func setUpCoachingExperience() {
        
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            
            coachingOverlay.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        self.userInstructionsView.layer.borderColor = UIColor.white.cgColor
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
        coachingOverlay.activatesAutomatically = false
        
        userInstructionsView.isHidden = false
        userInstructionLabel.text = "Place thematic image to load card set..."
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Initial Card Images", bundle: nil) else {
            fatalError("Could not get tracking images.")
        }
        
        configuration.detectionImages = trackingImages
        configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        sceneView.session.run(configuration)

        print("Start image tracking!")
    }
}
