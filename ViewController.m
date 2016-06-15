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

#import "ViewController.h"

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
    finnCoordY = [[UIScreen mainScreen] bounds].size.height * 3/4;
    
    [self reDraw];
    
    if (!debug) {
        directionStatus.hidden = true;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reDraw{
    finnCharc.center = CGPointMake(finnCoordX, finnCoordY);
}

- (IBAction)leftButton:(id)sender {
    
    if (debug) directionStatus.text = @"left";
    
    if(!(finnCoordX <= [finnCharc frame].size.width/2)) finnCoordX -= 10;
    
    [self reDraw];
    
}

- (IBAction)rightButton:(id)sender {
    
    if (debug) directionStatus.text = @"right";
    
    if (!(finnCoordX >=  [[UIScreen mainScreen] bounds].size.width-[finnCharc frame].size.width/2)) finnCoordX += 10;
    
    [self reDraw];
        
}

@end
