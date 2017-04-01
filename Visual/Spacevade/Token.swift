//
//  Token.swift
//  Spacevade
//
//  Created by Santiago Castano M. on 10/22/16.
//  Copyright (c) 2016 Santiago Castano M. All rights reserved.
//

import Foundation
import SpriteKit

class Token: SKSpriteNode {
    
    init(imageNamed: String) {
        
        let texture = SKTexture(imageNamed: "\(imageNamed)")
        
        super.init(texture: texture, color: UIColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}