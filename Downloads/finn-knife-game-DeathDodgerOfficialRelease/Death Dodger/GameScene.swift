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
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let left = SKAction.moveByX(-100, y: 0, duration: 0.3)
    let right = SKAction.moveByX(100, y: 0, duration: 0.3)
    //let spinnyStuff = UserDefaults.standard().value(forKey: "spinnyStuff") ?? false
    //let numSwords = UserDefaults.standard().value(forKey: "numSwords") ?? 3
    let spinnyStuff = NSUserDefaults.standardUserDefaults().valueForKey("spinnyStuff") ?? false
    let numSwords = NSUserDefaults.standardUserDefaults().valueForKey("numSwords") ?? 3
    
    var backgroundImage = SKSpriteNode()
    var screenBoarder = SKNode()
    var deathLabel = SKLabelNode()
    var pLabel = SKLabelNode()
    private var label : SKLabelNode?
    private var rocket : SKSpriteNode?
    private var over : SKShapeNode?
    private var spinnyNode : SKShapeNode?
    private var scoreDisplay = SKLabelNode()
    private var swords = [SKSpriteNode?](count: 4, repeatedValue: nil)
    private var emitter = [SKEmitterNode?](count: 1, repeatedValue: nil)
    
    var backgroundMusic = AVAudioPlayer()
    var swordSoundEffect = AVAudioPlayer()
    var punchSoundEffect = AVAudioPlayer()
    var removeElement = SKAction.removeFromParent()
    var initialized : Bool = false
    var continued : Bool = false
    var playerRekt = false
    var secondDeath = false
    var score : CGFloat = 0.0
    var displayScore = 0
    var temp = 0
    var screenScale = 0
    var downRate = 10.0
    var maxSpeed = 30.0
    
    //******************************************************************************* Did Move To View
    override func didMoveToView(view: SKView){
        
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
        
        //Music
        let music = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Crazy", ofType: "wav")!)
        backgroundMusic = try! AVAudioPlayer.init(contentsOfURL: music)
        backgroundMusic.prepareToPlay()
        backgroundMusic.numberOfLoops = -1
        
        //Sword Sound
        let swordSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Sword", ofType: "wav")!)
        swordSoundEffect = try! AVAudioPlayer.init(contentsOfURL: swordSound)
        swordSoundEffect.prepareToPlay()
        swordSoundEffect.numberOfLoops = 0
        
        //Punch Sound
        let punchSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("punch", ofType: "wav")!)
        punchSoundEffect = try! AVAudioPlayer.init(contentsOfURL: punchSound)
        punchSoundEffect.prepareToPlay()
        punchSoundEffect.numberOfLoops = 0
        
        //Sprites
        self.rocket = self.childNodeWithName("finnCharc") as? SKSpriteNode
        self.over = self.childNodeWithName("overScreen") as? SKShapeNode
        
        //Setup For Player Info
        //let deathLabel = SKLabelNode.init()
        deathLabel.text = "Tap to Restart"
        deathLabel.fontSize = 30;
        deathLabel.setScale(0.33);
        deathLabel.fontColor = UIColor.blackColor()
        deathLabel.position = CGPoint(x: 0,y: -10)
        deathLabel.zPosition = 15
        self.over?.addChild(deathLabel)
        
        pLabel.fontSize = 45;
        pLabel.setScale(0.33);
        pLabel.fontColor = UIColor.blackColor()
        pLabel.position = CGPoint(x: 0,y: 20)
        self.over?.addChild(pLabel)
        
        //Score Board
        scoreDisplay.text = String(displayScore)
        scoreDisplay.fontSize = 120
        scoreDisplay.fontColor = UIColor.whiteColor()
        scoreDisplay.zPosition = 12
        scoreDisplay.position = CGPoint(x: self.frame.origin.x + self.frame.size.width * 1/2,
        y: self.frame.origin.y + self.frame.size.height * 0.9)
        scoreDisplay.zPosition = -3
        self.addChild(scoreDisplay)
        
        //Physics
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0,y: 0, width: self.frame.size.width,height: self.frame.size.height * 1.5))
        self.physicsBody?.dynamic = true
        
        self.physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        
        //Initialize
        if !initialized {
            initialize()
        }
        
        
        if continued {
            if let label = self.label {
                label.alpha = 0.0
                label.runAction(SKAction.fadeInWithDuration(2.0))
                label.text = String("Spaceship");
            }
            
            // Create shape node to use during mouse interaction
            let w = (self.size.width + self.size.height) * 0.05
            self.spinnyNode = SKShapeNode.init(rectOfSize: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
            
            if let spinnyNode = self.spinnyNode {
                spinnyNode.lineWidth = 2.5
                spinnyNode.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 1)))
                spinnyNode.runAction(SKAction.sequence([SKAction.waitForDuration(0.5),SKAction.fadeOutWithDuration(0.5),SKAction.removeFromParent()]))
            }
        }
    }
    
    //***************************************************** Death
    func playerDidDie(){
        
        if (playerRekt == false){
            
        //Music Stop
        backgroundMusic.stop()
        backgroundMusic.currentTime = 0.0
        
        punchSoundEffect.play()
        
        continued = false;
        playerRekt = true
        self.over?.setScale(1.0)
        self.over?.hidden = false
        self.over?.alpha = 1.0
        self.rocket?.hidden = true
        
        deathLabel.text = "Tap to Restart"
        pLabel.text = String(displayScore) + " Points!"
        
            
        for i in emitter { i?.particleBirthRate = 500;
            i?.position = (rocket?.position)! }

        self.over?.runAction(SKAction.scaleTo(4.0, duration: 1.0))
            
            
            
        }
        
    }
    
    //***************************************************** Touch Down
    func touchDown(atPoint pos : CGPoint) {
        if self.spinnyStuff as! Bool {
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = pos
                n.strokeColor = UIColor.greenColor()
                self.addChild(n)
            }
        }
    }
    
    //***************************************************** Move Charc
    func touchMoved(toPoint pos : CGPoint) {
        if self.spinnyStuff as! Bool {
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = pos
                n.strokeColor = UIColor.blueColor()
                self.addChild(n)
            }
        }
        
        if let rocket = self.rocket {
            if continued {
                if pos.x < self.frame.origin.x + self.frame.width/2{
                    if (self.rocket?.position.x)! - ((self.rocket?.frame.width)!/2) >= self.frame.origin.x {
                        rocket.runAction(self.left);
                    }
                } else if pos.x >= self.frame.origin.x + self.frame.width/2 {
                    if (self.rocket?.position.x)! + ((self.rocket?.frame.width)!/2) <= self.frame.origin.x + self.frame.size.width {
                        rocket.runAction(self.right);
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
                n.strokeColor = UIColor.redColor()
                self.addChild(n)
            }
        }
    }
    
    //***************************************************** Restart
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let label = self.label {
            label.runAction(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.touchDown(atPoint: t.locationInNode(self))
            
            for i in self.nodesAtPoint(t.locationInNode(self)) {
                if !continued && i.name == "Over-screen" {
                    self.initialized = false
                    
                    for i in 1 ... swords.endIndex-1 {
                        swords[i]?.runAction(SKAction.removeFromParent())
                    }
                    
                    self.over?.runAction(SKAction.fadeOutWithDuration(1.0), completion: {
                        self.initialize()
                    })
                    
                }
            }
        }
    }
    
    //*****************************************************
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.locationInNode(self)) }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.locationInNode(self)) }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.locationInNode(self)) }
    }
    
    
    //***************************************************** Swords
    override func update(currentTime: NSTimeInterval) {
        for i in 1 ... swords.endIndex-1 {
            
            //print((swords[i]?.position)!)
            
            swords[i]?.runAction(SKAction.moveByX(0, y: -(CGFloat)(self.downRate), duration: 0.03))
            
            if ((checkCollision(swords[i]!)) == true) {
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
                        swords[i]?.hidden = false
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
            
            //swords[i] = self.childNodeWithName("//sword"+String(i)) as? SKSpriteNode
            let swordSkin = SKTexture(imageNamed: "rainbowordersword.gif")
            swords[i] = SKSpriteNode(texture: swordSkin)
            
            let sword = swords[i]
 
            sword?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),       y: self.frame.origin.y + self.frame.height * 1.2)
            
            sword?.physicsBody?.dynamic = false
            
            sword?.zPosition = 8
            self.addChild((sword)!)
            
            if i > numSwords as! Int {
                swords[i]?.hidden = true
            } else {
                swords[i]?.hidden = false
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
        rocket?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: (rocket?.frame.width)!,
            height: (rocket?.frame.height)!))
        rocket?.physicsBody?.dynamic = true
        rocket?.hidden = false
        rocket?.zPosition = 10
        
        //Over Screen
        over?.position = CGPoint(x: self.frame.origin.x + self.frame.width/2,
            y: self.frame.origin.y + self.frame.height/2)
        
        over?.hidden = true
        over?.name = "Over-screen"
        over?.userInteractionEnabled = false
        
        //Settings
        continued = true;
        initialized = true;
        self.playerRekt = false
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
