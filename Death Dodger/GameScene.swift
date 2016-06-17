//
//  GameScene.swift
//  Death Dodger
//
//  Created by Eli Bradley on 6/16/16.
//  Copyright © 2016 Eli Bradley. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var rocket : SKSpriteNode?
    private var spinnyNode : SKShapeNode?
    private var swords = [SKSpriteNode?](repeating: nil, count: 4);
    
    let left = SKAction.moveBy(x: -60, y: 0, duration: 0.3)
    let right = SKAction.moveBy(x: 60, y: 0, duration: 0.3)
    let down = SKAction.moveBy(x: 0, y: -20, duration: 0.03)
    
    var initialized : Bool = false;
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        self.rocket = self.childNode(withName: "//finnCharc") as? SKSpriteNode
        
        if !initialized {
            for i in 1 ... swords.endIndex-1 {
                swords[i] = self.childNode(withName: "//enemy"+String(i)) as? SKSpriteNode
                let sword = swords[i]
                
                sword?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                                          y: self.frame.origin.y + self.frame.width * 2)
            };
            
            rocket?.position = CGPoint(x: self.frame.origin.x + self.frame.width/2,
                                       y: self.frame.origin.y + self.frame.height/4)
            initialized = true;
        }
        
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
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green()
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue()
            self.addChild(n)
        }
        
        if let rocket = self.rocket {
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
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red()
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for i in 1 ... swords.endIndex-1 {
            swords[i]?.run(self.down);
            if ((self.rocket?.intersects(swords[i]!)) == true) {
                swords[i]?.isHidden = true;
            } else if (swords[i]?.position.y <= self.frame.origin.y + (swords[i]?.frame.height)!/2) {
                swords[i]?.position = CGPoint(x: self.frame.origin.x + CGFloat(arc4random_uniform(UInt32(self.frame.width))),
                                              y: self.frame.origin.y + self.frame.width * 2)
                swords[i]?.isHidden = false;
            }
        }
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
