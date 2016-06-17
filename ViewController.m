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
    //Initial Values and Setup
    playerScore = 0;
    deathScreen.hidden = true;
    deathStatus =false;
    playerScoreInGame.text = [[NSString alloc] initWithFormat:@"Your Score: %d",playerScore];
    if (!debug) {directionStatus.hidden = true;}
    
    //Initial Character Placemet
    finnCoordX = finnCharc.center.x;
    finnCoordY = [[UIScreen mainScreen] bounds].size.height * 3/4;
    
    //Initial Sword Placement
    //Sword size      52px X 112px
    sword1yCoords = -[aSword1 frame].size.height/2;
    sword2yCoords = -[aSword1 frame].size.height/2;
    
    sword1xCoords = [aSword1 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword1 frame].size.width/2);
    
    sword2xCoords = [aSword2 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword2 frame].size.width/2);
    
    [self drawLoop];
    
}

//Calling reDraw
- (void)drawLoop {
    
    moveSwordsDown = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDraw) userInfo:nil repeats:true];
    
    if (debug) directionStatus.text = @"Yep, this isn't a infinite loop.";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Movement of Sword
- (void)reDraw{
    
    if (!deathStatus) {
        finnCharc.center = CGPointMake(finnCoordX, finnCoordY);
    
        if (aSword1.center.y<=[[UIScreen mainScreen] bounds].size.height+[aSword1 frame].size.height/2) {
        sword1yCoords = sword1yCoords + 20;
    } else {
        sword1yCoords = -[aSword1 frame].size.height/2;
        sword1xCoords = [aSword1 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword1 frame].size.width);
        aSword1.hidden = false;
        playerScore = playerScore + 1;
        //playerScoreInGame.text = [[NSString alloc] initWithFormat:@"Your Score: %d",playerScore];
    }
    
        if (aSword2.center.y<=[[UIScreen mainScreen] bounds].size.height+[aSword2 frame].size.height/2) {
        sword2yCoords = sword2yCoords + 20;
    } else {
        sword2yCoords = -[aSword2 frame].size.height/2 - 200;
        sword2xCoords = [aSword2 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword2 frame].size.width);
        aSword2.hidden = false;
        playerScore = playerScore + 1;
        //playerScoreInGame.text = [[NSString alloc] initWithFormat:@"Your Score: %d",playerScore];
    }
    
        if ([self checkCollision:aSword1]) {[self playerDidDie]; deathStatus = true;}
        if ([self checkCollision:aSword2]) {[self playerDidDie]; deathStatus = true;}
    
        aSword1.center = CGPointMake(sword1xCoords, sword1yCoords);
        aSword2.center = CGPointMake(sword2xCoords, sword2yCoords);
        
    }
}

- (void)playerDidDie{
    
    //Score
    aSword1.center = CGPointMake(sword1xCoords, sword1yCoords);
    aSword2.center = CGPointMake(sword2xCoords, sword2yCoords);
    deathScreen.hidden = false;
    playerScoreOnScreen.text = [[NSString alloc] initWithFormat:@"%d",playerScore];
    
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

- (IBAction)restartButton:(id)sender {
    
    //Restating Initial Character Placemet
    finnCoordX = finnCharc.center.x;
    finnCoordY = [[UIScreen mainScreen] bounds].size.height * 3/4;
    
    //Restating Initial Sword Placement
    sword1yCoords = -[aSword1 frame].size.height/2;
    sword2yCoords = -[aSword1 frame].size.height/2;
    
    sword1xCoords = [aSword1 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword1 frame].size.width/2);
    
    sword2xCoords = [aSword2 frame].size.width/2 + rand() % (int)([[UIScreen mainScreen] bounds].size.width-[aSword2 frame].size.width/2);
    
    //Run Game
    deathStatus = false;
    deathScreen.hidden = true;
    playerScore = 0;
    playerScoreInGame.text = [[NSString alloc] initWithFormat:@"Your Score: %d",playerScore];
    
}

//Returns Death Value (Boolean)
- (GLboolean)checkCollision:(UIImageView*)aSword{
    
    return (aSword.center.x-[aSword frame].size.width/2 < finnCharc.center.x+[finnCharc frame].size.width/2 && // X Overlap
            
            finnCharc.center.x-[finnCharc frame].size.width/2 < aSword.center.x+[aSword frame].size.width/2 &&
            
            aSword.center.y-[aSword frame].size.height/2 < finnCharc.center.y+[finnCharc frame].size.height/2 && // Y Overlap
            
            finnCharc.center.y-[finnCharc frame].size.height/2 < aSword.center.y+[aSword frame].size.height/2);
}

@end