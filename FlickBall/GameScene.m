//
//  AttributorMyScene.m
//  Flickball
//
//  Created by KirbyGee on 6/23/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "GameScene.h"
#import <math.h>
#import "GameLogic.h"


@interface GameScene ()
@property (nonatomic) SKShapeNode *veloVector;
@end
@implementation GameScene

#define MAX_TAN_DIST 70

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size]) {
      
      self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
      
      _point_array = [[NSMutableArray alloc] init];
      [_point_array addObjectsFromArray:@[[NSValue valueWithCGPoint: CGPointMake(20, 20)],
                                          [NSValue valueWithCGPoint: CGPointMake(20, 200)],
                                          [NSValue valueWithCGPoint: CGPointMake(300, 200)]]];
      
      
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
      
      
      self.returnButton = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
      self.returnButton.position = CGPointMake(300,460);
      self.returnButton.name = @"returnButton";//how the node is identified later
      self.returnButton.zPosition = 1.0;
      [self addChild: self.returnButton];
      
      
      self.startPoint = CGPointMake(20, 20);
      [NSTimer scheduledTimerWithTimeInterval:1.0/60.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
      
      
      [self.player1 hike];
      [self drawPath];
      
   }
   return self;
}

- (void)drawPath
{
   SKShapeNode *line_to_t1 = [SKShapeNode node];
   line_to_t1.path = [GameLogic createPath:self.player1.pointArray];
   [line_to_t1 setStrokeColor:[UIColor whiteColor]];
   [self addChild:line_to_t1];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   
   UITouch *touch = [touches anyObject];
   CGPoint location = [touch locationInNode:self];
   SKNode *node = [self nodeAtPoint:location];
   
   if ([node.name isEqualToString:@"returnButton"]) {
      
      [self.player1 playIsOver];

   } else{
      if (![self.player1 hasActions]){
         [self removeAllChildren];
         
         CGPoint touchPoint = [touch locationInView:self.view];
         touchPoint.y = self.view.frame.size.height - touchPoint.y;
         [self.player1.pointArray addObject:[NSValue valueWithCGPoint:touchPoint]];
         
         if ([_point_array count] >= 3){
            self.player1.position = self.player1.startPosition;
            [self addChild:self.player1];
            [self addChild:self.returnButton];
            [self addChild:self.veloLine];
            [self addChild:self.veloVector];
            [self.player1 hike];
            [self drawPath];
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
