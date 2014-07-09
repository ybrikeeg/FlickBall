//
//  AttributorMyScene.h
//  Flickball
//

//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Player.h"

@interface AttributorMyScene : SKScene


@property (nonatomic,retain) NSMutableArray *point_array; // ADDED ON EDI
//@property (nonatomic, retain) SKSpriteNode *player;
@property (nonatomic, retain) Player *player1;
@end
