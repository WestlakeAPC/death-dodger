//
//  ViewController.h
//  DeathDodger
//
//  Created by Joseph Jin on 6/14/16.
//  Copyright (c) 2016 Animator Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
    IBOutlet UILabel *directionStatus;
    IBOutlet UIImageView *finnCharc;
    
    IBOutlet UIImageView *aSword1;
    IBOutlet UIImageView *aSword2;
    
    IBOutlet UIView *deathScreen;
    IBOutlet UILabel *playerScoreOnScreen;
    IBOutlet UILabel *playerScoreInGame;
    
    bool debug;
    bool deathStatus;
    
    int playerScore;
    
    CGFloat finnCoordX;
    CGFloat finnCoordY;
    
    CGFloat sword1xCoords;
    CGFloat sword2xCoords;
    CGFloat sword1yCoords;
    CGFloat sword2yCoords;
    
    NSTimer *moveSwordsDown;
    
}

- (IBAction)leftButton:(id)sender;
- (IBAction)rightButton:(id)sender;
- (IBAction)restartButton:(id)sender;

@end

