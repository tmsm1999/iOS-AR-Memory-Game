//
//  ViewController.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 08/04/2021.
//

import UIKit
import ARKit
import SpriteKit

class ARMemoryGameUI: UIViewController, ARSCNViewDelegate {

    var sceneView = ARSCNView()
    var planeAnchors = [(ARAnchor, ARPlaneAnchor)]()
    let configuration = ARWorldTrackingConfiguration()

    var memoryGame: MemoryGame
    var observers = [NSKeyValueObservation]()
    
    let turnLabelWidth: CGFloat = 250
    let turnLabelHeight: CGFloat = 40
    
    let endGameButton = UIButton(type: .system)
    let addBoardButton = UIButton(type: .system)
    let userInstructionsView = UIView()
    let userInstructionLabel = UILabel()
    
    let spinner = UIActivityIndicatorView()
    let spinnerText = UILabel()
    
    let pointsView = UIView()
    let humanPointsLabel = UILabel()
    let computerPointsLabel = UILabel()
    
    let blackView = UIView()
    
    let coachingOverlay = ARCoachingOverlayView()
    
    init(gamedifficulty: GameDifficulty) {
        
        memoryGame = MemoryGame(initialNumberOfCards: 5, gameDifficulty: gamedifficulty)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.sceneView = ARSCNView()
        self.sceneView.delegate = self
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sceneView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(turnCardUp))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let placeBoardImage = UIImage(systemName: "plus.viewfinder")
        addBoardButton.translatesAutoresizingMaskIntoConstraints = false
        addBoardButton.setBackgroundImage(placeBoardImage, for: .normal)
        addBoardButton.addTarget(self, action: #selector(addBoardButtonWasPressed), for: .touchUpInside)
        addBoardButton.isHidden = true
        self.view.addSubview(addBoardButton)
        
        let endGameImage = UIImage(systemName: "xmark.circle.fill")?.withTintColor(UIColor.red, renderingMode: .alwaysOriginal)
        endGameButton.translatesAutoresizingMaskIntoConstraints = false
        endGameButton.setBackgroundImage(endGameImage, for: .normal)
        endGameButton.addTarget(self, action: #selector(giveUpGame), for: .touchUpInside)
        endGameButton.isHidden = false
        self.view.addSubview(endGameButton)
        
        userInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        userInstructionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        userInstructionLabel.text = "This is an Augmented Reality Game..."
        userInstructionLabel.textColor = UIColor.white
        userInstructionsView.addSubview(userInstructionLabel)
        
        userInstructionsView.translatesAutoresizingMaskIntoConstraints = false
        userInstructionsView.backgroundColor = UIColor.systemGray2
        userInstructionsView.layer.cornerRadius = 30
        userInstructionsView.layer.borderWidth = 3
        userInstructionsView.layer.borderColor = UIColor.white.cgColor
        userInstructionsView.isHidden = true
        self.view.addSubview(userInstructionsView)
        
        pointsView.translatesAutoresizingMaskIntoConstraints = false
        pointsView.backgroundColor = UIColor.systemGray2
        pointsView.layer.cornerRadius = 15
        pointsView.layer.borderWidth = 3
        pointsView.layer.borderColor = UIColor.white.cgColor
        pointsView.isHidden = true
        self.view.addSubview(pointsView)
        
        humanPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        humanPointsLabel.font = UIFont.boldSystemFont(ofSize: 17)
        humanPointsLabel.text = "You: 0 points"
        humanPointsLabel.textColor = UIColor.white
        pointsView.addSubview(humanPointsLabel)
        
        computerPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        computerPointsLabel.font = UIFont.boldSystemFont(ofSize: 17)
        computerPointsLabel.text = "PC: 0 points"
        computerPointsLabel.textColor = UIColor.white
        pointsView.addSubview(computerPointsLabel)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor.white
        spinner.isHidden = true
        self.view.addSubview(spinner)
        
        spinnerText.translatesAutoresizingMaskIntoConstraints = false
        spinnerText.text = "Preparing cards..."
        spinnerText.textColor = UIColor.white
        spinnerText.font = UIFont.boldSystemFont(ofSize: 17)
        spinnerText.isHidden = true
        self.view.addSubview(spinnerText)
        
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        blackView.alpha = 1
        blackView.isHidden = true
        self.view.addSubview(blackView)
        
        NSLayoutConstraint.activate([
            
            endGameButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35),
            endGameButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30),
            endGameButton.widthAnchor.constraint(equalToConstant: 45),
            endGameButton.heightAnchor.constraint(equalToConstant: 45),
            
            userInstructionsView.heightAnchor.constraint(equalToConstant: 60),
            userInstructionsView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.55),
            userInstructionsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30),
            userInstructionsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            userInstructionLabel.centerXAnchor.constraint(equalTo: userInstructionsView.centerXAnchor),
            userInstructionLabel.centerYAnchor.constraint(equalTo: userInstructionsView.centerYAnchor),
            
            addBoardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            addBoardButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -65),
            addBoardButton.widthAnchor.constraint(equalToConstant: 70),
            addBoardButton.heightAnchor.constraint(equalToConstant: 70),
            
            pointsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -35),
            pointsView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30),
            pointsView.widthAnchor.constraint(equalToConstant: 180),
            pointsView.heightAnchor.constraint(equalToConstant: 60),
            
            humanPointsLabel.topAnchor.constraint(equalTo: pointsView.topAnchor, constant: 8),
            humanPointsLabel.centerXAnchor.constraint(equalTo: pointsView.centerXAnchor),
            
            computerPointsLabel.bottomAnchor.constraint(equalTo: pointsView.bottomAnchor, constant: -8),
            computerPointsLabel.centerXAnchor.constraint(equalTo: pointsView.centerXAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            spinnerText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            spinnerText.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 20),
            
            blackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            blackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            blackView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            blackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            self.sceneView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.sceneView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.sceneView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.sceneView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        startARExperience()
    }
    
    @objc func giveUpGame() {
        
        self.view.layer.removeAllAnimations()
        
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        
        present(StartView(), animated: true, completion: nil)
    }
    
    @objc func addBoardButtonWasPressed(_ sender: UIButton) {
        
        if planeAnchors.count == 1 {
            
            let planePosition = planeAnchors[0].1.transform.columns.3 //Plane Position in the world
            guard let cameraAngle = self.sceneView.session.currentFrame?.camera.eulerAngles else {
                return
            }
                
            self.sceneView.session.remove(anchor: planeAnchors[0].0)
            planeAnchors.removeAll()
            
            configuration.planeDetection = []
            self.sceneView.session.run(configuration, options: [.removeExistingAnchors])
            
            //The board can be placed on this surface.
            let gameBoard = memoryGame.getGameBoard()
            gameBoard.position = SCNVector3(planePosition.x, planePosition.y, planePosition.z - 0.05)
            gameBoard.eulerAngles.y = cameraAngle.y

            self.sceneView.scene.rootNode.addChildNode(gameBoard)
            addBoardButton.isHidden = true
            
            humanPointsLabel.text = "You: 0 points"
            computerPointsLabel.text = "PC: 0 points"
            pointsView.isHidden = false
            
            userInstructionsView.layer.borderColor = UIColor.white.cgColor
            userInstructionLabel.text = ""
            
            startMemoryGame()
            //presentVictoryCelebrationView()
        }
    }
    
    @objc func turnCardUp(sender: UITapGestureRecognizer) {
        
        if !memoryGame.isComputerTurn {
            
            let sceneViewTappedOn = sender.view as! SCNView
            let touchCoordinates = sender.location(in: sceneViewTappedOn)
            
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
            if hitTest.isEmpty {
            }
            else {
                
                guard let hitTestResultNode = hitTest.first?.node, hitTestResultNode.name != "board", memoryGame.numberOfCardsTurnedUp() < 2 else {
                    return
                }
                
                print("Card was touched!")
                    
                let cards = memoryGame.getGameCards()
                for card in cards {
                    
                    if hitTestResultNode.name == card.characterName, !card.cardWasMatched(), !card.isCardTurnedUp() {
                        memoryGame.turnUpCard(card: card)
                    }
                }
            }
        }
    }
    
    func startARExperience() {
        
        configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        setUpCoachingExperience()
    }
    
    func startMemoryGame() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.observeMemoryGame()
            
            if self.memoryGame.isComputerTurn {
                self.memoryGame.nextPlay(changesPlayer: false)
            }
        }
    }
    
    func observeMemoryGame() {
        observers = [
            memoryGame.observe(\.isComputerTurn, options: [.initial]) { (memoryGame, change) in
                
                self.userInstructionLabel.text = ""
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.userInstructionLabel.text = memoryGame.isComputerTurn ? "Computer is Playing... 💭" : "It is your turn... 🤔"
                }
            },
            
            memoryGame.observe(\.gameHasEnded, options: [.initial]) { (memoryGame, change) in
                
                if memoryGame.gameHasEnded {
                    
                    let humanPoints = self.memoryGame.getHumanPlayerPoints()
                    let computerPoints = self.memoryGame.getComputerPlayerPoints()
                    
                    self.userInstructionLabel.text = "The game is finished..."
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        if humanPoints > computerPoints {
                            self.presentVictoryCelebrationView()
                        }
                        else {
                            self.presentDefeatParticleEmitter()
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        
                        memoryGame.removeCharacterInfo()
                        self.showGameFinishedAlert(humanPoints: humanPoints, computerPoints: computerPoints)
                    }
                }
            },
            
            memoryGame.observe(\.humanPlayerPoints, options: [.initial]) { (memoryGame, change) in
                
                let points = memoryGame.updateHumanNumberOfPoints()
                let previous = points.0
                let current = points.1
                
                if previous == current { return }
                
                if current > previous {
                    
                    self.pointsView.layer.borderColor = UIColor.systemGreen.cgColor
                    self.humanPointsLabel.textColor = UIColor.systemGreen
                }
                else {
                    self.pointsView.layer.borderColor = UIColor.systemRed.cgColor
                    self.humanPointsLabel.textColor = UIColor.systemRed
                }
                
                self.humanPointsLabel.text = "You: \(current) " + (current == 1 ? "point" : "points")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.pointsView.layer.borderColor = UIColor.white.cgColor
                    self.humanPointsLabel.textColor = UIColor.white
                }
            },
            
            memoryGame.observe(\.computerPlayer.numberOfPoints, options: [.initial]) { (memoryGame, change) in
                
                let points = memoryGame.computerPlayer.updateComputerNumberOfPoints()
                let previous = points.0
                let current = points.1
                
                if previous == current { return }
                
                if current > previous {
                    
                    self.pointsView.layer.borderColor = UIColor.systemGreen.cgColor
                    self.computerPointsLabel.textColor = UIColor.green
                }
                else {
                    self.pointsView.layer.borderColor = UIColor.systemRed.cgColor
                    self.computerPointsLabel.textColor = UIColor.systemRed
                }
                
                self.computerPointsLabel.text = "PC: \(current) " + (current == 1 ? "point" : "points")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.pointsView.layer.borderColor = UIColor.white.cgColor
                    self.computerPointsLabel.textColor = UIColor.white
                }
            }
        ]
    }
    
    func showGameFinishedAlert(humanPoints: Int, computerPoints: Int) {
        
        var title = ""
        var message = ""
        
        if humanPoints > computerPoints {
            title = "Congratulations! You WON! 🥇"
            message = "Well done! Keep exercising your memory!"
        }
        else {
            title = "Sorry! You LOST! 😢"
            message = "Better luck next time. Continue exercising your memory to improve your result!"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let exitGameAction = UIAlertAction(title: "Continue", style: .default) { _ in
            self.giveUpGame()
        }
        
        alertController.addAction(exitGameAction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func makePlaneGrid(anchor: ARPlaneAnchor) -> SCNNode {
        
        let surfaceWidth: CGFloat = CGFloat(anchor.extent.x)
        let surfaceHeight: CGFloat = CGFloat(anchor.extent.z)
        
        let gridPlane = SCNPlane(width: surfaceWidth, height: surfaceHeight)
        gridPlane.materials = [GridMaterial()]
        
        let gridNode = SCNNode()
        gridNode.geometry = gridPlane
        gridNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        gridNode.eulerAngles.x = -.pi / 2
        
        return gridNode
    }
    
    func presentDefeatParticleEmitter() {
        
        blackView.isHidden = false
        
        let blackViewAppearenceAnimation = CABasicAnimation(keyPath: "opacity")
        blackViewAppearenceAnimation.fromValue = 0
        blackViewAppearenceAnimation.toValue = 1
        blackViewAppearenceAnimation.duration = 2
        blackView.layer.add(blackViewAppearenceAnimation, forKey: "opacity")
        
        let skView = SKView()
        self.blackView.addSubview(skView)
        self.blackView.bringSubviewToFront(skView)
        
        skView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        let particleScene = ParticleScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        particleScene.scaleMode = .aspectFill
        particleScene.backgroundColor = .clear
        
        skView.presentScene(particleScene)
    }
    
    func presentVictoryCelebrationView() {
        
        blackView.isHidden = false
        
        let blackViewAppearenceAnimation = CABasicAnimation(keyPath: "opacity")
        blackViewAppearenceAnimation.fromValue = 0
        blackViewAppearenceAnimation.toValue = 1
        blackViewAppearenceAnimation.duration = 2
        blackView.layer.add(blackViewAppearenceAnimation, forKey: "opacity")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            for _ in 1 ... 50 {
                
                let objectView = UIView()
                objectView.translatesAutoresizingMaskIntoConstraints = false
                objectView.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height + 100, width: 20, height: 100)
                
                let ballon = UILabel()
                ballon.translatesAutoresizingMaskIntoConstraints = false
                ballon.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height + 100, width: 20, height: 100)
                ballon.text = "🎈"
                ballon.font = UIFont.systemFont(ofSize: 60)
                objectView.addSubview(ballon)
                
                NSLayoutConstraint.activate([
                    ballon.centerXAnchor.constraint(equalTo: objectView.centerXAnchor),
                    ballon.centerYAnchor.constraint(equalTo: objectView.centerYAnchor)
                ])
                
                self.blackView.addSubview(objectView)
                self.blackView.bringSubviewToFront(objectView)
                
                let randomXOffset = Int.random(in: -Int(UIScreen.main.bounds.width / 1.5) + 100 ..< Int(UIScreen.main.bounds.width / 1.5) - 100)
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: randomXOffset, y: Int(UIScreen.main.bounds.height + 100)))
                path.addCurve(to: CGPoint(x: Int(UIScreen.main.bounds.width / 2) + randomXOffset, y: -300), controlPoint1: CGPoint(x: randomXOffset - 300, y: 600), controlPoint2: CGPoint(x: randomXOffset + 450, y: 300))
                
                let animation = CAKeyframeAnimation(keyPath: "position")
                animation.path = path.cgPath
                animation.repeatCount = 1
                animation.duration = Double.random(in: 4.0 ..< 7.0)
                
                let delegate = BallonAnimationDelegate()
                delegate.didFinishAnimation = {
                    objectView.removeFromSuperview()
                }
                animation.delegate = delegate
                
                objectView.layer.add(animation, forKey: "animate position along path")
            }
        }
    }
    
    //Plane anchor encodes orientation and size of a surface
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !memoryGame.isCardSetSet() {
            
            if let imageAnchor = anchor as? ARImageAnchor {
                
                guard let imageName = imageAnchor.referenceImage.name else {
                    return
                }
                
                print("Card set: \(imageName)")
                
                self.memoryGame.setNewCardSet(cardSet: imageName)
                
                DispatchQueue.main.async {
                    self.spinner.startAnimating()
                    self.spinner.isHidden = false
                    self.spinnerText.isHidden = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                    self.spinnerText.isHidden = true
                    self.addBoardButton.isHidden = false
                    self.userInstructionLabel.text = "Move your iPhone around to find surfaces..."
                }
                
                self.sceneView.scene.rootNode.enumerateChildNodes { childNode, _ in
                    childNode.removeFromParentNode()
                }
            }
        }
        else {
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
            
            for oldAnchor in planeAnchors {
                
                if oldAnchor.0.identifier != anchor.identifier {
                    sceneView.session.remove(anchor: oldAnchor.0)
                }
            }
            
            planeAnchors.removeAll()
            
            let newGrid = makePlaneGrid(anchor: planeAnchor)
            node.addChildNode(newGrid)
            
            planeAnchors.append((anchor, planeAnchor))
            
            DispatchQueue.main.async {
                
                let planeWidth = planeAnchor.extent.x
                let planeheight = planeAnchor.extent.z
                
                self.userInstructionLabel.text = ""
                self.userInstructionsView.layer.borderColor = UIColor.white.cgColor
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if planeWidth >= 0.43, planeheight >= 0.30 {
                        self.userInstructionLabel.text = "You can place the board on this surface."
                        self.userInstructionsView.layer.borderColor = UIColor.systemGreen.cgColor
                        self.addBoardButton.isEnabled = true
                    }
                    else {
                        self.userInstructionLabel.text = "You can not place the board on this surface."
                        self.userInstructionsView.layer.borderColor = UIColor.systemRed.cgColor
                        self.addBoardButton.isEnabled = false
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if memoryGame.isCardSetSet() {
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
            
            node.enumerateChildNodes { childNode, _ in
                childNode.removeFromParentNode()
            }
            
            let newGrid = makePlaneGrid(anchor: planeAnchor)
            node.addChildNode(newGrid)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
        if memoryGame.isCardSetSet() {
            
            guard let _ = anchor as? ARPlaneAnchor else {
                return
            }
            
            node.enumerateChildNodes { childNode, _ in
                childNode.removeFromParentNode()
            }
        }
    }
}
