//
//  GameViewController.swift
//  Death Dodger tvOS
//
//  Created by Joseph Jin on 9/4/16.
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

        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
            
            self.scene = scene
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func shareButton() {
        
        //GameCenter-y stuff to do.
        print(String(describing: ((scene as! GameScene?)?.score)!))
        saveHighscore(((scene as! GameScene?)?.score)!)
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
    func saveHighscore(_ score:CGFloat) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            //let scoreReporter = GKScore(leaderboardIdentifier: "DeathDodgerLeaderBoardID" + String(NSUserDefaults.standardUserDefaults().valueForKey("numSwords") ?? 3)) //leaderboard id here
            
            let scoreReporter = GKScore(leaderboardIdentifier: "g_death3")
            
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
