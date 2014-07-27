//
//  Player.m
//  FlickBall
//
//  Created by Kirby Gee on 7/8/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Player.h"

@interface Player ()
@end
@implementation Player

- (instancetype) initWithImageNamed:(NSString *)fileName {
   // note that [super init] will call the SpaceshipNode's init method
   if (self = [super init]) {
      SKSpriteNode *p = [SKSpriteNode spriteNodeWithImageNamed:fileName];
      [self addChild:p];
      
      self.lastPosition = self.position;
      
      [NSTimer scheduledTimerWithTimeInterval:1.0/15.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
   }
   return self;
}

-(void)update:(CFTimeInterval)currentTime {
   if (self.position.x != self.lastPosition.x && self.position.y != self.lastPosition.y){
      self.lastPosition = self.position;
   }
}

@end
