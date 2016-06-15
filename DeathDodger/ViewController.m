//
//  ViewController.m
//  DeathDodger
//
//  Created by Joseph Jin on 6/14/16.
//  Copyright (c) 2016 Animator Joe. All rights reserved.
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
    
    directionStatus.hidden = false;
    finnCoordX = finnCharc.center.x;
    finnCoordY = finnCharc.center.y;
    
    //This is like a main loop or function.
    [self drawSwords];
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reDraw {
    //Charac Movement
    if(!(finnCoordX <= 20)){
        
        if (!(finnCoordX >= 350)){
            
            finnCharc.center = CGPointMake(finnCoordX, finnCoordY);
            
        }
    }
}

- (void)drawSwords {
    //Sword size      52px X 112px
    sword1yCoords = -56;
    sword2yCoords = -56;
    
    sword1xCoords = 26 + rand() % 323;
    sword2xCoords = 26 + rand() % 323;
    
    moveSwordsDown = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(dropSwords) userInfo:nil repeats:true];
    directionStatus.text = @"Yep, this isn't a infinite loop.";
        
}

- (void)dropSwords {
    
    sword1yCoords = sword1yCoords + 20;
    sword2yCoords = sword2yCoords + 20;
    aSword1.center = CGPointMake(sword1xCoords, sword1yCoords);
    aSword2.center = CGPointMake(sword2xCoords, sword2yCoords);
    
}

- (IBAction)leftButton:(id)sender {
    
    //Left Button
    if (debug){
        
        directionStatus.text = @"left";
        
    }
    
    if(!(finnCoordX <= 20)){
        finnCoordX -= 10;
        [self reDraw];
    }
    
}

- (IBAction)rightButton:(id)sender {
    
    //Right Button
    if (debug){
        
        directionStatus.text = @"right";
        
    }
    
    if(!(finnCoordX >= 350)){
        finnCoordX += 10;
        [self reDraw];
    }
    
}

@end
