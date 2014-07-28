//
//  GameLogic.h
//  FlickBall
//
//  Created by Kirby Gee on 7/27/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameLogic : NSObject



+(float)calculateAngle:(CGPoint)tangent center:(CGPoint)center;
+(CGPoint)createCenterWithTan:(CGPoint)t1 tan2:(CGPoint)t2 slope1:(float)slope1 slope2:(float)slope2;
+(CGPoint)anchor:(CGPoint)anchor point:(CGPoint)other slope:(float)slope withDistance:(int)dist inside:(BOOL) inside;
+(float)slope:(CGPoint)p1 and:(CGPoint)p2;
+(float)distance:(CGPoint)p1 and:(CGPoint)p2;
+ (CGPoint)createControlPointUsingVeloPoint:(CGPoint)velo playerPosition:(CGPoint)playerPosition slope:(float)slope;
+(CGMutablePathRef)createPath:(NSMutableArray *)pointArray;


@end
