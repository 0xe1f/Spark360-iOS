//
//  ProfileGamertagCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileGamertagCell.h"

@implementation ProfileGamertagCell

@synthesize screenName;
@synthesize gamerpic;
@synthesize gamerpicContainer;
@synthesize motto;

-(NSString*)reuseIdentifier
{
    return @"gamertagCell";
}

@end
