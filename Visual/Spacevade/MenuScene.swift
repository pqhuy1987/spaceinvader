//
//  MenuScene.swift
//  Spacevade
//
//  Created by Santiago Castaño M on 11/26/16.
//  Copyright © 2016 Santiago Castaño. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

class MenuScene: SKScene {
    var music: SKAudioNode?

    override func didMoveToView(view: SKView) {
        //Prepara la escena
        
        
        self.backgroundColor = SKColor.blackColor()
        
        
        let heroLogo = SKSpriteNode(imageNamed: "Spaceship")
        heroLogo.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height * 0.75)
        heroLogo.size.height = 100
        heroLogo.size.width = 100
        
        let playButton = SKLabelNode(fontNamed: "Impact")
        playButton.position = CGPointMake(self.size.width/2, (self.size.height/2)-35)
        playButton.name = "playButton"
        playButton.text = "Start"
        playButton.fontSize = 40
        playButton.fontColor = UIColor.redColor()
        self.music = SKAudioNode(URL: NSBundle.mainBundle().URLForResource("music", withExtension: "mp3")!)
        if self.music != nil {
            addChild(self.music!)
        }
        
        self.addChild(heroLogo)
        self.addChild(playButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches
        let location = touch.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        // Se inicia el juego si se toca el "Start"
        if (node.name == "playButton") {
            let gameScene = GameScene(size: self.size)
            let transition = SKTransition.fadeWithDuration(1.0)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
        }
        
    }
}
