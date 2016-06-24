//
//  GameScene.swift
//  Death Dodger
//
//  Created by Eli Bradley on 6/16/16.
//  Copyright © 2016 Eli Bradley. All rights reserved.
//

import SpriteKit
import GameplayKit

@objc(GameScene)
class GameScene: SKScene {
    
    var spinnyStuff = false
    var deleteElement = SKAction.removeFromParent()
    var scoreDisplay = SKLabelNode()
    private var label : SKLabelNode?
    private var rocket : SKSpriteNode?
    private var over : SKShapeNode?
    private var spinnyNode : SKShapeNode?
    private var swords = [SKSpriteNode?](repeating: nil, count: 4);
    private var emitter = [SKEmitterNode?](repeating: nil, count: 4);

    let left = SKAction.moveBy(x: -50, y: 0, duration: 0.3)
    let right = SKAction.moveBy(x: 50, y: 0, duration: 0.3)
    let down = SKAction.moveBy(x: 0, y: -40, duration: 0.03)
    
    var initialized = false;
    var continued = false;
    var score = 0;
    
    override func didMove(to view: SKView) {
        
        //As soon as view is loaded
        // Get label node from scene and store it for use later
        
        //Score Board
        //scoreDisplay = SKLabelNode.init(text: String(score))
        scoreDisplay.text = String(score)
        scoreDisplay.fontSize = 150
        scoreDisplay.fontColor = #colorLiteral(red: 0.2464724183, green: 0.05352632701, blue: 0.03394328058, alpha: 1)
        scoreDisplay.position = CGPoint(x: -(self.frame.size.width*1/3),y :self.frame.size.height*3/8)
        self.addChild(scoreDisplay)

        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        self.label?.isHidden = true;
        
        self.rocket = self.childNode(withName: "finnCharc") as? SKSpriteNode
        self.over = self.childNode(withName: "overScreen") as? SKShapeNode
        
        if !initialized {
            initialize()
        }
        
        if continued {
            if let label = self.label {
                label.alpha = 0.0
                //label.run(SKAction.fadeIn(withDuration: 2.0))
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
    //*************************************************************
  
    func playerDidDie(){
        continued = false;
        scoreDisplay.text = " "
        
        self.over?.setScale(0.0)
        self.over?.isHidden = false
        self.over?.alpha = 1.0
        self.over?.removeAllChildren()
        self.rocket?.isHidden = true
        
        let deathLabel = SKLabelNode.init(text: "You died!")
        deathLabel.fontSize = 40;
        deathLabel.setScale(0.33);
        deathLabel.fontColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1);
        self.over?.addChild(deathLabel)
        deathLabel.position = CGPoint(x: (self.over?.frame.origin.x)! + (self.over?.frame.width)!/2,
                                      y: (self.over?.frame.origin.y)! + (self.over?.frame.height)!/2)
        
        
        let restartLabel = SKLabelNode.init(text: "Restart?")
        restartLabel.fontSize = 40;
        restartLabel.setScale(0.33);
        restartLabel.fontColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1);
        self.over?.addChild(restartLabel)
        restartLabel.position = CGPoint(x: (self.over?.frame.origin.x)! + (self.over?.frame.width)!/2,
                                      y: (self.over?.frame.origin.y)! + (self.over?.frame.height)!/2 - 25)
 
 
        let pLabel = SKLabelNode.init(text: String(score)+" points!")
        pLabel.fontSize = 45;
        pLabel.fontName = "Iowan Old";
        pLabel.setScale(0.33);
        pLabel.fontColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1);
        self.over?.addChild(pLabel)
        pLabel.position = CGPoint(x: (self.over?.frame.origin.x)! + (self.over?.frame.width)!/2,
                                      y: (self.over?.frame.origin.y)! + (self.over?.frame.height)!/2 + 25)
        
        for i in emitter { i?.particleBirthRate = 40 }
        
        self.over?.run(SKAction.scale(to: 4.0, duration: 1.0))
    }
    
    //*************************************************************
    
    func touchDown(atPoint pos : CGPoint) {
        
        
        if spinnyStuff{
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = pos
                n.strokeColor = SKColor.green()
                self.addChild(n)
            }
        }
    }
    
    //*************************************************************

    func touchMoved(toPoint pos : CGPoint) {
        if spinnyStuff{
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
    //*************************************************************

    func touchUp(atPoint pos : CGPoint) {
        if spinnyStuff{
            if let n = self.spinnyNode?.copy() as! SKShapeNode? {
                n.position = pos
                n.strokeColor = SKColor.red()
                self.addChild(n)
            }
        }
    }
    //*************************************************************
    
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
    //*************************************************************

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //*************************************************************

    override func update(_ currentTime: TimeInterval) {
        for i in 1 ... swords.endIndex-2 {
            swords[i]?.run(self.down);
            if ((self.rocket?.intersects(swords[i]!)) == true) {
                swords[i]?.isHidden = true;
                self.playerDidDie();
            } else if (swords[i]?.position.y <= self.frame.origin.y + (swords[i]?.frame.height)!/2) {
                if continued {
                    swords[i]?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                                                  y: self.frame.origin.y + self.frame.width * 2 + CGFloat(i)*self.frame.height/4)
                    swords[i]?.isHidden = false;
                    score+=1;
                    scoreDisplay.text = String(score)
                    print(score)
                    
                }
            }
        }
    }
    
    // Initialziation ***************************************
    func initialize() {
        for i in 1 ... swords.endIndex-2 {
            swords[i] = self.childNode(withName: "//enemy"+String(i)) as? SKSpriteNode
            let sword = swords[i]
            
            sword?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                                      y: self.frame.origin.y + self.frame.width * 2)
            sword?.isHidden = false
        }
        
        
        
 /*       for i in 0...emitter.endIndex-1 {
            if (emitter[i] == nil) {
                emitter[i] = SKEmitterNode(fileNamed: "Confetti")
                let extraX = CGFloat(i%2) * self.frame.width/2
                let extraY = CGFloat((i/2)%2) * self.frame.height/2
                emitter[i]?.position = CGPoint(x: self.frame.origin.x + self.frame.width/4 + extraX,
                                           y: self.frame.origin.y + self.frame.height/4 + extraY)
                
                self.addChild(emitter[i]!)
            }
 
            emitter[i]?.particleBirthRate = 0
        }
  */
        
        score = 0
        
        //Rocket Placement
        rocket?.position = CGPoint(x: self.frame.origin.x + self.frame.width/2,
                                   y: self.frame.origin.y + self.frame.height/4)
        rocket?.isHidden = false
        
        over?.position = CGPoint(x: self.frame.origin.x + self.frame.width/2,
                                 y: self.frame.origin.y + self.frame.height/2)
        over?.isHidden = true
        over?.name = "Over-screen"
        over?.isUserInteractionEnabled = false
        
        continued = true;
        initialized = true;
    }
    
    
    
    
    
    
    
    /*
    func checkCollision (aSword: SKSpriteNode) -> Bool {
        let swordX = aSword.position.x - aSword.frame.width/2;
        let swordXRight = aSword.position.x + aSword.frame.width/2;
        let swordY = aSword.position.y - aSword.frame.height/2;
        let swordYRight = aSword.position.y + aSword.frame.height/2;
        
        let rocketX = (self.rocket?.position.x)! - (self.rocket?.frame.width)!/2;
        let rocketXRight = (self.rocket?.position.x)! + (self.rocket?.frame.width)!/2;
        let rocketY = (self.rocket?.position.y)! - (self.rocket?.frame.height)!/2;
        let rocketYRight = (self.rocket?.position.y)! + (self.rocket?.frame.height)!/2;
        
        return (rocketX < swordXRight && swordX < rocketXRight && // X Overlap
                rocketY < swordYRight && swordY < rocketYRight); // Y Overlap
    } */
}