//
//  CongratulationsScene.swift
//  Spacevade
//
//  Created by Santiago Castaño M on 11/27/16.
//  Copyright © 2016 Santiago Csataño. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

class CongratulationsScene: SKScene {
    var music: SKAudioNode?
    override func didMoveToView(view: SKView) {
        //Prepara la escena
        self.music = SKAudioNode(URL: NSBundle.mainBundle().URLForResource("music", withExtension: "mp3")!)
        if self.music != nil {
            addChild(self.music!)
        }

        self.backgroundColor = SKColor.blackColor()
        
        let rotateAction = SKAction.rotateByAngle(1, duration: 0.6)
        let repeatRotation = SKAction.repeatActionForever(rotateAction)
        
        let congratsLabel = SKLabelNode(fontNamed: "Impact")
        congratsLabel.text = "Congratulations!!!"
        congratsLabel.fontColor = UIColor.whiteColor()
        congratsLabel.fontSize = 55
        congratsLabel.position = CGPointMake(self.size.width/2, (self.size.height/5)*4)
        
        let heroLogo = SKSpriteNode(imageNamed: "Spaceship")
        heroLogo.position = CGPointMake(CGRectGetMidX(self.frame), (self.size.height/5)*2.5)
        heroLogo.size.height = 80
        heroLogo.size.width = 80
        
        
        let restartButton = SKLabelNode(fontNamed: "Impact")
        restartButton.position = CGPointMake(self.size.width*0.25, (self.size.height/5))
        restartButton.name = "restartButton"
        restartButton.text = "Restart"
        restartButton.fontSize = 40
        restartButton.fontColor = UIColor.blueColor()
        
        let menuButton = SKLabelNode(fontNamed: "Impact")
        menuButton.position = CGPointMake(self.size.width*0.75, (self.size.height/5))
        menuButton.name = "menuButton"
        menuButton.text = "Menu"
        menuButton.fontSize = 40
        menuButton.fontColor = UIColor.redColor()
        
        
        self.addChild(congratsLabel)
        self.addChild(heroLogo)
        heroLogo.runAction(repeatRotation)
        self.addChild(restartButton)
        self.addChild(menuButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches
        let location = touch.first!.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        // Se inicia el juego si se toca el "Start"
        if (node.name == "restartButton") {
            let gameScene = GameScene(size: self.size)
            let transition = SKTransition.fadeWithDuration(1.0)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
        }
        else if(node.name == "menuButton"){
            let menuScene = MenuScene(size: self.size)
            let transition = SKTransition.fadeWithDuration(1.0)
            menuScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(menuScene, transition: transition)
        }
        
    }
}
