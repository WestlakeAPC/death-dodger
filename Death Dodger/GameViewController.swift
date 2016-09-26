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

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    
    fileprivate var scene : SKScene?
    var deviceType = "Device"
    @IBOutlet var share: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        share.frame.size.height = 1
        share.layer.cornerRadius = 5
        
        share.isHidden = false
        
        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            //Also made game work on different devices
            if (UIDevice.current.model == "iPhone"){
                deviceType = "Iphone"
                scene.scaleMode = .aspectFill
            } else if (UIDevice.current.model == "iPad"){
                deviceType = "Ipad"
                scene.scaleMode = .resizeFill
            } else {
                scene.scaleMode = .aspectFill
            }
            
            self.scene = scene as SKScene?
            
            print(deviceType)
            
            skView.presentScene(scene)
            
            self.scene = scene
        }
        
        authenticateLocalPlayer()
        
    }

    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func shareButton() {
        
        //GameCenter-y stuff to do.
        print(String(describing: ((scene as! GameScene?)?.score)!))
        saveHighscore(((scene as! GameScene?)?.displayScore)!)
        showLeader()
        
    }
    
    
    //shows leaderboard screen
    func showLeader() {
        //let vc = self.view?.window?.rootViewController
        let vc = self
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc.present(gc, animated: true, completion: nil)
    }
    
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        
    }
    
    //send high score to leaderboard
    func saveHighscore(_ score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "DeathDodgerLeaderBoardGameCenterIDNumber" + String(describing: (UserDefaults.standard.value(forKey: "numSwords") ?? 3)!)) //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {(error : Error?) -> Void in
                if error != nil {
                    print("error")
                }
            })
            
        }
        
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
                
            else {
                print((GKLocalPlayer.localPlayer().isAuthenticated))
            }
        }
    }
    
}
