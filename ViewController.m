//
//  ViewController.m
//  Death_Dodger
//
//  Created by Joseph Jin on 5/22/16.
//  Copyright (c) 2016 Animator Joe. All rights reserved.
//
//
// ================================================================================
//
// Update Notice: Enabling the directionStatus text may cause glitches in the game.
//
// ================================================================================

#import "GameViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //This part is what happens to Finn as soon as the app is loaded.
    //spriteFinn.
    
    // Set to True to Debug
    //        |
    //       \|/
    debug = false;
    
    finnCoordX = finnCharc.center.x;
    finnCoordY = finnCharc.center.y;
    
    if (!debug) {
        directionStatus.hidden = true;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reDraw{
    
    if(!(finnCoordX <= 20)){
        
      if (!(finnCoordX >= 350)){
          
    finnCharc.center = CGPointMake(finnCoordX, finnCoordY);
          
          }
        
    }
    
}

- (IBAction)leftButton:(id)sender {
    
    if (debug){
        
        directionStatus.text = @"left";
        
    }
    
    finnCoordX -= 10;
    [self reDraw];
    
}

- (IBAction)rightButton:(id)sender {
    
    if (debug){
        
        directionStatus.text = @"right";
        
    }
    
    finnCoordX += 10;
    [self reDraw];
        
}

@end
