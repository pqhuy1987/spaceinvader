        //
        //  GameScene.swift
        //  Spacevade
        //
        //  Created by Santiago Castano M. on 10/20/16.
        //  Copyright (c) 2016 Santiago Castano M. All rights reserved.
        //
        
        import SpriteKit
        import Foundation
        import UIKit
        
        
        
        //Bodytype: define cada tipo de cuerpo en el juego como entidad.
        //Struct: Class que no tiene acciones para ejecutar, solo define una entidad con caracteristicas.
        struct Bodytype {
            
            //None: Creado para definir una acción nula y tener un "Default"
            //Meteor: Enemigo del juego.
            //Bullet: Bala lanzada por el Usuario
            //Token:  Medalla Que sale despues de eliminar un Meteor
            //Hero:   Usuario... Nave espacial!
            static let None: UInt32 = 0
            static let Meteor: UInt32 = 1
            static let Bullet: UInt32 = 2
            static let Token: UInt32 = 3
            static let Hero: UInt32 = 4
            
        }
        
        //GameScene es la "Escena" del juego. En esta Escena salen los personajes y todas las
        //caracteristicas del juego. Background, "Score: 0", "Lives: 3", "Energy: 0".
        //Escrito en INTs y en Labels(Labels = Maneras de desplegar un String a la pantalla del usuario).
        
        class GameScene: SKScene, SKPhysicsContactDelegate {
            var music: SKAudioNode?
            let hero = SKSpriteNode(imageNamed: "Spaceship")
            let heroSpeed: CGFloat = 100.0
            var ammoLeft = 30
            var scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            var levelCount = 1
            var levelCountLabel = SKLabelNode(fontNamed: "Chalkduster")
            var livesLabel = SKLabelNode(fontNamed: "Chalkduster")
            var livesCounter = 3
            var gameIsOver = false
            var gotHit: Bool = false
            var livesLost = 0
            var bgImage = SKSpriteNode(imageNamed: "Bg")
            var meteorScore = 0

            
            
            //Función otorgada por XCode para definir todo lo que pasa cuando el usuario entra al juego.
            //Se usa addChild(Object) para agregar objetos a la pantalla.
            override func didMoveToView(view: SKView) {
                //Corre musica
                self.music = SKAudioNode(URL: NSBundle.mainBundle().URLForResource("music", withExtension: "mp3")!)
                if self.music != nil {
                    addChild(self.music!)
                }
                self.backgroundColor = SKColor.blackColor()
                //Se establese la foto de fondo.
                addChild(bgImage)
                bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
                bgImage.zPosition = 0
                //Se establese la posición del background en la pantalla
                //Para todos los objetos:
                //(OBJECT).position = Punto(x,y)
                //(OBJECT).zPostion = el valor de profundidad (front, back) se da en valores
                //    numericos igual que (x,y,z)
                
                
                //xCoord y yCoord son las coordenadas (x,y) del centro de la pantalla.
                let xCoord = size.width * 0.5
                let yCoord = size.height * 0.5
                
                //Caracteristicas para la nave espacial
                hero.size.height = 50
                hero.size.width = 50
                hero.position = CGPoint(x: xCoord, y: yCoord)
                hero.zPosition = 9
                
                //Declara a "hero" como un objeto que puede ser afectado por leyes de la fisica.
                hero.physicsBody = SKPhysicsBody(rectangleOfSize: hero.size)
                hero.physicsBody?.dynamic = true
                hero.physicsBody?.categoryBitMask = Bodytype.Hero
                hero.physicsBody?.contactTestBitMask = Bodytype.Meteor
                hero.physicsBody?.collisionBitMask = 0
                addChild(hero)
                
                //Estos LETs definen las acciones del usuario para mover la nave espacial:
                // Up, Down, Left, Right
                //Puede ser confuso.
                
                //let (nombreDeVariable: (deTipoUISwipeGesture...) = UISwipeGestureRecog...(EnPantalla, corre la funcion: swipedUp))
                //las funciones "Swiped" estan definidas más abajo.
                let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: ("swipedUp:"))
                swipeUp.direction = .Up
                view.addGestureRecognizer(swipeUp)
                
                let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: ("swipedDown:"))
                swipeDown.direction = .Down
                view.addGestureRecognizer(swipeDown)
                
                let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: ("swipedRight:"))
                swipeRight.direction = .Right
                view.addGestureRecognizer(swipeRight)
                
                let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: ("swipedLeft:"))
                swipeLeft.direction = .Left
                view.addGestureRecognizer(swipeLeft)
                
                //Se agregan meteoros infinitos. La función addMeteor(),meteorPerLevel() esta más abajo.
                meteorPerLevel()
                
                //Se define la gravedad del mundo inicial hacia el centro de la pantalla, pero luego cambia.
                physicsWorld.gravity = CGVectorMake(0,0)
                physicsWorld.contactDelegate = self
                
                //Caracteristicas de los marcadores del HUD.
                scoreLabel.fontColor = UIColor.whiteColor()
                scoreLabel.fontSize = 15
                scoreLabel.position = CGPointMake(self.size.width-50, self.size.height-25)
                scoreLabel.zPosition = 1
                scoreLabel.text = "Score: \(0)"
                levelCountLabel.fontColor = UIColor.whiteColor()
                levelCountLabel.fontSize = 15
                levelCountLabel.position = CGPointMake(50, self.size.height-25)
                levelCountLabel.zPosition = 1
                levelCountLabel.text = "Level: \(levelCount)"
                livesLabel.fontColor = UIColor.whiteColor()
                livesLabel.fontSize = 15
                livesLabel.position = CGPointMake(50, 25)
                livesLabel.zPosition = 1
                livesLabel.text = "Lives: \(3)"
                addChild(livesLabel)
                addChild(scoreLabel)
                addChild(levelCountLabel)
            }
            
            //funcion para generar un numero random más simple que la original.
            func random() -> CGFloat {
                
                return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
                
            }
            
            //Función para agregar meteors.
            func addMeteor() {
                var meteor: Enemy
                
                //Se le da la imagen, el lado de pantalla que saldra hacia el "hero", y el tamaño.
                meteor = Enemy(imageNamed: "MeteorLeft")
                meteor.size.height = 28
                meteor.size.width = 40
                let side = Int(arc4random_uniform(4))
                
                //Valores random en X y Y para que los Meteors salgan de todos lados desde cualquier angulo.
                //Se usan en el switch abajo.
                let randomX : CGFloat
                let randomY : CGFloat
                
                
                //Switch para que toma un valor random para establecer el lado del que sale el Meteor.
                switch(side)
                {
                //Up
                case 0:
                    //la posición X del meteoro se define random ya que el Meteoro entrará de arriba hacia abajo. meteor.position
                    randomX = random() * ((size.width - meteor.size.width/2) - meteor.size.width/2) + meteor.size.width/2
                    meteor.position = CGPoint(x: randomX, y: size.height + meteor.size.height/2)
                    meteor.zPosition = 8
                    var moveMeteor: SKAction
                    
                    //Se declara un punto en la pantalla (ubicacion del usuario) que es hacia donde sale el Meteor.
                    let vector : CGVector = CGVectorMake((hero.position.x - meteor.position.x)*10, (hero.position.y - meteor.position.y)*10)
                    
                    //variable que guarda la acción que hara el Meteor (Vector y cuanto tardara en llegar)
                    
                    switch(levelCount){
                    case 2:
                        moveMeteor = SKAction.moveBy(vector, duration: 15.0)
                        break
                    case 3:
                        moveMeteor = SKAction.moveBy(vector, duration: 12.0)
                        break
                    default:
                        moveMeteor = SKAction.moveBy(vector, duration: 25.0)
                        break
                    }
                    
                    //Se corre la acción con todas las caracteristicas definidas.
                    meteor.runAction(SKAction.sequence([moveMeteor, SKAction.removeFromParent()]))
                    break
                //Down
                case 1:
                    randomX = random() * ((size.width - meteor.size.width/2) - meteor.size.width/2) + meteor.size.width/2
                    meteor.position = CGPoint(x: randomX, y: 0 - meteor.size.width/2)
                    meteor.zPosition = 8
                    
                    var moveMeteor: SKAction
                    
                    let vector : CGVector = CGVectorMake((hero.position.x - meteor.position.x)*10, (hero.position.y - meteor.position.y)*10)
                    
                    switch(levelCount){
                    case 2:
                        moveMeteor = SKAction.moveBy(vector, duration: 15.0)
                        break
                    case 3:
                        moveMeteor = SKAction.moveBy(vector, duration: 12.0)
                        break
                    default:
                        moveMeteor = SKAction.moveBy(vector, duration: 25.0)
                        break
                    }
                    meteor.runAction(SKAction.sequence([moveMeteor, SKAction.removeFromParent()]))
                    break
                //Left
                case 2:
                    
                    randomY = random() * ((size.height - meteor.size.height/2) - meteor.size.height/2) + meteor.size.height/2
                    meteor.position = CGPoint(x: 0 - meteor.size.width/2, y: randomY)
                    meteor.zPosition = 8
                    
                    var moveMeteor: SKAction
                    
                    let vector : CGVector = CGVectorMake((hero.position.x - meteor.position.x)*10, (hero.position.y - meteor.position.y)*10)
                    
                    switch(levelCount){
                    case 2:
                        moveMeteor = SKAction.moveBy(vector, duration: 15.0)
                        break
                    case 3:
                        moveMeteor = SKAction.moveBy(vector, duration: 12.0)
                        break
                    default:
                        moveMeteor = SKAction.moveBy(vector, duration: 25.0)
                        break
                    }
                    
                    meteor.runAction(SKAction.sequence([moveMeteor, SKAction.removeFromParent()]))
                    break
                //Right
                case 3:
                    
                    randomY = random() * ((size.height - meteor.size.height/2) - meteor.size.height/2) + meteor.size.height/2
                    meteor.position = CGPoint(x: size.width + meteor.size.width/2, y: randomY)
                    meteor.zPosition = 8
                    
                    var moveMeteor: SKAction
                    
                    let vector : CGVector = CGVectorMake((hero.position.x - meteor.position.x)*10, (hero.position.y - meteor.position.y)*10)
                    
                    switch(levelCount){
                    case 2:
                        moveMeteor = SKAction.moveBy(vector, duration: 15.0)
                        break
                    case 3:
                        moveMeteor = SKAction.moveBy(vector, duration: 12.0)
                        break
                    default:
                        moveMeteor = SKAction.moveBy(vector, duration: 25.0)
                        break
                    }
                    meteor.runAction(SKAction.sequence([moveMeteor, SKAction.removeFromParent()]))
                    break
                default:
                    
                    break
                }
                
                addChild(meteor)
                //Se le da cuerpo físico al Meteor
                meteor.physicsBody = SKPhysicsBody(rectangleOfSize: meteor.size)
                meteor.physicsBody?.dynamic = true
                meteor.physicsBody?.categoryBitMask = Bodytype.Meteor
                meteor.physicsBody?.contactTestBitMask = Bodytype.Bullet
                meteor.physicsBody?.collisionBitMask = 0
                
            }
            
            override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
                let touch = touches
                let location = touch.first!.locationInNode(self)
                let node = self.nodeAtPoint(location)
                
                // Se reinicia el juego si se toca el "Restart"
                if (node.name == "restartButton") {
                    let gameScene = GameScene(size: self.size)
                    let transition = SKTransition.fadeWithDuration(1.0)
                    gameScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(gameScene, transition: transition)
                }
                
            }
            
            override func update(currentTime: CFTimeInterval) {
            }
            
            //Función que corre cuando el usuario hace un click en la pantalla
            override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
                
                //Se declada un nuevo node(Bullet) y se le dan todas sus caracterisitcas fisicas.
                let bullet = SKSpriteNode()
                bullet.color = UIColor.redColor()
                bullet.size  = CGSize(width: 5,height: 5)
                bullet.position = CGPointMake(hero.position.x, hero.position.y)
                bullet.zPosition = 10
                bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
                bullet.physicsBody?.dynamic = true
                bullet.physicsBody?.categoryBitMask = Bodytype.Bullet
                bullet.physicsBody?.contactTestBitMask = Bodytype.Meteor
                bullet.physicsBody?.collisionBitMask = 0
                bullet.physicsBody?.usesPreciseCollisionDetection = true
                
                if (gameIsOver == false){
                    addChild(bullet)
                }
                
                //Se declara una variable para guardar la ubicación del lugar donde el usuario hizo un click.
                guard let touch = touches.first else {return }
                let touchLocation = touch.locationInNode(self)
                //Se crea un vector con la variable creada
                let vector = CGVectorMake(-(hero.position.x-touchLocation.x), -(hero.position.y-touchLocation.y))
                //Acción para lanzar la bala.
                let projectileAction = SKAction.sequence([
                    SKAction.repeatAction(SKAction.moveBy(vector, duration: 0.5), count: 10),
                    SKAction.waitForDuration(0.5),
                    SKAction.removeFromParent()
                    ])
                if (gameIsOver == false){
                bullet.runAction(projectileAction)
                }
            }
            
            //Funciones que describen lo que pasa cuando el usuario hace swipes.
            func swipedUp(sender:UISwipeGestureRecognizer){
                var actionMove: SKAction
                if (hero.position.y + heroSpeed >= size.height){
                    actionMove = SKAction.moveTo(CGPoint(x: hero.position.x, y: size.height - hero.size.height/2), duration: NSTimeInterval(0.5))
                }
                else {
                    actionMove = SKAction.moveTo(CGPoint(x: hero.position.x, y: hero.position.y + heroSpeed), duration: NSTimeInterval(0.5))
                }
                hero.runAction(actionMove)
                print("Up")
            }
            
            func swipedDown(sender:UISwipeGestureRecognizer){
                var actionMove: SKAction
                if (hero.position.y - heroSpeed <= 0){
                    actionMove = SKAction.moveTo(CGPoint(x: hero.position.x, y: size.height + hero.size.height/2), duration: NSTimeInterval(0.5))
                }
                else {
                    actionMove = SKAction.moveTo(CGPoint(x: hero.position.x, y: hero.position.y - heroSpeed), duration: NSTimeInterval(0.5))
                    
                }
                
                hero.runAction(actionMove)
                
                print("Down")
            }
            
            func swipedRight(sender:UISwipeGestureRecognizer){
                var actionMove: SKAction
                if (hero.position.x + heroSpeed >= size.width){
                    actionMove = SKAction.moveTo(CGPoint(x: size.width - hero.size.width/2, y: hero.position.y), duration: NSTimeInterval(0.5))
                }
                else {
                    actionMove = SKAction.moveTo(CGPoint(x: hero.position.x + heroSpeed, y: hero.position.y), duration: NSTimeInterval(0.5))
                    
                }
                
                
                hero.runAction(actionMove)
                
                print("Right")
            }
            
            func swipedLeft(sender:UISwipeGestureRecognizer){
                var actionMove : SKAction
                if (hero.position.x - heroSpeed <= 0){
                    actionMove = SKAction.moveTo(CGPoint(x: hero.size.width/2, y: hero.position.y), duration: NSTimeInterval(0.5))
                }
                else {
                    actionMove = SKAction.moveTo(CGPoint(x: hero.position.x - heroSpeed, y: hero.position.y), duration: NSTimeInterval(0.5))
                    
                }
                hero.runAction(actionMove)
                print("Left")
            }
            
            //función que describe lo que pasa cuando la bala le pega al Meteor.
            func bulletHitMeteor(bullet: SKSpriteNode, meteor: Enemy){
                
                //removeFromParent() borra el node de la pantalla.
                bullet.removeFromParent()
                meteor.removeFromParent()
                self.runAction(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                
                //Agrega puntos y cambia lo que dice el texto de scoreLabel.
                
                meteorScore += 1
                scoreLabel.text = "Score \(meteorScore)"
                
                //corre la acción que causa que salgan tokens cuando un Meteor se destrulle.
                explodeMeteor(meteor)
                
                if (meteorScore == 30){
                    newLevel()
                }
                else if(meteorScore == 50){
                    newLevel()
                }
                else if(meteorScore == 70){
                    removeActionForKey("meteorLoop")
                    removeAllChildren()
                    let congratsScene = CongratulationsScene(size: self.size)
                    let transition = SKTransition.fadeWithDuration(1.0)
                    congratsScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(congratsScene, transition: transition)
                }
                
                
            }
            
            //Función que declara lo que sucede cuando un meteoro le pega al Hero.
            func heroHitMeteor(player: SKSpriteNode, meteor: SKSpriteNode){
                
                //Variables para guardar intervalos de tiempo.
                let waitALittle : SKAction = SKAction.waitForDuration(0.2)
                let waitALong : SKAction = SKAction.waitForDuration(2.0)
                
                //Declara actividad cuando le pegan al Hero
                let gotHitted : SKAction = SKAction.runBlock({() -> Void in
                    self.gotHit = true
                })
                //Se inicia una acción para que la nave no pueda recibir daño por un tiempo.(Recuperación)
                let recoverFromHit : SKAction = SKAction.runBlock({() -> Void in
                    self.gotHit = false
                })
                
                //Acciones hideHero y showHero son para hacer parpadear la nave en rojo cuando pierde una vida.
                let hideHero : SKAction = SKAction.runBlock({() -> Void in
                    self.hero.color = UIColor.redColor()
                    self.hero.colorBlendFactor = 1
                })
                
                let showHero : SKAction = SKAction.runBlock({() -> Void in
                    
                    self.hero.color = UIColor.whiteColor()
                    
                })
                
                //Se quita el Meteor de la pantalla
                meteor.removeFromParent()
                //Se corre hideHero y showHero 5 veces.
                runAction(SKAction.repeatAction(SKAction.sequence([hideHero,waitALittle,showHero,waitALittle]), count: 5))
                
                //Corre sound effect "heroHit"
                runAction(SKAction.playSoundFileNamed("heroHit", waitForCompletion: false))
                
                //Se corre lo que pasa en el HUD cuando Hero pierde una vida.
                runAction(SKAction.sequence([gotHitted,waitALong,recoverFromHit]))
                livesCounter -= 1
                livesLabel.text = "Lives \(livesCounter)"
                livesLost += 1
                
                //Gameover si se acaban las vidas.
                if livesCounter <= 0{
                    gameOver()
                }
            }
            
            //Función que describe lo que pasa cuando el Hero choca con un Token.
            func heroHitToken(player: SKSpriteNode, token: SKSpriteNode){
                meteorScore = meteorScore + 3
                scoreLabel.text = "Score: \(meteorScore)"
                
                token.removeFromParent()
                if (meteorScore == 30){
                    newLevel()
                }
                else if(meteorScore == 50){
                    newLevel()
                }
                else if(meteorScore == 70){
                    removeActionForKey("meteorLoop")
                    removeAllChildren()
                    let congratsScene = CongratulationsScene(size: self.size)
                    let transition = SKTransition.fadeWithDuration(1.0)
                    congratsScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(congratsScene, transition: transition)
                }

            }
            
            //función llamada cuando se inicia contacto entre dos cuerpos
            func didBeginContact(contact: SKPhysicsContact) {
                
                //No entiendo estas 4 cosas
                let bodyA = contact.bodyA
                let bodyB = contact.bodyB
                let contactA = bodyA.categoryBitMask
                let contactB = bodyB.categoryBitMask
                
                
                switch contactA {
                    
                case Bodytype.Meteor:
                    
                    switch contactB {
                        
                    case Bodytype.Meteor:
                        break
                        
                    case Bodytype.Bullet:
                        if let bodyBNode = contact.bodyB.node as? SKSpriteNode, bodyANode = contact.bodyA.node as? Enemy {
                            bulletHitMeteor(bodyBNode, meteor: bodyANode)
                        }
                        
                    case Bodytype.Hero:
                        if let bodyBNode = contact.bodyB.node as? SKSpriteNode, bodyANode = contact.bodyA.node as? Enemy {
                            heroHitMeteor(bodyBNode, meteor: bodyANode)
                            
                        }
                        
                    case Bodytype.Token:
                        break
                        
                    default:
                        break
                    }
                    
                case Bodytype.Bullet:
                    
                    switch contactB {
                        
                    case Bodytype.Meteor:
                        if let bodyANode = contact.bodyA.node as? SKSpriteNode, bodyBNode = contact.bodyB.node as? Enemy {
                            bulletHitMeteor(bodyANode, meteor: bodyBNode)
                        }
                        
                    case Bodytype.Bullet:
                        break
                        
                    case Bodytype.Hero:
                        break
                        
                    case Bodytype.Token:
                        break
                        
                    default:
                        break
                    }
                    
                case Bodytype.Hero:
                    
                    switch contactB {
                        
                    case Bodytype.Meteor:
                        if let bodyANode = contact.bodyA.node as? SKSpriteNode, bodyBNode = contact.bodyB.node as? Enemy {
                            if gotHit == false{
                                heroHitMeteor(bodyANode, meteor: bodyBNode)
                            }
                        }
                        
                    case Bodytype.Bullet:
                        break
                        
                        
                    case Bodytype.Token:
                        if let bodyANode = contact.bodyA.node as? SKSpriteNode, bodyBNode = contact.bodyB.node as? Token {
                            
                            heroHitToken(bodyANode, token: bodyBNode)
                            
                        }
                        
                    case Bodytype.Hero:
                        break
                        
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
                
            }
            
            
            //función crea tokens aleatoriamente cuando un Meteor se destruye.
            func explodeMeteor(meteor: Enemy){
                
                var tokens: [Token] = []
                let randomTokenAmountGenerator =  Int(arc4random_uniform(15) + 1)
                
                
                switch (randomTokenAmountGenerator){
                case 5,8,10,3:
                    for var i = 0; i < 1; i += 1 {
                        tokens.append(Token(imageNamed: "token"))
                    }
                    
                    
                case 8,1,2:
                    for var i = 0; i < 2; i += 1 {
                        tokens.append(Token(imageNamed: "token"))
                    }
                    
                    
                default:
                    break
                    
                }
                
                
                
                for token in tokens{
                    
                    let randomExplosionX = (random() * (1000 + size.width)) - size.width
                    
                    let randomExplosionY = (random() * (1000 + size.height)) - size.width
                    
                    
                    let moveExplosion: SKAction
                    moveExplosion = SKAction.moveTo(CGPoint(x: randomExplosionX, y: randomExplosionY), duration: NSTimeInterval(20))
                    
                    token.runAction(SKAction.sequence([moveExplosion, SKAction.removeFromParent()]))
                    
                    
                    token.size = CGSize(width: 40, height: 40)
                    token.position = CGPointMake(meteor.position.x, meteor.position.y)
                    
                    addChild(token)
                    
                    token.physicsBody = SKPhysicsBody(rectangleOfSize: token.size)
                    token.physicsBody?.dynamic = true
                    token.physicsBody?.categoryBitMask = Bodytype.Token
                    token.physicsBody?.contactTestBitMask = Bodytype.Hero
                    token.physicsBody?.collisionBitMask = 0
                    
                    
                }
                
            }
            //Lo que pasa cuando se acaban las vidas.
            func gameOver(){
                gameIsOver = true

                //Se borran todos los nodes de la pantalla
                removeAllChildren()
                //Se le dan todas las caracteristicas fisicas al Label de GameOver.
                let gameOverLabel = SKLabelNode(fontNamed: "Impact")
                gameOverLabel.text = "GAME OVER"
                gameOverLabel.fontColor = UIColor.whiteColor()
                gameOverLabel.fontSize = 50
                gameOverLabel.position = CGPointMake(self.size.width/2, self.size.height*0.75)
                
                //Se dan las caracteristicas fisicas al Label Score abajo del Gameover.
                scoreLabel.text = "Score: \(meteorScore)"
                scoreLabel.fontName = "Impact"
                scoreLabel.position = CGPointMake((self.size.width/2), (self.size.height*0.6))
                scoreLabel.fontColor = UIColor.whiteColor()
                scoreLabel.fontSize = 25
                
                let restartButton = SKLabelNode(fontNamed: "Impact")
                restartButton.position = CGPointMake(self.size.width/2, (self.size.height*0.35))
                restartButton.name = "restartButton"
                restartButton.text = "Restart"
                restartButton.fontSize = 30
                restartButton.fontColor = UIColor.redColor()
                
                //Se agregan las tres Labels
                addChild(gameOverLabel)
                addChild(scoreLabel)
                addChild(restartButton)
                
                
            }
            
            func newLevel(){
                //Se borran todos los nodes de la pantalla y se agregan las labels y el hero
                
                bgImage.removeFromParent()
                levelCount += 1
                levelCountLabel.text = "Level: \(levelCount)"
                if(levelCount == 2){
                bgImage = SKSpriteNode(imageNamed: "Bg2")
                }else{
                    bgImage = SKSpriteNode(imageNamed: "Bg3")
                }
                addChild(bgImage)
                bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
                bgImage.zPosition = 0
                meteorPerLevel()

                
            }
            
            func heroFlashAfterHit(){
                
                hero.color = UIColor.redColor()
                hero.colorBlendFactor = 1
                
                if hero.color == UIColor.redColor(){
                    hero.color = UIColor.whiteColor()
                }
                else{
                    hero.color = UIColor.redColor()
                    hero.colorBlendFactor = 1
                }
            }
            
            func meteorPerLevel(){
                switch levelCount {
                case 2:
                    removeActionForKey("meteorLoop")
                    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addMeteor), SKAction.waitForDuration(0.75)])), withKey: "meteorLoop")
                    break
                case 3:
                    removeActionForKey("meteorLoop")
                    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addMeteor), SKAction.runBlock(addMeteor), SKAction.waitForDuration(0.85)])), withKey: "meteorLoop")
                    break
                default:
                    runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addMeteor), SKAction.waitForDuration(1.0)])), withKey: "meteorLoop")
                }
                
            }
         
            
            
}
    