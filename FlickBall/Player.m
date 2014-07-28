//
//  Player.m
//  FlickBall
//
//  Created by Kirby Gee on 7/8/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Player.h"
#import "GameLogic.h"

@interface Player ()
@end
@implementation Player

- (instancetype) initWithImageNamed:(NSString *)fileName {
   // note that [super init] will call the SpaceshipNode's init method
   if (self = [super init]) {
      SKSpriteNode *p = [SKSpriteNode spriteNodeWithImageNamed:fileName];
      [self addChild:p];
      
      self.lastPosition = self.position;
      self.startPosition = CGPointMake(20, 20);
      
      self.pointArray = [[NSMutableArray alloc] init];
      [self.pointArray addObjectsFromArray:@[[NSValue valueWithCGPoint: self.startPosition],
                                          [NSValue valueWithCGPoint: CGPointMake(20, 200)],
                                          [NSValue valueWithCGPoint: CGPointMake(300, 200)]]];
   }
   return self;
}

/*
 *    Called when the play starts. Creates the players path and then starts the action
 */
- (void)hike
{
   CGMutablePathRef path = [GameLogic createPath:self.pointArray];
   //create bezier path
   SKAction *run_route = [SKAction followPath:path asOffset:NO orientToPath:NO duration:3.0f];
   [self runAction:run_route];
}

/**
 *    This function creates the bezier path from the player to the starting position
 */
- (UIBezierPath *)createBezierToStart
{
   float slope = [GameLogic slope:self.position and:self.lastPosition];
   CGPoint veloPoint = [GameLogic anchor:self.position point:self.lastPosition slope:slope withDistance:80 inside:NO];
   
   UIBezierPath *bezPath = [UIBezierPath bezierPath];
   [bezPath moveToPoint:self.position];
   
   [bezPath addCurveToPoint:self.startPosition controlPoint1:veloPoint controlPoint2:[GameLogic createControlPointUsingVeloPoint: veloPoint playerPosition:self.position slope: slope]];
   
   return bezPath;
}

/**
 *    Starts the action for the player to run back to the starting position
 */
- (void)returnToStart
{
   UIBezierPath *returnPath = [self createBezierToStart];
   
   [self removeAllActions];
   SKAction *run_route = [SKAction followPath:returnPath.CGPath asOffset:NO orientToPath:NO duration:2.0f];
   [self runAction:run_route];
}

/**
 *    This function is called in the game scene and it sets the lastPosition,
 *    then 0.05f seconds later returns the player to the starting position
 */
- (void)playIsOver
{
   self.lastPosition = self.position;
   [self performSelector:@selector(returnToStart) withObject:nil afterDelay:0.05f];
}
@end
