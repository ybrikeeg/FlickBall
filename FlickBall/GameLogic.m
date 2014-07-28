//
//  GameLogic.m
//  FlickBall
//
//  Created by Kirby Gee on 7/27/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "GameLogic.h"

@implementation GameLogic

#define MAX_TAN_DIST 70

/**
 * This function returns the angle between two points
 */
+(float)calculateAngle:(CGPoint)tangent center:(CGPoint)center
{
   float theta = atan2f(tangent.y - center.y, tangent.x - center.x);
   return (theta < 0)? theta + 2*M_PI : theta;
}

/**
 * This function returns the center point of the two tangent points
 */
+(CGPoint)createCenterWithTan:(CGPoint)t1 tan2:(CGPoint)t2 slope1:(float)slope1 slope2:(float)slope2
{
   CGPoint center;
   
   if (slope1 == 0){
      if (slope2 == slope2 + 1){
         center.x = t1.x;
         center.y = t2.y;
      }else{
         center.x = t1.x;
         center.y = (-1/slope2) * (center.x - t2.x) + t2.y;
      }
   }else if (slope2 == 0){
      center.x = t2.x;
      center.y = (-1/slope1) * (center.x - t1.x) + t1.y;
   }else{
      center.x = ((t2.x/slope2) - (t1.x/slope1) + t2.y - t1.y) / ((1/slope2) - (1/slope1));
      center.y = (-1/slope1) * (center.x - t1.x) + t1.y;
   }
   return center;
}

/**
 * This function returns a point that is a fixed distance from
 * an anchor point that lies on the line formed by anchor and point.
 * Inside determines if it is inbetween the two points or and
 * extrapolation of it
 */
+(CGPoint)anchor:(CGPoint)anchor point:(CGPoint)other slope:(float)slope withDistance:(int)dist inside:(BOOL) inside
{
   if (anchor.x == other.x && anchor.y == other.y){
      return CGPointMake(0, 0);
   }
   float dx = 0, dy = 0;
   
   if (slope == 0) {
      dx = dist;
   }else if (slope == slope + 1 || slope != slope){//slope is infinite (vertical line)
      dy = dist;
   }else{
      dx = sqrtf((powf(dist, 2) / (1 + (powf(slope, 2)))));
      dy = fabs(slope) * fabs(dx);
   }
   
   
   float xDir = -1.0, yDir = -1.0;
   if (anchor.x <= other.x) xDir = 1.0;
   if (anchor.y <= other.y) yDir = 1.0;
   float insideAdjust = (inside)? 1.0 : -1.0;
   
   CGPoint tangentPoint;
   tangentPoint.x = anchor.x + (xDir * dx * insideAdjust);
   tangentPoint.y = anchor.y + (yDir * dy * insideAdjust);
   
   return tangentPoint;
}


/**
 * This function returns the distnce between two points
 */
+(float)distance:(CGPoint)p1 and:(CGPoint)p2
{
   return sqrtf((pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)));
}

/**
 * This function returns the slope of two points
 */
+(float)slope:(CGPoint)p1 and:(CGPoint)p2
{
   return (float)((p1.y - p2.y) / (p1.x - p2.x));
}

/**
 *    Creates a second anchor point for the return bezier path for the player
 */
+ (CGPoint)createControlPointUsingVeloPoint:(CGPoint)velo playerPosition:(CGPoint)playerPosition slope:(float)slope
{
   
   if (slope == slope + 1 || slope != slope){//slope is infinite (vertical line)
      return playerPosition;
   } else if (slope > 0){
      if (velo.y > playerPosition.y){
         return CGPointMake(velo.x, 20);
      } else {
         //basically return the same point. For some reason, it wont work if i return the exact same point
         return CGPointMake(velo.x - 1, velo.y);
      }
   } else if (slope < 0){
      if (velo.y > playerPosition.y){
         return CGPointMake(20, velo.y);
      } else {
         return CGPointMake(velo.x, 20);
      }
   } else if (slope == 0){
      if (velo.x > playerPosition.x){
         return CGPointMake(velo.x, 20);
      } else {
         return CGPointMake(20, velo.y);
      }
   }
   
   return CGPointMake(0, 0);
}

/**
 * This function returns uses all the points to calculate the
 * players running path
 */
+(CGMutablePathRef)createPath:(NSMutableArray *)pointArray
{
   
   NSMutableArray *arr = [NSMutableArray arrayWithArray:pointArray];
   CGMutablePathRef playerPath = CGPathCreateMutable();
   
   for (int i = 1; i < [arr count]-1; i ++){
      
      CGPoint p1 = [[arr objectAtIndex:i-1] CGPointValue];
      CGPoint p2 = [[arr objectAtIndex:i] CGPointValue];
      CGPoint p3 = [[arr objectAtIndex:i+1] CGPointValue];
      
      //create triangle between points, get lengths of each side
      float a = [GameLogic distance: p1 and: p2];
      float b = [GameLogic distance: p2 and: p3];
      float c = [GameLogic distance: p1 and: p3];
      
      //theta is the angle of p2 when p1, p2, p3 form a triangle (law of cosines)
      float theta = acosf((powf(a, 2) + powf(b, 2) - pow(c, 2)) / (2*a*b));
      
      //distance the tangents are from the anchor point (variable based on theta)
      int tanDist = theta/M_PI * MAX_TAN_DIST +  30;
      
      //get the slopes of the line segments
      float slope1 = [GameLogic slope: p1 and: p2];
      float slope2 = [GameLogic slope: p2 and: p3];
      
      //calculate both tangent points
      CGPoint t1 = [GameLogic anchor: p2 point: p1 slope: slope1 withDistance: tanDist inside: YES];
      CGPoint t2 = [GameLogic anchor: p2 point: p3 slope: slope2 withDistance: tanDist inside: YES];
      
      //center point of the two tangent points
      CGPoint center = [GameLogic createCenterWithTan: t1 tan2: t2 slope1: slope1 slope2: slope2];
      
      float radius = [GameLogic distance:t1 and:center];
      //for testing
      float rad2 = [GameLogic distance:t2 and:center];
      //better be the same length
      if (radius != rad2){
         
      }
      
      //angles from each point, needed to calculate delta for arc function
      float startAngle = [GameLogic calculateAngle: t1 center: center];
      float endAngle = [GameLogic calculateAngle: t2 center: center];
      
      
      float delta = startAngle - endAngle;
      
      //adjusts for invalid delta values
      if (delta > M_PI){
         delta -= 2*M_PI;
      }
      if (delta < -M_PI){
         delta += 2*M_PI;
      }
      
      //if the first iteration, the path must be move to point, not add line to point
      if (i == 1){
         CGPathMoveToPoint(playerPath, NULL, p1.x, p1.y);
         
      }else{
         CGPathAddLineToPoint(playerPath, NULL, p1.x, p1.y);
         
      }
      
      //add line from start to the first tangent
      CGPathAddLineToPoint(playerPath, NULL, t1.x, t1.y);
      //add arc
      CGPathAddRelativeArc(playerPath, NULL, center.x, center.y, radius, startAngle, -delta);
      
      //replace p2 with t1
      [arr replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:t2]];
   }
   
   CGPoint p1 = [[arr objectAtIndex:[pointArray count] - 2] CGPointValue];
   CGPoint p2 = [[arr objectAtIndex:[pointArray count] - 1] CGPointValue];
   CGPathAddLineToPoint(playerPath, NULL, p1.x, p1.y);
   CGPathAddLineToPoint(playerPath, NULL, p2.x, p2.y);
   
   return playerPath;
}

@end
