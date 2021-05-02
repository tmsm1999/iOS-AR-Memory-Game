//
//  Card.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 08/04/2021.
//

import ARKit
import Foundation

class Card {
    
    var characterName: String
    var characterSummary: String
    var characterNode: SCNNode
    private var cardIsUp: Bool
    private var cardFoundMatch: Bool
    private var cardWasTurnedBefore: Bool
    
    init(characterName: String, characterSummary: String, pairNumber: Int, backCard: String) {
        
        self.characterName = characterName + "_\(pairNumber)"
        self.characterSummary = characterSummary
        self.cardIsUp = false
        self.cardFoundMatch = false
        self.cardWasTurnedBefore = false
        
        let card = SCNNode()
        card.name = characterName + "_\(pairNumber)"
        card.geometry = SCNBox(width: 0.05, height: 0.00025, length: 0.09, chamferRadius: 0.5)
        card.geometry?.firstMaterial?.diffuse.contents = backCard
        card.geometry?.firstMaterial?.isDoubleSided = false
        
        let character = SCNNode()
        character.geometry = SCNBox(width: 0.05, height: 0.00025, length: 0.09, chamferRadius: 10)
        character.geometry?.firstMaterial?.diffuse.contents = characterName
        character.geometry?.firstMaterial?.isDoubleSided = false
        character.position = SCNVector3(card.presentation.position.x, card.presentation.position.y + 0.0001, card.presentation.position.z)
        character.eulerAngles = SCNVector3(0, 0, 180.degreesToRadians)
        
        card.addChildNode(character)
        
        characterNode = card
    }
    
    func turnCard() {
        cardIsUp = !cardIsUp
    }
    
    func matchCard() {
        cardFoundMatch = true
    }
    
    func cardWasMatched() -> Bool {
        return cardFoundMatch
    }
    
    func setCardWasTurnedBefore() {
        cardWasTurnedBefore = true
    }
    
    func getCardWasTurnedUpBefore() -> Bool {
        return cardWasTurnedBefore
    }
    
    func isCardTurnedUp() -> Bool {
        return cardIsUp
    }
}

extension SCNNode {
    
    func turnCardUpAnimation() {
            
        let nodePosition = self.presentation.position
        
        let liftCard = CABasicAnimation(keyPath: "position")
        liftCard.fromValue = self.presentation.position
        liftCard.toValue = SCNVector3(nodePosition.x, nodePosition.y, 0.05)
        self.position = SCNVector3(nodePosition.x, nodePosition.y, 0.05)
        liftCard.duration = 1
        self.addAnimation(liftCard, forKey: "position")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let action = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 1)
            self.runAction(action)
        }
    }
    
    func turnCardDownAnimation() {
        
        let action = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 1)
        self.runAction(action)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let nodePosition = self.presentation.position
            
            let liftCard = CABasicAnimation(keyPath: "position")
            liftCard.fromValue = self.presentation.position
            liftCard.toValue = SCNVector3(nodePosition.x, nodePosition.y, 0)
            self.position = SCNVector3(nodePosition.x, nodePosition.y, 0)
            liftCard.duration = 1
            self.addAnimation(liftCard, forKey: "position")
        }
    }
    
    func putCardDownAfterMatch() {
        
        let nodePosition = self.presentation.position
        
        let liftCard = CABasicAnimation(keyPath: "position")
        liftCard.fromValue = self.presentation.position
        liftCard.toValue = SCNVector3(nodePosition.x, nodePosition.y, 0)
        self.position = SCNVector3(nodePosition.x, nodePosition.y, 0)
        liftCard.duration = 1
        self.addAnimation(liftCard, forKey: "position")
    }
    
    func characterInfoPlaneAppearence() {
        
        let nodePosition = self.position
        
        let pushPlaneUp = CABasicAnimation(keyPath: "position")
        pushPlaneUp.fromValue = nodePosition
        pushPlaneUp.toValue = SCNVector3(nodePosition.x, nodePosition.y, 0.35 / 4)
        self.position = SCNVector3(nodePosition.x, nodePosition.y, 0.35 / 4)
        pushPlaneUp.duration = 2
        self.addAnimation(pushPlaneUp, forKey: "position")
    }
    
    func characterInfoPlaneVanishes() {
        
        let pushPlaneUp = CABasicAnimation(keyPath: "opacity")
        pushPlaneUp.fromValue = 1
        pushPlaneUp.toValue = 0
        pushPlaneUp.duration = 1
        self.addAnimation(pushPlaneUp, forKey: "opacity")
    }
}

extension Int {
    
    var degreesToRadians: Double {
        return Double(self) * .pi / 180
    }
}
