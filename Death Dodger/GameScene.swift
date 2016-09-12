//
//  GameScene.swift
//  Death Dodger
//
//  Created by Eli Bradley on 6/16/16.
//  Copyright © 2016 Eli Bradley. All rights reserved.
//

import UIKit
import SpriteKit
#if (os(iOS)||os(tvOS))
    import GameplayKit
    import AVFoundation
#elseif os(watchOS)
    import WatchKit
    typealias SKColor = UIColor
#endif

@objc(GameScene)
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let left = SKAction.moveBy(x: -100, y: 0, duration: TimeInterval(0.3))
    let right = SKAction.moveBy(x: 100, y: 0, duration: TimeInterval(0.3))
    let spinnyStuff = UserDefaults.standard.value(forKey: "spinnyStuff") ?? false
    let numSwords = UserDefaults.standard.value(forKey: "numSwords") ?? 3
    
    var backgroundImage = SKSpriteNode()
    var screenBoarder = SKNode()
    var deathLabel = SKLabelNode()
    var pLabel = SKLabelNode()
    var label : SKLabelNode?
    var rocket : SKSpriteNode?
    var over : SKShapeNode?
    var spinnyNode : SKShapeNode?
    var scoreDisplay = SKLabelNode()
    var swords = [SKSpriteNode?](repeating: nil, count: 4)
    var emitter = [SKEmitterNode?](repeating: nil, count: 1)
    
    #if (os(iOS)||os(tvOS))
        var backgroundMusic : AVAudioPlayer?
        var swordSoundEffect : AVAudioPlayer?
        var punchSoundEffect : AVAudioPlayer?
    #elseif os(watchOS)
        var backgroundMusic : WKAudioFilePlayer?
        var swordSoundEffect : WKAudioFilePlayer?
        var punchSoundEffect : WKAudioFilePlayer?
    #endif
    
    var removeElement = SKAction.removeFromParent()
    var initialized : Bool = false
    var continued : Bool = false
    var secondDeath = false
    var score : CGFloat = 0.0
    var displayScore = 0
    var temp = 0
    var screenScale = 0
    var downRate = 10.0
    var maxSpeed = 30.0
    
    //******************************************************************************* Did Move To View
    #if os(watchOS)
        override func sceneDidLoad() {
            self.setUpScene()
        }
    #else
        override func didMove(to view: SKView) {
            self.setUpScene()
        }
    #endif
    
    func setUpScene(){
        //Setup For Collisions
        self.physicsWorld.contactDelegate = self
        
        //Background Image
        let backgroundPhoto = SKTexture(imageNamed: "gamebackground.png")
        backgroundImage = SKSpriteNode(texture: backgroundPhoto)
        backgroundImage.size.height = self.size.height
        backgroundImage.size.width = self.size.height * 900/504
        backgroundImage.position = CGPoint(x:self.frame.width/2, y:self.frame.height/2)
        backgroundImage.zPosition = -5
        self.addChild(backgroundImage)
        
        let music = URL(fileURLWithPath: Bundle.main.path(forResource: "Crazy", ofType: "wav")!)
        let swordSound = URL(fileURLWithPath: Bundle.main.path(forResource: "Sword", ofType: "wav")!)
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)

        #if (os(iOS)||os(tvOS))
            //Music
            backgroundMusic = try! AVAudioPlayer.init(contentsOf: music)
            backgroundMusic?.prepareToPlay()
            backgroundMusic?.numberOfLoops = -1
        
            //Sword Sound
            swordSoundEffect = try! AVAudioPlayer.init(contentsOf: swordSound)
            swordSoundEffect?.prepareToPlay()
            swordSoundEffect?.numberOfLoops = 0
        
            //Punch Sound
            punchSoundEffect = try! AVAudioPlayer.init(contentsOf: punchSound)
            punchSoundEffect?.prepareToPlay()
            punchSoundEffect?.numberOfLoops = 0
        #elseif os(watchOS)
            backgroundMusic = WKAudioFilePlayer(playerItem:  WKAudioFilePlayerItem(asset: WKAudioFileAsset(url: music)))
            swordSoundEffect = WKAudioFilePlayer(playerItem:  WKAudioFilePlayerItem(asset: WKAudioFileAsset(url: swordSound)))
            punchSoundEffect = WKAudioFilePlayer(playerItem:  WKAudioFilePlayerItem(asset: WKAudioFileAsset(url: punchSound)))
        #endif
        
        //Sprites
        self.rocket = self.childNode(withName: "finnCharc") as? SKSpriteNode
        self.over = self.childNode(withName: "overScreen") as? SKShapeNode
        
        //Setup For Player Info
        //let deathLabel = SKLabelNode.init()
        deathLabel.text = "Tap to Restart"
        deathLabel.fontSize = 30;
        deathLabel.setScale(0.33);
        deathLabel.fontColor = UIColor.black
        deathLabel.position = CGPoint(x: 0,y: -10)
        deathLabel.zPosition = 15
        self.over?.addChild(deathLabel)
        
        pLabel.fontSize = 45;
        pLabel.setScale(0.33);
        pLabel.fontColor = UIColor.black
        pLabel.position = CGPoint(x: 0,y: 20)
        self.over?.addChild(pLabel)
        
        //Score Board
        scoreDisplay.text = String(displayScore)
        scoreDisplay.fontSize = 120
        scoreDisplay.fontColor = UIColor.white
        scoreDisplay.zPosition = 12
        scoreDisplay.position = CGPoint(x: self.frame.origin.x + self.frame.size.width * 1/2,
        y: self.frame.origin.y + self.frame.size.height * 0.9)
        scoreDisplay.zPosition = -3
        self.addChild(scoreDisplay)
        
        //Physics
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0,y: 0, width: self.frame.size.width,height: self.frame.size.height * 1.5))
        self.physicsBody?.isDynamic = true
        
        self.physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        
        //Initialize
        if !initialized {
            initialize()
        }
        
        
        if continued {
            if let label = self.label {
                label.alpha = 0.0
                label.run(SKAction.fadeIn(withDuration: 2.0))
                label.text = String("Spaceship");
            }
            
            // Create shape node to use during mouse interaction
            let w = (self.size.width + self.size.height) * 0.05
            self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
            
            if let spinnyNode = self.spinnyNode {
                spinnyNode.lineWidth = 2.5
                spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
                spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),SKAction.fadeOut(withDuration: 0.5),SKAction.removeFromParent()]))
            }
        }
    }
    
    //***************************************************** Death
    func playerDidDie(){
        
        //Music Stop
        #if (os(iOS)||os(tvOS))
            backgroundMusic?.stop()
            backgroundMusic?.currentTime = 0.0
        #elseif os(watchOS)
            backgroundMusic?.pause()
        #endif
        
        punchSoundEffect?.play()
        
        continued = false;
        initialized = false;
        self.over?.setScale(1.0)
        self.over?.isHidden = false
        self.over?.alpha = 1.0
        self.rocket?.isHidden = false
        
        deathLabel.text = "Tap to Restart"
        pLabel.text = String(displayScore) + " Points!"
        
            
        for i in emitter { i?.particleBirthRate = 1500;
            i?.position = (rocket?.position)! }

        self.over?.run(SKAction.scale(to: 4.0, duration: 1.5))
        
    }
    
    //***************************************************** Swords
    override func update(_ currentTime: TimeInterval) {
        for i in 1 ... swords.endIndex-1 {
            
            //print((swords[i]?.position)!)
            
            swords[i]?.run(SKAction.moveBy(x: 0, y: -(CGFloat)(self.downRate), duration: 0.03))
            
            if ((checkCollision(swords[i]!)) == true) {
                if i <= numSwords as! Int {
                    self.playerDidDie()
                }
                
            } else if ((swords[i]?.position.y)! <= self.frame.origin.y - (swords[i]?.frame.height)!/2) {
                if continued {
                    swords[i]?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                        y: self.frame.origin.y + self.frame.height + CGFloat(i * 50))
                    swordSoundEffect?.play()
                    
                    //Score
                    if i <= numSwords as! Int {
                        swords[i]?.isHidden = false
                    }
                    
                    if i > numSwords as! Int {
                        displayScore = displayScore + 0
                    } else {
                        displayScore = displayScore + 1
                        score = score + 1
                    }
                    
                    if self.downRate < maxSpeed { self.downRate+=0.2 }
                    self.scoreDisplay.text = String(displayScore)
                }
            }
        }
    }
    
    //***************************************************** Initialize
    func initialize() {
        
        for i in 1 ... swords.endIndex-1 {
            swords[i]?.run(SKAction.removeFromParent())
        }
        
        for i in 1 ... swords.endIndex-1 {
            
            //swords[i] = self.childNodeWithName("//sword"+String(i)) as? SKSpriteNode
            let swordSkin = SKTexture(imageNamed: "the_sword.png")
            swords[i] = SKSpriteNode(texture: swordSkin)
            
            let sword = swords[i]
 
            sword?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                                      y: self.frame.origin.y + self.frame.height * 1.2)
            
            sword?.physicsBody?.isDynamic = false
            
            sword?.zPosition = 8
            self.addChild((sword)!)
            
            if i > numSwords as! Int {
                swords[i]?.isHidden = true
            } else {
                swords[i]?.isHidden = false
            }
            
        };
        
        for i in 0...emitter.endIndex-1 {
            if (emitter[i] == nil) {
                emitter[i] = SKEmitterNode(fileNamed: "Blood")
                let extraX = CGFloat(i%2) * self.frame.width/2
                _ = CGFloat((i/2)%2) * self.frame.height/2
                emitter[i]?.position = CGPoint(x: self.frame.origin.x + self.frame.width/4 + extraX,
                    y: self.frame.origin.y + self.frame.height/5)
                
                self.addChild(emitter[i]!)
            }
            
            emitter[i]?.particleBirthRate = 0
        }
        
        //Rocket
        rocket?.position = CGPoint(x: self.frame.origin.x + self.frame.width/2,
            y: self.frame.origin.y + self.frame.height/6)
        rocket?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: (rocket?.frame.width)!,
            height: (rocket?.frame.height)!))
        rocket?.physicsBody?.isDynamic = true
        rocket?.isHidden = false
        rocket?.zPosition = 10
        
        //Over Screen
        over?.position = CGPoint(x: self.frame.origin.x + self.frame.width/2,
            y: self.frame.origin.y + self.frame.height/2)
        
        over?.isHidden = true
        over?.name = "Over-screen"
        over?.isUserInteractionEnabled = false
        
        //Settings
        continued = true;
        initialized = true;
        self.displayScore = 0
        self.score = 0.0
        scoreDisplay.text = String(displayScore)
        self.downRate = 10.0
        
        //Music and Sound
        backgroundMusic?.play()
        swordSoundEffect?.play()
        
    }
    
    func checkCollision (_ aSword: SKSpriteNode) -> Bool {
        let swordX = aSword.position.x - aSword.frame.width/80;
        let swordXRight = aSword.position.x + aSword.frame.width/80;
        let swordY = aSword.position.y - aSword.frame.height/2;
        let swordYRight = aSword.position.y + aSword.frame.height/2;
        
        let rocketX = (self.rocket?.position.x)! - (self.rocket?.frame.width)!/2;
        let rocketXRight = (self.rocket?.position.x)! + (self.rocket?.frame.width)!/2;
        let rocketY = (self.rocket?.position.y)! - (self.rocket?.frame.height)!/2;
        let rocketYRight = (self.rocket?.position.y)! + (self.rocket?.frame.height)! * 2/5;
        
        return (rocketX < swordXRight && swordX < rocketXRight && // X Overlap
            rocketY < swordYRight && swordY < rocketYRight); // Y Overlap
    }
    
}

#if (os(iOS)||os(tvOS))
    extension GameScene {
        //***************************************************** Touch Down
        func touchDown(atPoint pos : CGPoint) {
            if self.spinnyStuff as! Bool {
                if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                    n.position = pos
                    n.strokeColor = UIColor.green
                    self.addChild(n)
                }
            }
        }
        
        //***************************************************** Move Charc
        func touchMoved(toPoint pos : CGPoint) {
            if self.spinnyStuff as! Bool {
                if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                    n.position = pos
                    n.strokeColor = UIColor.blue
                    self.addChild(n)
                }
            }
            
            //print(self.rocket?.position.x)
            
            if let rocket = self.rocket {
                if continued {
                    if pos.x < self.frame.origin.x + self.frame.width/2{
                        if (self.rocket?.position.x)! - ((self.rocket?.frame.width)!/2) >= self.frame.origin.x {
                            rocket.run(self.left);
                        }
                    } else if pos.x >= self.frame.origin.x + self.frame.width/2 {
                        if (self.rocket?.position.x)! + ((self.rocket?.frame.width)!/2) <= self.frame.origin.x + self.frame.size.width {
                            rocket.run(self.right);
                        }
                    }
                }
            }
        }
        
        //***************************************************** Spinny Stuff
        func touchUp(atPoint pos : CGPoint) {
            if self.spinnyStuff as! Bool {
                if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                    n.position = pos
                    n.strokeColor = UIColor.red
                    self.addChild(n)
                }
            }
        }
        
        //***************************************************** When Tapped (Restart)
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
            
            for t in touches {
                self.touchDown(atPoint: t.location(in: self))
                
                for i in self.nodes(at: t.location(in: self)) {
                    if !initialized && i.name == "Over-screen" {
                        self.initialized = true
                        
                        self.over?.run(SKAction.fadeOut(withDuration: 1.5), completion: {
                            self.over?.isUserInteractionEnabled = false
                            self.initialize()
                        })
                        
                        for i in 1 ... swords.endIndex-1 {
                            swords[i]?.run(SKAction.removeFromParent())
                        }
                        
                    }
                }
            }
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        }
    }
#endif
