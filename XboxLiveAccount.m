//
//  XboxLiveAccount.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLiveAccount.h"

@implementation XboxLiveAccount

@synthesize gamertag;

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    return self;
}

- (void)dealloc
{
    [self.gamertag release];
    
    [super dealloc];
}

@end
