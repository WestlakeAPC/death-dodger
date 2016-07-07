//
//  GameScene.swift
//  Death Dodger
//
//  Created by Eli Bradley on 6/16/16.
//  Copyright © 2016 Eli Bradley. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

@objc(GameScene)
class GameScene: SKScene {
    
    enum ColliderType: UInt32 {
        
        case Charc = 1
        case Swords = 2
        
    }
    
    let left = SKAction.moveBy(x: -100, y: 0, duration: 0.3)
    let right = SKAction.moveBy(x: 100, y: 0, duration: 0.3)
    let spinnyStuff = UserDefaults.standard().value(forKey: "spinnyStuff") ?? false
    let numSwords = UserDefaults.standard().value(forKey: "numSwords") ?? 3
    
    var backgroundImage = SKSpriteNode()
    private var label : SKLabelNode?
    private var rocket : SKSpriteNode?
    private var over : SKShapeNode?
    private var spinnyNode : SKShapeNode?
    private var scoreDisplay = SKLabelNode()
    private var swords = [SKSpriteNode?](repeating: nil, count: 4);
    private var emitter = [SKEmitterNode?](repeating: nil, count: 1);
    
    var backgroundMusic = AVAudioPlayer()
    var swordSoundEffect = AVAudioPlayer()
    var punchSoundEffect = AVAudioPlayer()
    var removeElement = SKAction.removeFromParent()
    var initialized : Bool = false;
    var continued : Bool = false;
    var score : CGFloat = 0.0;
    var displayScore = 0
    var temp = 0
    var screenScale = 0
    var downRate = 10.0
    var maxSpeed = 30.0
    
//******************************************************************************* Did Move To View
    override func didMove(to view: SKView) {
        
        //Background Image
        let backgroundPhoto = SKTexture(imageNamed: "gamebackground.png")
        backgroundImage = SKSpriteNode(texture: backgroundPhoto)
        backgroundImage.size.height = self.size.height
        backgroundImage.size.width = self.size.height * 900/504
        backgroundImage.zPosition = -5
        self.addChild(backgroundImage)
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        self.label?.isHidden = true;
        
        //Music
        let music = NSURL(fileURLWithPath: Bundle.main().pathForResource("Crazy", ofType: "wav")!)
        backgroundMusic = try! AVAudioPlayer.init(contentsOf: music as URL)
        backgroundMusic.prepareToPlay()
        backgroundMusic.numberOfLoops = -1
        
        //Sword Sound
        let swordSound = NSURL(fileURLWithPath: Bundle.main().pathForResource("Sword", ofType: "wav")!)
        swordSoundEffect = try! AVAudioPlayer.init(contentsOf: swordSound as URL)
        swordSoundEffect.prepareToPlay()
        swordSoundEffect.numberOfLoops = 0
        
        //Punch Sound
        let punchSound = NSURL(fileURLWithPath: Bundle.main().pathForResource("punch", ofType: "wav")!)
        punchSoundEffect = try! AVAudioPlayer.init(contentsOf: punchSound as URL)
        punchSoundEffect.prepareToPlay()
        punchSoundEffect.numberOfLoops = 0
        
        //Sprites
        self.rocket = self.childNode(withName: "//finnCharc") as? SKSpriteNode
        self.over = self.childNode(withName: "overScreen") as? SKShapeNode
        
        //Score Board
        scoreDisplay.text = String(displayScore)
        scoreDisplay.fontSize = 120
        scoreDisplay.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        scoreDisplay.position = CGPoint(x: self.frame.origin.x + self.frame.size.width * 1/2,
                                        y: self.frame.origin.y + self.frame.size.height * 0.9)
        self.addChild(scoreDisplay)

        //Gravity Crap
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
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
                spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                                  SKAction.fadeOut(withDuration: 0.5),
                                                  SKAction.removeFromParent()]))
            }
        }
    }
    
//***************************************************** Death
    func playerDidDie(){
        
        //Music Stop
        backgroundMusic.stop()
        backgroundMusic.currentTime = 0.0
        
        punchSoundEffect.play()
        
        continued = false;
        //self.over?.setScale(1.0)
        self.over?.isHidden = false
        self.over?.alpha = 1.0
        self.over?.removeAllChildren()
        self.rocket?.isHidden = false
        
        let deathLabel = SKLabelNode.init(text: "Tap to Restart")
        deathLabel.fontSize = 36;
        deathLabel.setScale(0.33);
        deathLabel.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        self.over?.addChild(deathLabel)
        deathLabel.position = CGPoint(x: (self.over?.frame.origin.x)! + (self.over?.frame.width)!/2, y: (self.over?.frame.origin.y)! + (self.over?.frame.height)!/2)
        
        let pLabel = SKLabelNode.init(text: String(displayScore)+" points")
        pLabel.fontSize = 45;
        pLabel.setScale(0.33);
        pLabel.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        self.over?.addChild(pLabel)
        pLabel.position = CGPoint(x: (self.over?.frame.origin.x)! + (self.over?.frame.width)!/2,
                                      y: (self.over?.frame.origin.y)! + (self.over?.frame.height)!/2 + 25)

        for i in emitter { i?.particleBirthRate = 500;
                           i?.position = (rocket?.position)! }
        
        self.over?.run(SKAction.scale(to: 4.0, duration: 1.0))
        
    }
    
//***************************************************** ^^^
    func touchDown(atPoint pos : CGPoint) {
        if self.spinnyStuff as! Bool {
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = pos
                n.strokeColor = SKColor.green()
                self.addChild(n)
            }
        }
    }
    
//***************************************************** Move Charc
    func touchMoved(toPoint pos : CGPoint) {
        if self.spinnyStuff as! Bool {
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = pos
                n.strokeColor = SKColor.blue()
                self.addChild(n)
            }
        }
        
        if let rocket = self.rocket {
            if continued {
                if pos.x < self.frame.origin.x + self.frame.width/2{
                    if (self.rocket?.position.x)! - (self.rocket?.frame.width)!/2 > self.frame.origin.x {
                        rocket.run(self.left);
                    }
                } else if pos.x >= self.frame.origin.x + self.frame.width/2 {
                    if (self.rocket?.position.x)! + (self.rocket?.frame.width)!/2 <= self.frame.origin.x + self.frame.width {
                        rocket.run(self.right);
                    }
                }
            }
        }
    }
    
//***************************************************** ^^^
    func touchUp(atPoint pos : CGPoint) {
        if self.spinnyStuff as! Bool {
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = pos
                n.strokeColor = SKColor.red()
                self.addChild(n)
            }
        }
    }
    
//***************************************************** Restart
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
            
            for i in self.nodes(at: t.location(in: self)) {
                if !continued && i.name == "Over-screen" {
                    self.initialized = false
                    
                    self.over?.run(SKAction.fadeOut(withDuration: 1.0), completion: {
                        self.initialize()
                    })
                }
            }
        }
    }
    
//*****************************************************
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
//***************************************************** Swords
    override func update(_ currentTime: TimeInterval) {
        for i in 1 ... swords.endIndex-1 {
            swords[i]?.run(SKAction.moveBy(x: 0, y: -(CGFloat)(self.downRate), duration: 0.03))
            
            if ((checkCollision(aSword: swords[i]!)) == true) {
                //swords[i]?.isHidden = true
                if i <= numSwords as! Int {
                    self.playerDidDie()
                }
            } else if (swords[i]?.position.y <= self.frame.origin.y - (swords[i]?.frame.height)!/2) {
                if continued {
                    swords[i]?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                                                  y: self.frame.origin.y + self.frame.height + CGFloat(i * 50))
                    swordSoundEffect.play()
                    
                    //Score
                    if i <= numSwords as! Int {
                        swords[i]?.isHidden = false
                    }
                    
                    if i > numSwords as! Int {
                        displayScore = displayScore + 0
                    } else {
                        displayScore = displayScore + 1
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
            swords[i] = self.childNode(withName: "//enemy"+String(i)) as? SKSpriteNode
            let sword = swords[i]
            
            sword?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),       y: self.frame.origin.y + self.frame.height * 3/2)
            
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
                let extraY = CGFloat((i/2)%2) * self.frame.height/2
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
        rocket?.zPosition = 9
        
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
        backgroundMusic.play()
        swordSoundEffect.play()
        
    }
    
    func checkCollision (aSword: SKSpriteNode) -> Bool {
        let swordX = aSword.position.x - aSword.frame.width/5;
        let swordXRight = aSword.position.x + aSword.frame.width/5;
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
