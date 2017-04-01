//
//  GameViewController.swift
//  Spacevade
//
//  Created by Santiago Castano M. on 10/20/16.
//  Copyright (c) 2016 Santiago Castano M. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuScene = MenuScene(size: view.bounds.size)
        let gameScene = GameScene(size: view.bounds.size)
        playMusic()
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        gameScene.scaleMode = .AspectFill
        
        skView.presentScene(menuScene)
        skView.showsNodeCount = false
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    func playMusic()
    {
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
