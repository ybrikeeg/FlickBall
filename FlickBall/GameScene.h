//
//  AttributorMyScene.h
//  Flickball
//

//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Player.h"

@interface GameScene : SKScene

@property (nonatomic,retain) NSMutableArray *point_array; // ADDED ON EDI
@property (nonatomic, retain) Player *player1;
@property(nonatomic, retain) SKShapeNode *veloLine;
@property (nonatomic, retain) SKSpriteNode *returnButton;


@property (nonatomic) CGPoint startPoint;
@end
