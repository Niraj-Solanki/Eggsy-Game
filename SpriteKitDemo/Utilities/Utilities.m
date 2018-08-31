//
//  Utilities.m
//  SpriteKitDemo
//
//  Created by Saurabh Passolia on 28/04/17.
//  Copyright © 2017 Neeraj Solanki. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+(NSArray*)actionsArray:(CGFloat)waitDuration fade:(CGFloat)fadeDuration
{
    return @[
             [SKAction waitForDuration:waitDuration],
             [SKAction fadeOutWithDuration:fadeDuration],
             [SKAction removeFromParent],
             ];
}

@end
