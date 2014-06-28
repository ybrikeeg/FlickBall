//
//  AttributorMyScene.m
//  Flickball
//
//  Created by KirbyGee on 6/23/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "AttributorMyScene.h"
#import <math.h>

@implementation AttributorMyScene

#define MAX_TAN_DIST 50

//commenasdfasd
//second
//lets code xcode
//another one more

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size]) {
      /* Setup your scene here */
      
      self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
      
      _point_array = [[NSMutableArray alloc] init];
      [_point_array addObjectsFromArray:@[[NSValue valueWithCGPoint: CGPointMake(20, 40)],
                                          [NSValue valueWithCGPoint: CGPointMake(20, 200)],
                                          [NSValue valueWithCGPoint: CGPointMake(300, 200)]]];
      
      [self create_path: _point_array];
      
      _player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
      _player.position = [[_point_array objectAtIndex:0] CGPointValue];
      _player.name = @"player";//how the node is identified later
      _player.zPosition = 1.0;
      [self addChild:_player];
      
   }
   return self;
}

-(float)distance:(CGPoint)p1 and:(CGPoint)p2{
   return sqrtf((pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)));
}

-(float)slope:(CGPoint)p1 and:(CGPoint)p2{
   return (float)((p1.y - p2.y) / (p1.x - p2.x));
}

-(CGPoint)anchor:(CGPoint)anchor point:(CGPoint)other slope:(float)slope withDistance:(int)dist inside:(BOOL) inside{
   float dx = 0, dy = 0;
   NSLog(@"Slopeszzz: %f", slope);
   if (slope == 0) {
      NSLog(@"Slope is zero");
      dx = dist;
   }else if (slope == slope + 1){
      NSLog(@"Slope is inf");
      dy = dist;
   }else{
      dx = sqrtf((powf(dist, 2) / (1 + (powf(slope, 2)))));
      dy = fabs(slope) * fabs(dx);
   }
   
   int x_dir = -1, y_dir = -1;
   if (anchor.x < other.x) x_dir = 1;
   if (anchor.y < other.y) y_dir = 1;
   
   int inside_adjust = (inside)? 1 : -1;
   
   CGPoint tangent_point;
   tangent_point.x = anchor.x + (x_dir * dx * inside_adjust);
   tangent_point.y = anchor.y + (y_dir * dy * inside_adjust);
   
   return tangent_point;
}

-(float)calculate_angle:(CGPoint)tangent center:(CGPoint)center{
   float theta = atan2f(tangent.y - center.y, tangent.x - center.x);
   return (theta < 0)? theta + 2*M_PI : theta;
}

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
-(void)create_path:(NSMutableArray *)point_array1{
   
   /*
    for (int i = 0; i < [point_array count]-1; i ++){
    CGPoint p1 = [[point_array objectAtIndex:i] CGPointValue];
    CGPoint p2 = [[point_array objectAtIndex:i+1] CGPointValue];
    
    SKShapeNode *line_to_t1 = [SKShapeNode node];
    
    CGMutablePathRef t1_path = CGPathCreateMutable();
    CGPathMoveToPoint(t1_path, NULL, p1.x, p1.y);
    CGPathAddLineToPoint(t1_path, NULL, p2.x, p2.y);
    
    line_to_t1.lineWidth = 10.0f;
    line_to_t1.path = t1_path;
    
    [line_to_t1 setStrokeColor:[UIColor blueColor]];
    
    [self addChild:line_to_t1];
    }
    */
   NSMutableArray *arr = [NSMutableArray arrayWithArray:point_array1];
   CGMutablePathRef player_path = CGPathCreateMutable();
   
   for (int i = 1; i < [arr count]-1; i ++){
      NSLog(@"Print points: %@", NSStringFromCGPoint([[arr objectAtIndex:i] CGPointValue]));
      
      CGPoint p1 = [[arr objectAtIndex:i-1] CGPointValue];
      CGPoint p2 = [[arr objectAtIndex:i] CGPointValue];
      CGPoint p3 = [[arr objectAtIndex:i+1] CGPointValue];
      
      //create triangle between points, get lengths of each side
      float a = [self distance: p1 and: p2];
      float b = [self distance: p2 and: p3];
      float c = [self distance: p1 and: p3];
      NSLog(@"Distances: %f, %f, %f", a, b, c);
      
      //theta is the angle of p2 when p1, p2, p3 form a triangle (law of cosines)
      float theta = acosf((powf(a, 2) + powf(b, 2) - pow(c, 2)) / (2*a*b));
      NSLog(@"Theta: %f", theta);
      
      int tan_dist = theta/M_PI * MAX_TAN_DIST;
      tan_dist = 45;
      //get the slopes of the line segments
      float slope1 = [self slope: p1 and: p2];
      float slope2 = [self slope: p2 and: p3];
      NSLog(@"Slopes: %f, %f", slope1, slope2);
      
      CGPoint t1 = [self anchor: p2 point: p1 slope: slope1 withDistance: tan_dist inside: YES];
      CGPoint t2 = [self anchor: p2 point: p3 slope: slope2 withDistance: tan_dist inside: YES];
      NSLog(@"Tangent points: %@, %@", NSStringFromCGPoint(t1), NSStringFromCGPoint(t2));
      
      CGPoint center = [self create_center_with_tan: t1 tan2: t2 slope1: slope1 slope2: slope2];
      
      
      /*
       
       //draw line to center point of circle for testing
       SKShapeNode *line_to_center = [SKShapeNode node];
       
       CGMutablePathRef center_path = CGPathCreateMutable();
       CGPathMoveToPoint(center_path, NULL, t1.x, t1.y);
       CGPathAddLineToPoint(center_path, NULL, center.x, center.y);
       
       line_to_center.path = center_path;
       [line_to_center setStrokeColor:[UIColor greenColor]];
       
       [self addChild:line_to_center];
       
       
       //draw line to center point of circle for testing
       SKShapeNode *line_to_center2 = [SKShapeNode node];
       
       CGMutablePathRef center_path2 = CGPathCreateMutable();
       CGPathMoveToPoint(center_path2, NULL, t2.x, t2.y);
       CGPathAddLineToPoint(center_path2, NULL, center.x, center.y);
       
       line_to_center2.path = center_path2;
       [line_to_center2 setStrokeColor:[UIColor purpleColor]];
       
       [self addChild:line_to_center2];
       */
      
      float radius = [self distance:t1 and:center];
      //for testing
      float rad2 = [self distance:t2 and:center];
      //better be the same length
      if (radius != rad2){
         
      }
      NSLog(@"Distances: %f, %f", radius, rad2);
      
      float start_angle = [self calculate_angle: t1 center: center];
      float end_angle = [self calculate_angle: t2 center: center];
      
      
      NSLog(@"Start angles: %f, %f", start_angle, end_angle);
      float delta = start_angle - end_angle;
      if (delta > M_PI){
         NSLog(@"Adjusting2");
         delta -= 2*M_PI;
      }
      
      if (delta < -M_PI){
         NSLog(@"Adjusting2");
         delta += 2*M_PI;
      }
      NSLog(@"Delta: %f", delta);
      
      //create the line from p1 to t1
      //SKShapeNode *line_to_t1 = [SKShapeNode node];
      
      //CGMutablePathRef t1_path = CGPathCreateMutable();
      if (i == 1){
         CGPathMoveToPoint(player_path, NULL, p1.x, p1.y);
         
      }else{
         CGPathAddLineToPoint(player_path, NULL, p1.x, p1.y);
         
      }
      CGPathAddLineToPoint(player_path, NULL, t1.x, t1.y);
      CGPathAddRelativeArc(player_path, NULL, center.x, center.y, radius, start_angle, -delta);
      //line_to_t1.path = player_path;
      //[line_to_t1 setStrokeColor:[UIColor whiteColor]];
      
      //[self addChild:line_to_t1];
      
      
      
      /*
       //create the line from t2 to p3
       SKShapeNode *line_to_t2 = [SKShapeNode node];
       
       CGMutablePathRef t2_path = CGPathCreateMutable();
       CGPathMoveToPoint(player_path, NULL, t2.x, t2.y);
       CGPathAddLineToPoint(player_path, NULL, p3.x, p3.y);
       
       line_to_t2.path = player_path;
       [line_to_t2 setStrokeColor:[UIColor whiteColor]];
       
       [self addChild:line_to_t2];
       */
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
   
   NSLog(@"%@", _point_array);
   
   SKAction *run_route = [SKAction followPath:player_path asOffset:NO orientToPath:NO duration:2.0f];
   [_player runAction:run_route];
   
}

-(void)update:(CFTimeInterval)currentTime {
   /* Called before each frame is rendered */
   
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   [self removeAllChildren];
   UITouch *touch = [touches anyObject];
   CGPoint touchPoint = [touch locationInView:self.view];
   touchPoint.y = self.view.frame.size.height - touchPoint.y;
   [_point_array addObject:[NSValue valueWithCGPoint:touchPoint]];
   
   if ([_point_array count] >= 3){
      _player.position = [[_point_array objectAtIndex:0] CGPointValue];
      [self addChild:_player];
      [self create_path:_point_array];
   }
   NSLog(@"New Point %f %f", touchPoint.x, touchPoint.y);
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
   [self removeAllChildren];
   [_point_array removeAllObjects];
}
@end
