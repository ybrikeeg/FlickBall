//
//  AttributorMyScene.m
//  Flickball
//
//  Created by KirbyGee on 6/23/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "AttributorMyScene.h"
#import <math.h>

@interface AttributorMyScene ()
@property (nonatomic) SKShapeNode *veloVector;
@end
@implementation AttributorMyScene

#define MAX_TAN_DIST 70

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size]) {
      
      self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
      
      _point_array = [[NSMutableArray alloc] init];
      [_point_array addObjectsFromArray:@[[NSValue valueWithCGPoint: CGPointMake(20, 20)],
                                          [NSValue valueWithCGPoint: CGPointMake(20, 200)],
                                          [NSValue valueWithCGPoint: CGPointMake(300, 200)]]];
      
      [self create_path: _point_array];
      
      
      self.player1 = [[Player alloc] initWithImageNamed:@"player"];
      self.player1.position = [[_point_array objectAtIndex:0] CGPointValue];
      self.player1.zPosition = 1.0;
      [self addChild:self.player1];
      
      
      self.veloLine = [SKShapeNode node];
      [self.veloLine setStrokeColor:[UIColor redColor]];
      self.veloLine.zPosition = 50.0f;
      [self addChild:self.veloLine];
      
      self.veloVector = [SKShapeNode node];
      [self.veloVector setStrokeColor:[UIColor orangeColor]];
      self.veloVector.zPosition = 50.0f;
      [self addChild:self.veloVector];
      
      [self create_path:_point_array];
      
      
      self.returnButton = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
      self.returnButton.position = CGPointMake(300,460);
      self.returnButton.name = @"returnButton";//how the node is identified later
      self.returnButton.zPosition = 1.0;
      [self addChild: self.returnButton];
      
      
      _startPoint = CGPointMake(20, 20);
      [NSTimer scheduledTimerWithTimeInterval:1.0/60.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
      
      
   }
   return self;
}

/**
 * This function returns the distnce between two points
 */
-(float)distance:(CGPoint)p1 and:(CGPoint)p2{
   return sqrtf((pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)));
}

/**
 * This function returns the slope of two points
 */
-(float)slope:(CGPoint)p1 and:(CGPoint)p2{
   return (float)((p1.y - p2.y) / (p1.x - p2.x));
}

/**
 * This function returns a point that is a fixed distance from
 * an anchor point that lies on the line formed by anchor and point.
 * Inside determines if it is inbetween the two points or and
 * extrapolation of it
 */
-(CGPoint)anchor:(CGPoint)anchor point:(CGPoint)other slope:(float)slope withDistance:(int)dist inside:(BOOL) inside{
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
   
   
   float x_dir = -1.0, y_dir = -1.0;
   if (anchor.x <= other.x) x_dir = 1.0;
   if (anchor.y <= other.y) y_dir = 1.0;
   float inside_adjust = (inside)? 1.0 : -1.0;
   
   CGPoint tangent_point;
   tangent_point.x = anchor.x + (x_dir * dx * inside_adjust);
   tangent_point.y = anchor.y + (y_dir * dy * inside_adjust);
   
   return tangent_point;
}

/**
 * This function returns the angle between two points
 */
-(float)calculate_angle:(CGPoint)tangent center:(CGPoint)center{
   float theta = atan2f(tangent.y - center.y, tangent.x - center.x);
   return (theta < 0)? theta + 2*M_PI : theta;
}

/**
 * This function returns the center point of the two tangent points
 */
-(CGPoint)create_center_with_tan:(CGPoint)t1 tan2:(CGPoint)t2 slope1:(float)slope1 slope2:(float)slope2{
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
 * This function returns uses all the points to calculate the
 * players running path
 */
-(void)create_path:(NSMutableArray *)point_array1{
   for (int i = 0; i < [point_array1 count]-1; i ++){
      CGPoint p1 = [[point_array1 objectAtIndex:i] CGPointValue];
      CGPoint p2 = [[point_array1 objectAtIndex:i+1] CGPointValue];
      
      SKShapeNode *line_to_t1 = [SKShapeNode node];
      
      CGMutablePathRef t1_path = CGPathCreateMutable();
      CGPathMoveToPoint(t1_path, NULL, p1.x, p1.y);
      CGPathAddLineToPoint(t1_path, NULL, p2.x, p2.y);
      
      line_to_t1.lineWidth = 10.0f;
      line_to_t1.path = t1_path;
      
      [line_to_t1 setStrokeColor:[UIColor blueColor]];
      
      [self addChild:line_to_t1];
   }
   
   NSMutableArray *arr = [NSMutableArray arrayWithArray:point_array1];
   CGMutablePathRef player_path = CGPathCreateMutable();
   
   for (int i = 1; i < [arr count]-1; i ++){
      
      CGPoint p1 = [[arr objectAtIndex:i-1] CGPointValue];
      CGPoint p2 = [[arr objectAtIndex:i] CGPointValue];
      CGPoint p3 = [[arr objectAtIndex:i+1] CGPointValue];
      
      //create triangle between points, get lengths of each side
      float a = [self distance: p1 and: p2];
      float b = [self distance: p2 and: p3];
      float c = [self distance: p1 and: p3];
      
      //theta is the angle of p2 when p1, p2, p3 form a triangle (law of cosines)
      float theta = acosf((powf(a, 2) + powf(b, 2) - pow(c, 2)) / (2*a*b));
      
      //distance the tangents are from the anchor point (variable based on theta)
      int tan_dist = theta/M_PI * MAX_TAN_DIST +  30;
      
      //get the slopes of the line segments
      float slope1 = [self slope: p1 and: p2];
      float slope2 = [self slope: p2 and: p3];
      
      //calculate both tangent points
      CGPoint t1 = [self anchor: p2 point: p1 slope: slope1 withDistance: tan_dist inside: YES];
      CGPoint t2 = [self anchor: p2 point: p3 slope: slope2 withDistance: tan_dist inside: YES];
      
      //center point of the two tangent points
      CGPoint center = [self create_center_with_tan: t1 tan2: t2 slope1: slope1 slope2: slope2];
      
      float radius = [self distance:t1 and:center];
      //for testing
      float rad2 = [self distance:t2 and:center];
      //better be the same length
      if (radius != rad2){
         
      }
      
      //angles from each point, needed to calculate delta for arc function
      float start_angle = [self calculate_angle: t1 center: center];
      float end_angle = [self calculate_angle: t2 center: center];
      
      
      float delta = start_angle - end_angle;
      
      //adjusts for invalid delta values
      if (delta > M_PI){
         delta -= 2*M_PI;
      }
      if (delta < -M_PI){
         delta += 2*M_PI;
      }
      
      //if the first iteration, the path must be move to point, not add line to point
      if (i == 1){
         CGPathMoveToPoint(player_path, NULL, p1.x, p1.y);
         
      }else{
         CGPathAddLineToPoint(player_path, NULL, p1.x, p1.y);
         
      }
      
      //add line from start to the first tangent
      CGPathAddLineToPoint(player_path, NULL, t1.x, t1.y);
      //add arc
      CGPathAddRelativeArc(player_path, NULL, center.x, center.y, radius, start_angle, -delta);
      
      //replace p2 with t1
      [arr replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:t2]];
   }
   
   CGPoint p1 = [[arr objectAtIndex:[point_array1 count] - 2] CGPointValue];
   CGPoint p2 = [[arr objectAtIndex:[point_array1 count] - 1] CGPointValue];
   CGPathAddLineToPoint(player_path, NULL, p1.x, p1.y);
   CGPathAddLineToPoint(player_path, NULL, p2.x, p2.y);
   
   SKShapeNode *line_to_t1 = [SKShapeNode node];
   line_to_t1.path = player_path;
   [line_to_t1 setStrokeColor:[UIColor whiteColor]];
   
   [self addChild:line_to_t1];
   
   
   SKAction *run_route = [SKAction followPath:player_path asOffset:NO orientToPath:NO duration:3.0f];
   [self.player1 runAction:run_route];
   
}

- (CGPoint)createControlPointUsingVeloPoint:(CGPoint)velo playerPosition:(CGPoint)playerPosition slope:(float)slope
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

- (UIBezierPath *)returnToStart
{
   float slope = [self slope:self.player1.position and:self.player1.lastPosition];
   CGPoint veloPoint = [self anchor:self.player1.position point:self.player1.lastPosition slope:slope withDistance:80 inside:NO];
   
   UIBezierPath *bezPath = [UIBezierPath bezierPath];
   [bezPath moveToPoint:self.player1.position];

   [bezPath addCurveToPoint:CGPointMake(20, 20) controlPoint1:veloPoint controlPoint2:[self createControlPointUsingVeloPoint: veloPoint playerPosition:self.player1.position slope: slope]];
   
   return bezPath;
}

- (void)update:(NSTimeInterval)currentTime{
   CGMutablePathRef pathToDraw = CGPathCreateMutable();
   CGPathMoveToPoint(pathToDraw, NULL, self.player1.position.x, self.player1.position.y);
   float slope = [self slope:self.player1.position and:self.player1.lastPosition];
   
   if (!isnan(slope)){
      
      CGPoint veloP = [self anchor:self.player1.position point:self.player1.lastPosition slope:slope withDistance:100 inside:NO];
      CGPathAddLineToPoint(pathToDraw, NULL, veloP.x, veloP.y);
      self.veloVector.path = pathToDraw;
      self.veloLine.path = [self returnToStart].CGPath;
   }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
   
   UITouch *touch = [touches anyObject];
   CGPoint location = [touch locationInNode:self];
   SKNode *node = [self nodeAtPoint:location];
   
   if ([node.name isEqualToString:@"returnButton"]) {
      NSLog(@"returning");
      UIBezierPath *returnPath = [self returnToStart];
      [self.player1 removeAllActions];
      SKAction *run_route = [SKAction followPath:returnPath.CGPath asOffset:NO orientToPath:NO duration:2.0f];
      [self.player1 runAction:run_route];
      self.veloLine.path = returnPath.CGPath;
      
   }else{
      if (![self.player1 hasActions]){
         [self removeAllChildren];
         
         CGPoint touchPoint = [touch locationInView:self.view];
         touchPoint.y = self.view.frame.size.height - touchPoint.y;
         [_point_array addObject:[NSValue valueWithCGPoint:touchPoint]];
         
         if ([_point_array count] >= 3){
            self.player1.position = [[_point_array objectAtIndex:0] CGPointValue];
            [self addChild:self.player1];
            [self addChild:self.returnButton];
            [self addChild:self.veloLine];
            [self addChild:self.veloVector];
            [self create_path:_point_array];
         }
      }
   }
}
/*
 - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 
 UITouch *touch = [touches anyObject];
 CGPoint location = [touch locationInNode:self];
 
 SKNode *node = [self nodeAtPoint:location];
 if (![node.name isEqualToString:@"returnButton"]) {
 [self removeAllChildren];
 
 CGPoint touchPoint = [touch locationInView:self.view];
 touchPoint.y = self.view.frame.size.height - touchPoint.y;
 [_point_array addObject:[NSValue valueWithCGPoint:touchPoint]];
 
 if ([_point_array count] >= 3){
 _player1.position = [[_point_array objectAtIndex:0] CGPointValue];
 [self addChild:_player1];
 [self addChild:self.veloLine];
 [self create_path:_point_array];
 }
 }
 }
 */
/*
 -(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
 [self removeAllChildren];
 [_point_array removeAllObjects];
 }
 */
@end
