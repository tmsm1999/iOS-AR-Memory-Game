//
//  Player.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 25/04/2021.
//

import Foundation

class ComputerPlayer: NSObject {
    
    @objc dynamic var numberOfPoints: Int
    private var previousNmberOfPoints: Int
    private var cardsSeenIndex: [String: Int]
    
    var gameCards: [Card]
    
    override init() {
        
        self.numberOfPoints = 0
        self.previousNmberOfPoints = 0
        self.cardsSeenIndex = [:]
        self.gameCards = []
    }
    
    func play(indexForCardsNotMatched: [Int], gameDifficulty: GameDifficulty) -> (Int, Int) {
        
        var chosenIndex: (Int, Int) = (-1, -1)
        var cardsToChoosenFrom = indexForCardsNotMatched
        
        switch gameDifficulty {
        
        case .easy:
            
            if cardsToChoosenFrom.count == 2 {
                chosenIndex = (cardsToChoosenFrom[0], cardsToChoosenFrom[1])
            }
            else {
                print(cardsToChoosenFrom)
                
                var index = (Int.random(in: 0..<cardsToChoosenFrom.count))
                let firstCardIndex = cardsToChoosenFrom[index]
                cardsToChoosenFrom.remove(at: index)
                
                index = (Int.random(in: 0..<cardsToChoosenFrom.count))
                let secondCardIndex = cardsToChoosenFrom[index]
                
                chosenIndex = (firstCardIndex, secondCardIndex)
                print(chosenIndex)
            }
            
            break
        
        case .medium:
            
            if cardsToChoosenFrom.count == 2 {
                chosenIndex = (cardsToChoosenFrom[0], cardsToChoosenFrom[1])
            }
            else {
                
                for i in cardsSeenIndex.keys {
                    for j in cardsSeenIndex.keys {
                        
                        if i == j { continue }
                        
                        if i.split(separator: "_")[0] == j.split(separator: "_")[0] {
                            
                            chosenIndex = (cardsSeenIndex[i]!, cardsSeenIndex[j]!)
                            
                            cardsSeenIndex.removeValue(forKey: i)
                            cardsSeenIndex.removeValue(forKey: j)
                            
                            return chosenIndex
                        }
                    }
                }
                    
                var index = (Int.random(in: 0..<cardsToChoosenFrom.count))
                let firstCardIndex = cardsToChoosenFrom[index]
                cardsToChoosenFrom.remove(at: index)
                
                index = (Int.random(in: 0..<cardsToChoosenFrom.count))
                let secondCardIndex = cardsToChoosenFrom[index]
                
                chosenIndex = (firstCardIndex, secondCardIndex)
                print(chosenIndex)
            }
            
        case .hard:
            
            print("Cards to choose from: \(cardsToChoosenFrom.count)")
            
            if cardsToChoosenFrom.count == 2 {
                chosenIndex = (cardsToChoosenFrom[0], cardsToChoosenFrom[1])
            }
            else {
                
                for i in cardsSeenIndex.keys {
                    for j in cardsSeenIndex.keys {
                        
                        if i == j { continue }
                        
                        if i.split(separator: "_")[0] == j.split(separator: "_")[0] {
                            
                            chosenIndex = (cardsSeenIndex[i]!, cardsSeenIndex[j]!)
                            
                            cardsSeenIndex.removeValue(forKey: i)
                            cardsSeenIndex.removeValue(forKey: j)
                            
                            print("Found match from seen cards.")
                            print(cardsSeenIndex)
                            
                            return chosenIndex
                        }
                    }
                }
                
                print("Primeira jogada!")
                
                var firstCardIndex = -1
                var secondCardIndex = -1
                
                var indexesAlreadySeen = [Int]()
                for character in cardsSeenIndex.keys {
                    indexesAlreadySeen.append(cardsSeenIndex[character]!)
                }
                
                cardsToChoosenFrom.shuffle()
                
                for index in 0 ..< cardsToChoosenFrom.count {

                    if !indexesAlreadySeen.contains(cardsToChoosenFrom[index]) {

                        if firstCardIndex != -1, secondCardIndex == -1 {

                            secondCardIndex = cardsToChoosenFrom[index]
                            cardsToChoosenFrom.remove(at: index)
                            break
                        }

                        firstCardIndex = cardsToChoosenFrom[index]
                        print(firstCardIndex)

                        for card in cardsSeenIndex.keys {

                            if gameCards[firstCardIndex].characterName.split(separator: "_")[0] == card.split(separator: "_")[0] {
                                
                                secondCardIndex = cardsSeenIndex[card]!
                                cardsSeenIndex.removeValue(forKey: card)
                                
                                print("Smart move!")
                                return (firstCardIndex, secondCardIndex)
                            }
                        }
                    }
                }
                
                if firstCardIndex == -1 {
                    
                    let index = (Int.random(in: 0..<cardsToChoosenFrom.count))
                    firstCardIndex = cardsToChoosenFrom[index]
                    cardsToChoosenFrom.remove(at: index)
                    
                    print(firstCardIndex)
                }
                
                if secondCardIndex == -1 {
                    
                    print("Segunda carta à sorte.")
                    
                    let index = (Int.random(in: 0..<cardsToChoosenFrom.count))
                    secondCardIndex = cardsToChoosenFrom[index]
                    cardsToChoosenFrom.remove(at: index)
                    
                    print(secondCardIndex)
                }
                
                chosenIndex = (firstCardIndex, secondCardIndex)
            }
        }
        
        return chosenIndex
    }
    
    func addSeenCard(cardName: String, cardIndex: Int) {
        cardsSeenIndex[cardName] = cardIndex
    }
    
    func removeSeenCardOnMatch(cardName: String) {
        cardsSeenIndex.removeValue(forKey: cardName)
    }
    
    func addPointsForMatchedCard(points: Int) {
        previousNmberOfPoints = numberOfPoints
        numberOfPoints += points
    }
    
    func removePointsForCardNotMatched(points: Int) {
        previousNmberOfPoints = numberOfPoints
        numberOfPoints = numberOfPoints - points < 0 ? 0 : numberOfPoints - points
    }
    
    func getNumberOfPoints() -> Int {
        return numberOfPoints
    }
    
    func updateComputerNumberOfPoints() -> (Int, Int) {
        return (previousNmberOfPoints, numberOfPoints)
    }
}
