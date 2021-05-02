//
//  MemoryGame.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 08/04/2021.
//

import Foundation
import ARKit

struct CharacterInfo: Codable {
    var characterName: String
    var characterSummary: String
}

class MemoryGame: NSObject {
    
    private var initialNumberOfCards: Int
    private var gameBoard: SCNNode = SCNNode()
    private var gameCards: [Card] = [Card]()
    private var gameDifficulty: GameDifficulty
    private var cardsTurnedUp = [Card]()
    private var cardSet: String!
    @objc dynamic var humanPlayerPoints: Int
    private var previousHumanPlayerNumberOfPoints: Int
    @objc dynamic var isComputerTurn: Bool
    @objc dynamic var gameHasEnded: Bool
    
    @objc dynamic var computerPlayer: ComputerPlayer
    
    init(initialNumberOfCards: Int, gameDifficulty: GameDifficulty) {
        
        self.initialNumberOfCards = initialNumberOfCards
        self.gameDifficulty = gameDifficulty
        self.computerPlayer = ComputerPlayer()
        self.humanPlayerPoints = 0
        self.isComputerTurn = Bool.random()
        self.gameHasEnded = false
        self.previousHumanPlayerNumberOfPoints = 0
        
        super.init()
    }
    
    func setUpGame() {
        
        guard cardSet != nil else {
            return
        }
        
        self.setUpGameBoard()
        
        let characterInfo = readCharacterInfoJSON().shuffled()
        var numberOfPairsOfCardsToSetUp = initialNumberOfCards
        
        var index = 0
        
        let backCard = "backOfCard_" + cardSet
        
        for(key, value) in characterInfo {
            
            let characterShow = String(key.split(separator: "_")[1])
            
            if characterShow != cardSet {
                continue
            }
            
            let newCardOne = Card(characterName: key, characterSummary: value, pairNumber: 1, backCard: backCard)
            addCardToGame(card: newCardOne)
            
            let newCardTwo = Card(characterName: key, characterSummary: value, pairNumber: 2, backCard: backCard)
            addCardToGame(card: newCardTwo)
            
            numberOfPairsOfCardsToSetUp -= 1
            if numberOfPairsOfCardsToSetUp < 1 {
                break;
            }
            
            index += 1
        }
        
        gameCards = gameCards.shuffled()
        
        for card in gameCards {
            print("\(card.characterName), \(card.characterSummary), \(card.cardIsUp), \(card.cardFoundMatch)")
        }
        
        computerPlayer.gameCards = gameCards
        
        self.placeCardsOnBoard()
    }
    
    func setNewCardSet(cardSet: String) {
        self.cardSet = cardSet
        self.setUpGame()
    }
    
    func isCardSetSet() -> Bool {
        
        guard let _ = self.cardSet else {
            return false
        }
        
        return true
    }
    
    func setUpGameBoard() {
        
        self.gameBoard.geometry = SCNPlane(width: 0.43, height: 0.30)
        self.gameBoard.name = "board"
        self.gameBoard.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        self.gameBoard.eulerAngles = SCNVector3(-90.degreesToRadians, 0, 0)
    }
    
    func showPlaneWidthCharacterInfo(characterName: String, characterBio: String) {
        
        let planeWithCharacterInfo = SCNNode()
        planeWithCharacterInfo.name = "planeWithCharacterInfo"
        
        planeWithCharacterInfo.geometry = SCNPlane(width: 0.43, height: 0.35 / 2)
        planeWithCharacterInfo.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        planeWithCharacterInfo.position = SCNVector3(0, self.gameBoard.height / 2, -0.35 / 4 - 0.01)
        planeWithCharacterInfo.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        
        let characterName = makeTextNode(content: String(characterName.split(separator: "_")[0]), font: UIFont.boldSystemFont(ofSize: 15))
        characterName.position = SCNVector3(-planeWithCharacterInfo.width / 2, planeWithCharacterInfo.height / 2 - characterName.height, 0.001)
        planeWithCharacterInfo.addChildNode(characterName)
        
        let characterBio = makeTextNode(content: characterBio, font: UIFont.systemFont(ofSize: 8))
        characterBio.position = SCNVector3(-planeWithCharacterInfo.width / 2, -0.04, 0.001)
        planeWithCharacterInfo.addChildNode(characterBio)
        
        self.gameBoard.addChildNode(planeWithCharacterInfo)
        planeWithCharacterInfo.characterInfoPlaneAppearence()
    }
    
    func makeTextNode(content: String, font: UIFont) -> SCNNode {
        
        let text = SCNText(string: content, extrusionDepth: 0)
        text.flatness = 0.1
        text.font = font
        text.isWrapped = true
        
        let textNode = SCNNode()
        textNode.geometry = text
        textNode.scale = SCNVector3Make(0.002, 0.002, 0.002)
        
        return textNode
    }
    
    func placeCardsOnBoard() {
        
        let cardWidth = 0.05
        let cardHeight = 0.09
        
        let boardWidth = 0.43
        let boardheight = 0.30
        
        var currentPositionX = -boardWidth / 2 + 0.03
        var currentPositionY = boardheight / 2 - cardHeight / 2 - 0.03
        
        print(gameCards.count)
        
        for i in 0 ... (gameCards.count - 1) / 2 {

            gameCards[i].characterNode.eulerAngles = SCNVector3(-90.degreesToRadians, 0, 0)
            gameCards[i].characterNode.position = SCNVector3(Double(currentPositionX) + cardWidth / 2, currentPositionY, 0)
            gameBoard.addChildNode(gameCards[i].characterNode)
            
            currentPositionX = currentPositionX + cardWidth + 0.03
        }
        
        currentPositionX = -boardWidth / 2 + 0.03
        currentPositionY = -boardheight / 2 - 0.02 + cardHeight
        
        for i in gameCards.count / 2 ... (gameCards.count - 1) {

            gameCards[i].characterNode.eulerAngles = SCNVector3(-90.degreesToRadians, 0, 0)
            gameCards[i].characterNode.position = SCNVector3(Double(currentPositionX) + cardWidth / 2, currentPositionY, 0)
            gameBoard.addChildNode(gameCards[i].characterNode)
            
            currentPositionX = currentPositionX + cardWidth + 0.03
        }
    }
    
    func checkMatch() {
        
        if cardsTurnedUp[0].characterName.split(separator: "_")[0] == cardsTurnedUp[1].characterName.split(separator: "_")[0] {
            cardsTurnedUp[0].cardFoundMatch = true
            cardsTurnedUp[1].cardFoundMatch = true
            print("We have a match!")
            
            cardsTurnedUp[0].characterNode.putCardDownAfterMatch()
            cardsTurnedUp[1].characterNode.putCardDownAfterMatch()
            
            computerPlayer.removeSeenCardOnMatch(cardName: cardsTurnedUp[0].characterName)
            computerPlayer.removeSeenCardOnMatch(cardName: cardsTurnedUp[1].characterName)
            
            if isComputerTurn {
                computerPlayer.addPointsForMatchedCard(points: 3)
            }
            else {
                previousHumanPlayerNumberOfPoints = humanPlayerPoints
                humanPlayerPoints += 3
            }
            
            let characterName = String(cardsTurnedUp[0].characterName.split(separator: "_")[0])
            let characterBio = cardsTurnedUp[0].characterSummary
            showPlaneWidthCharacterInfo(characterName: characterName, characterBio: characterBio)
            
            if checkGameHasEnded() {
                gameHasEnded = true
                return
            }
            
            nextPlay(changesPlayer: false)
        }
        else {
            if isComputerTurn {
                if cardsTurnedUp[0].cardWasTurnedBefore || cardsTurnedUp[1].cardWasTurnedBefore {
                    computerPlayer.removePointsForCardNotMatched(points: 1)
                }
            }
            else {
                if cardsTurnedUp[0].cardWasTurnedBefore || cardsTurnedUp[1].cardWasTurnedBefore {
                    previousHumanPlayerNumberOfPoints = humanPlayerPoints
                    humanPlayerPoints = humanPlayerPoints - 1 < 0 ? 0 : humanPlayerPoints - 1
                }
            }
            
            if gameDifficulty == .hard || gameDifficulty == .medium {
                
                for card in cardsTurnedUp {
                    
                    for i in 0 ..< gameCards.count {
                        
                        if card.characterName == gameCards[i].characterName {
                            computerPlayer.addSeenCard(cardName: card.characterName, cardIndex: i)
                        }
                    }
                }
            }
            
            cardsTurnedUp[0].characterNode.turnCardDownAnimation()
            cardsTurnedUp[1].characterNode.turnCardDownAnimation()
            
            cardsTurnedUp[0].cardIsUp = false
            cardsTurnedUp[1].cardIsUp = false
            
            cardsTurnedUp[0].cardWasTurnedBefore = true
            cardsTurnedUp[1].cardWasTurnedBefore = true
            
            cardsTurnedUp.removeAll()
            
            nextPlay(changesPlayer: true)
        }
    }
    
    func checkGameHasEnded() -> Bool {
        
        for card in gameCards {
            if !card.cardFoundMatch {
                return false
            }
        }
        
        return true
    }
    
    func nextPlay(changesPlayer: Bool) {
        
        var waitingTime = DispatchTime.now() + 5
        
        self.cardsTurnedUp.removeAll()
        
        if changesPlayer {
            isComputerTurn = !isComputerTurn
            waitingTime = DispatchTime.now() + 3
        }
        
        if isComputerTurn {
            
            DispatchQueue.main.asyncAfter(deadline: waitingTime) {
                
                var indexForCardsNotMatched = [Int]()
                
                for index in (0..<self.gameCards.count) {
                    if !self.gameCards[index].cardFoundMatch {
                        indexForCardsNotMatched.append(index)
                    }
                }
            
                let cardsToTurnedUp = self.computerPlayer.play(indexForCardsNotMatched: indexForCardsNotMatched, gameDifficulty: self.gameDifficulty)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.turnUpCard(card: self.gameCards[cardsToTurnedUp.0])
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.turnUpCard(card: self.gameCards[cardsToTurnedUp.1])
                }
            }
        }
    }
    
    func updateHumanNumberOfPoints() -> (Int, Int) {
        return (previousHumanPlayerNumberOfPoints, humanPlayerPoints)
    }
    
    func turnUpCard(card: Card) {
        
        self.gameBoard.enumerateChildNodes { child, _ in
            
            if child.name == "planeWithCharacterInfo" {
                
                child.characterInfoPlaneVanishes()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    child.removeFromParentNode()
                }
            }
        }
        
        for cardTurnedUp in cardsTurnedUp {
            if cardTurnedUp.characterName == card.characterName {
                return
            }
        }
        
        cardsTurnedUp.append(card)
        card.cardIsUp = true
        card.characterNode.turnCardUpAnimation()
        
        if cardsTurnedUp.count == 2 {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.checkMatch()
            }
        }
    }
    
    func removeCharacterInfo() {
        
        self.gameBoard.enumerateChildNodes { child, _ in
            
            if child.name == "planeWithCharacterInfo" {
                
                child.characterInfoPlaneVanishes()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    child.removeFromParentNode()
                }
            }
        }
    }
    
    func addCardToGame(card: Card) {
        gameCards.append(card)
    }
    
    func getGameCards() -> [Card] {
        return gameCards
    }
    
    func getGameBoard() -> SCNNode {
        return gameBoard
    }
    
    func getHumanPlayerPoints() -> Int {
        return humanPlayerPoints
    }
    
    func getComputerPlayerPoints() -> Int {
        return computerPlayer.getNumberOfPoints()
    }
    
    func numberOfCardsTurnedUp() -> Int{
        return cardsTurnedUp.count
    }
    
    private func readCharacterInfoJSON() -> [String: String] {
        
        var characterInfo: [String: String] = [:]
        
        if let filePath = Bundle.main.url(forResource: "characterInfo", withExtension: "json") {
            
            let decoder = JSONDecoder()
            
            do {
                let data = try Data(contentsOf: filePath)
                let characterList = try decoder.decode([CharacterInfo].self, from: data)
                
                for character in characterList {

                    characterInfo[character.characterName] = character.characterSummary
                }
            }
            catch {
                fatalError("Can't read information from character json file.")
            }
        }
        else {
            fatalError("Can't not find json file with character info.")
        }
        
        return characterInfo
    }
}
