//
//  ViewController.m
//  Death_Dodger
//
//  Created by Joseph Jin on 5/22/16.
//  Copyright (c) 2016 Animator Joe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //This part is what happens to Finn as soon as the app is loaded.

    /*
    spriteFinn.
     */
    finnCoordX = finnCharc.center.x;
    finnCoordY = finnCharc.center.y;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rightButton {
    
    directionStatus.text = @"right";
    finnCoordX+=6;
    [this reDraw];
}

- (IBAction)leftButton {
    
    directionStatus.text = @"left";
    finnCoordX-=6;
    [this reDraw];
}

- (void):reDraw {
    finnCharc.center=CGPointMake(finnCoordX,finnCoordY);
}

@end
