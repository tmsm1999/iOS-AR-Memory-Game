//
//  StartView.swift
//  MandalorianARMemory
//
//  Created by Tomás Mamede on 02/05/2021.
//

import Foundation
import UIKit

class StartView: UIViewController {
    
    let playButton = UIButton(type: .system)
    let backButton = UIButton(type: .system)
    
    let difficultyButtonsRow = UIView()
    let appTitle = UILabel()
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.black
        
        appTitle.translatesAutoresizingMaskIntoConstraints = false
        appTitle.font = UIFont.boldSystemFont(ofSize: 70)
        appTitle.text = "AR Memory"
        appTitle.textColor = UIColor.white
        appTitle.textAlignment = .center
        self.view.addSubview(appTitle)
        
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
        
        difficultyButtonsRow.translatesAutoresizingMaskIntoConstraints = false
        difficultyButtonsRow.isHidden = true
        self.view.addSubview(difficultyButtonsRow)
        
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
        
        let backButtonImage = UIImage(systemName: "arrow.backward.circle.fill")?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setBackgroundImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonWasPressed), for: .touchUpInside)
        backButton.isHidden = true
        self.view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            
            appTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            appTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appTitle.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.35),
            appTitle.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            
            difficultyButtonsRow.widthAnchor.constraint(equalToConstant: 190 * 3 + 40 * 2),
            difficultyButtonsRow.heightAnchor.constraint(equalToConstant: 45),
            difficultyButtonsRow.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            difficultyButtonsRow.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -65),
            
            playButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -65),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            playButton.widthAnchor.constraint(equalToConstant: 280),
            
            backButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35),
            backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30),
            backButton.widthAnchor.constraint(equalToConstant: 45),
            backButton.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
    
    @objc func startARExperience(_ sender: UIButton) {
        let memoryGameARViewController = ARMemoryGameUI()
        present(memoryGameARViewController, animated: true, completion: nil)
    }
    
    @objc func playButtonWasPressed(_ sender: UIButton) {
        playButton.isHidden = true
        backButton.isHidden = false
        difficultyButtonsRow.isHidden = false
    }
    
    @objc func backButtonWasPressed(_ sender: UIButton) {
        playButton.isHidden = false
        backButton.isHidden = true
        difficultyButtonsRow.isHidden = true
    }
    
}
