//
//  GameViewController.swift
//  Death Dodger
//
//  Created by Joseph Jin on 7/5/16.
//  Copyright (c) 2016 Animator Joe. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            //var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    
    private var scene : SKScene?
    var deviceType = "Device"
    @IBOutlet var share: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        share.frame.size.height = 1
        share.layer.cornerRadius = 5
        
        share.hidden = true
        
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            //Also made game work on different devices
            if (UIDevice.currentDevice().model == "iPhone"){
                deviceType = "Iphone"
                scene.scaleMode = .AspectFill
            } else if (UIDevice.currentDevice().model == "iPad"){
                deviceType = "Ipad"
                scene.scaleMode = .ResizeFill
            } else {
                scene.scaleMode = .AspectFill
            }
            
            self.scene = scene as SKScene?
            
            print(deviceType)
            
            skView.presentScene(scene)
            
            self.scene = scene
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func shareButton() {
        
        //GameCenter-y stuff to do.
        //print(((scene as! GameScene?)?.crap)!)
        print(String(((scene as! GameScene?)?.score)!))
        saveHighscore(((scene as! GameScene?)?.score)!)
        showLeader()
        
    }
    
    
    //send high score to leaderboard
    func saveHighscore(score:CGFloat) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "g_death" +
                String(NSUserDefaults.standardUserDefaults().valueForKey("numSwords") ?? 2)) //leaderboard id here
            
            scoreReporter.value = Int64(score * 10) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    // println("error")
                }
            })
            
        }
        
    }
    
    //shows leaderboard screen
    func showLeader() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        //vc?.present(gc, animated: true, completion: nil)
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        //gameCenterViewController.dismiss(animated: true, completion: nil)
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                //self.present(viewController!, animated: true, completion: nil)
                self.presentViewController((viewController)!, animated: true, completion: nil)
            }
                
            else {
                // println((GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
    
}
