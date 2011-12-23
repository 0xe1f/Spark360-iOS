//
//  PlayerCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerCell.h"

@implementation PlayerCell

@synthesize screenName;
@synthesize activity;
@synthesize gamerScore;
@synthesize gamerpic;
@synthesize titleIcon;

-(NSString*)reuseIdentifier
{
    return @"playerCell";
}

@end
