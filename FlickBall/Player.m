//
//  Player.m
//  FlickBall
//
//  Created by Kirby Gee on 7/8/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Player.h"

@implementation Player

- (instancetype) initWithImageNamed:(NSString *)fileName {
   // note that [super init] will call the SpaceshipNode's init method
   if (self = [super init]) {
      NSLog(@"New player: %@", fileName);
      SKSpriteNode *p = [SKSpriteNode spriteNodeWithImageNamed:fileName];
      [self addChild:p];
      
      [NSTimer scheduledTimerWithTimeInterval:1.0/60.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
   }
   return self;
}

-(void)update:(CFTimeInterval)currentTime {
   /* Called before each frame is rendered */
   NSLog(@"running: %@", NSStringFromCGPoint(self.position));
}

@end
