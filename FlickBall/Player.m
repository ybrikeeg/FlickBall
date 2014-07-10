//
//  Player.m
//  FlickBall
//
//  Created by Kirby Gee on 7/8/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Player.h"

@interface Player ()
@property(nonatomic, retain) SKShapeNode *veloLine;
@end
@implementation Player

- (instancetype) initWithImageNamed:(NSString *)fileName {
   // note that [super init] will call the SpaceshipNode's init method
   if (self = [super init]) {
      NSLog(@"New player: %@", fileName);
      SKSpriteNode *p = [SKSpriteNode spriteNodeWithImageNamed:fileName];
      [self addChild:p];
      
      self.lastPosition = self.position;
      
      self.veloLine = [SKShapeNode node];
      [self addChild:self.veloLine];
      
      [NSTimer scheduledTimerWithTimeInterval:1.0/35.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
   }
   return self;
}

-(void)update:(CFTimeInterval)currentTime {
   self.lastPosition = self.position;
}

@end
