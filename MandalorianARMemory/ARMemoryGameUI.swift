//
//  ViewController.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 08/04/2021.
//

import UIKit
import ARKit

class ARMemoryGameUI: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    var planeAnchors = [(ARAnchor, ARPlaneAnchor)]()
    
    let configuration = ARWorldTrackingConfiguration()

    var memoryGame: MemoryGame!
    var observers = [NSKeyValueObservation]()
    
    let turnLabelWidth: CGFloat = 250
    let turnLabelHeight: CGFloat = 40
    
    let mandalorianLogoImage = UIImageView()
    let backButton = UIButton(type: .system)
    let playButton = UIButton(type: .system)
    let addBoardButton = UIButton(type: .system)
    let endGameButton = UIButton(type: .system)
    let difficultyButtonsRow = UIView()
    
    let userInstructionsView = UIView()
    let userInstructionLabel = UILabel()
    
    let spinner = UIActivityIndicatorView()
    let spinnerText = UILabel()
    
    let pointsView = UIView()
    let humanPointsLabel = UILabel()
    let computerPointsLabel = UILabel()
    
    let coachingOverlay = ARCoachingOverlayView()
    
    var quitInTheMiddle: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.sceneView.delegate = self
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.sceneView.isHidden = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(turnCardUp))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        mandalorianLogoImage.translatesAutoresizingMaskIntoConstraints = false
        mandalorianLogoImage.contentMode = .scaleAspectFit
        mandalorianLogoImage.image = UIImage(named: "mandalorian_logo")
        self.view.addSubview(mandalorianLogoImage)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 23)
        playButton.backgroundColor = UIColor.systemBlue
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 3.5
        playButton.layer.cornerRadius = 30
        playButton.addTarget(self, action: #selector(playButtonWasPressed), for: .touchUpInside)
        self.view.addSubview(playButton)
        
        let easyButton = UIButton(type: .system)
        easyButton.setTitle("Easy", for: .normal)
        easyButton.setTitleColor(.white, for: .normal)
        easyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        easyButton.backgroundColor = UIColor.systemGreen
        easyButton.layer.borderColor = UIColor.white.cgColor
        easyButton.layer.borderWidth = 2.5
        easyButton.layer.cornerRadius = 25
        easyButton.addTarget(self, action: #selector(startARExperience), for: .touchUpInside)
        easyButton.frame = CGRect(x: 0, y: 0, width: 190, height: 50)
        difficultyButtonsRow.addSubview(easyButton)
        
        let mediumButton = UIButton(type: .system)
        mediumButton.setTitle("Medium", for: .normal)
        mediumButton.setTitleColor(.white, for: .normal)
        mediumButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        mediumButton.backgroundColor = UIColor.systemYellow
        mediumButton.layer.borderColor = UIColor.white.cgColor
        mediumButton.layer.borderWidth = 2.5
        mediumButton.layer.cornerRadius = 25
        mediumButton.addTarget(self, action: #selector(startARExperience), for: .touchUpInside)
        mediumButton.frame = CGRect(x: 230, y: 0, width: 190, height: 50)
        difficultyButtonsRow.addSubview(mediumButton)
        
        let hardButton = UIButton(type: .system)
        hardButton.setTitle("Hard", for: .normal)
        hardButton.setTitleColor(.white, for: .normal)
        hardButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        hardButton.backgroundColor = UIColor.systemRed
        hardButton.layer.borderColor = UIColor.white.cgColor
        hardButton.layer.borderWidth = 2.5
        hardButton.layer.cornerRadius = 25
        hardButton.addTarget(self, action: #selector(startARExperience), for: .touchUpInside)
        hardButton.frame = CGRect(x: 460, y: 0, width: 190, height: 50)
        difficultyButtonsRow.addSubview(hardButton)
        difficultyButtonsRow.isHidden = true
        
        difficultyButtonsRow.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(difficultyButtonsRow)
        
        let placeBoardImage = UIImage(systemName: "plus.viewfinder")
        addBoardButton.translatesAutoresizingMaskIntoConstraints = false
        addBoardButton.setBackgroundImage(placeBoardImage, for: .normal)
        addBoardButton.addTarget(self, action: #selector(addBoardButtonWasPressed), for: .touchUpInside)
        addBoardButton.isHidden = true
        self.view.addSubview(addBoardButton)
        
        let backButtonImage = UIImage(systemName: "arrow.backward.circle.fill")?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setBackgroundImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonWasPressed), for: .touchUpInside)
        backButton.isHidden = true
        self.view.addSubview(backButton)
        
        let endGameImage = UIImage(systemName: "xmark.circle.fill")?.withTintColor(UIColor.red, renderingMode: .alwaysOriginal)
        endGameButton.translatesAutoresizingMaskIntoConstraints = false
        endGameButton.setBackgroundImage(endGameImage, for: .normal)
        endGameButton.addTarget(self, action: #selector(giveUpGame), for: .touchUpInside)
        endGameButton.isHidden = true
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
        
        NSLayoutConstraint.activate([
            
            mandalorianLogoImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            mandalorianLogoImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            mandalorianLogoImage.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.35),
            mandalorianLogoImage.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            
            backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35),
            backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30),
            backButton.widthAnchor.constraint(equalToConstant: 45),
            backButton.heightAnchor.constraint(equalToConstant: 45),
            
            endGameButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35),
            endGameButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30),
            endGameButton.widthAnchor.constraint(equalToConstant: 45),
            endGameButton.heightAnchor.constraint(equalToConstant: 45),
            
            playButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -65),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            playButton.widthAnchor.constraint(equalToConstant: 280),
            
            difficultyButtonsRow.widthAnchor.constraint(equalToConstant: 190 * 3 + 40 * 2),
            difficultyButtonsRow.heightAnchor.constraint(equalToConstant: 45),
            difficultyButtonsRow.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            difficultyButtonsRow.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -65),
            
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
            
            self.sceneView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.sceneView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.sceneView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.sceneView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    @objc func playButtonWasPressed(_ sender: UIButton) {
        
        playButton.isHidden = true
        difficultyButtonsRow.isHidden = false
        backButton.isHidden = false
    }

    @objc func backButtonWasPressed(_ sender: UIButton) {
        
        playButton.isHidden = false
        difficultyButtonsRow.isHidden = true
        backButton.isHidden = true
    }
    
    @objc func giveUpGame() {
        
        if !memoryGame.gameHasEnded {
            quitInTheMiddle = true
        }
        
        self.view.layer.removeAllAnimations()
        
        self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        
        mandalorianLogoImage.isHidden = false
        playButton.isHidden = false
        
        endGameButton.isHidden = true
        addBoardButton.isHidden = true
        userInstructionsView.isHidden = true
        pointsView.isHidden = true
        
        self.sceneView.session.pause()
        self.sceneView.isHidden = true
        
        memoryGame.gameHasEnded = true
    }
    
    @objc func addBoardButtonWasPressed(_ sender: UIButton) {
        
        print("Button was pressed!")
        
        if planeAnchors.count == 1 {
            
            let planePosition = planeAnchors[0].1.transform.columns.3 //Plane Position in the world
                
            self.sceneView.session.remove(anchor: planeAnchors[0].0)
            planeAnchors.removeAll()
            
            configuration.planeDetection = []
            self.sceneView.session.run(configuration, options: [.removeExistingAnchors])
            
            //The board can be placed on this surface.
            let gameBoard = memoryGame.getGameBoard()
            gameBoard.position = SCNVector3(planePosition.x, planePosition.y, planePosition.z - 0.05)

            self.sceneView.scene.rootNode.addChildNode(gameBoard)
            addBoardButton.isHidden = true
            
            humanPointsLabel.text = "You: 0 points"
            computerPointsLabel.text = "PC: 0 points"
            pointsView.isHidden = false
            
            userInstructionsView.layer.borderColor = UIColor.white.cgColor
            userInstructionLabel.text = ""
            
            startMemoryGame()
        }
    }
    
    @objc func turnCardUp(sender: UITapGestureRecognizer) {
        
        if memoryGame != nil, !memoryGame.isComputerTurn {
            
            let sceneViewTappedOn = sender.view as! SCNView
            let touchCoordinates = sender.location(in: sceneViewTappedOn)
            
            let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
            if hitTest.isEmpty {
                print("Did not touch any card.")
            }
            else {
                
                guard let hitTestResultNode = hitTest.first?.node, hitTestResultNode.name != "board", memoryGame.numberOfCardsTurnedUp() < 2 else {
                    print("Did not touch a card.")
                    return
                }
                
                print("Touched a card!")
                    
                let cards = memoryGame.getGameCards()
                for card in cards {
                    
                    if hitTestResultNode.name == card.characterName, !card.cardFoundMatch, !card.cardIsUp {
                        memoryGame.turnUpCard(card: card)
                    }
                }
            }
        }
    }
    
    @objc func startARExperience(_ sender: UIButton) {
        
        print("Aqui!")
        
        switch sender.currentTitle {
        case "Easy":
            memoryGame = MemoryGame(initialNumberOfCards: 5, gameDifficulty: GameDifficulty.easy)
            break
        case "Medium":
            memoryGame = MemoryGame(initialNumberOfCards: 5, gameDifficulty: GameDifficulty.medium)
            break
        case "Hard":
            memoryGame = MemoryGame(initialNumberOfCards: 5, gameDifficulty: GameDifficulty.hard)
            break
        default:
            break
        }
        
        self.sceneView.isHidden = false
        
        configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        setUpCoachingExperience()
        
        mandalorianLogoImage.isHidden = true
        difficultyButtonsRow.isHidden = true
        backButton.isHidden = true
        
        endGameButton.isHidden = false
    }
    
    func startMemoryGame() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
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
                
                if memoryGame.gameHasEnded, !self.quitInTheMiddle {
                    
                    self.userInstructionLabel.text = "The game is finished..."
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        
                        memoryGame.removeCharacterInfo()
                        self.showGameFinishedAlert(humanPoints: self.memoryGame.getHumanPlayerPoints(), computerPoints: self.memoryGame.getComputerPlayerPoints())
                    }
                }
                
                self.quitInTheMiddle = false
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
        
        guard let _ = memoryGame else {
            return
        }
        
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
        //print(surfaceWidth)
        let surfaceHeight: CGFloat = CGFloat(anchor.extent.z)
        //print(surfaceHeight)
        
        let gridPlane = SCNPlane(width: surfaceWidth, height: surfaceHeight)
        gridPlane.materials = [GridMaterial()]
        
        let gridNode = SCNNode()
        gridNode.geometry = gridPlane
        gridNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        gridNode.eulerAngles.x = -.pi / 2
        
        return gridNode
    }
    
    //Plane anchor encodes orientation and size of a surface
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !memoryGame.isCardSetSet() {
            
            if let imageAnchor = anchor as? ARImageAnchor {
                
                guard let imageName = imageAnchor.referenceImage.name else {
                    return
                }
                
                print(imageName)
                
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

extension SCNNode {
    
    var width: Float {
        return (boundingBox.max.x - boundingBox.min.x) * scale.x
    }
    
    var height: Float {
        return (boundingBox.max.y - boundingBox.min.y) * scale.y
    }
    
    func pivotOnTopLeft() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(min.x, (max.y - min.y) + min.y, 0)
    }
    
    func pivotOnTopCenter() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, (max.y - min.y) + min.y, 0)
    }
}
