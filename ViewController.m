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
    
    
    //Sword size      52px X 112px
    
    sword1yCoords = -[aSword1 frame].size.height/2;
    sword2yCoords = -[aSword1 frame].size.height/2;
    
    sword1xCoords = [aSword1 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword1 frame].size.width/2);
    sword2xCoords = [aSword2 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword2 frame].size.width/2);
    
    [self drawLoop];
    
    if (!debug) {
        directionStatus.hidden = true;
    }
    
}

- (void)drawLoop {
    
    moveSwordsDown = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDraw) userInfo:nil repeats:true];
    if (debug) directionStatus.text = @"Yep, this isn't a infinite loop.";
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reDraw{
    finnCharc.center = CGPointMake(finnCoordX, finnCoordY);
    
    sword1yCoords = sword1yCoords + 20;
    sword2yCoords = sword2yCoords + 20;
    aSword1.center = CGPointMake(sword1xCoords, sword1yCoords);
    aSword2.center = CGPointMake(sword2xCoords, sword2yCoords);
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
