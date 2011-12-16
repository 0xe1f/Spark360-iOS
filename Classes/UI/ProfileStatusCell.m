//
//  ProfileStatusCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileStatusCell.h"

@implementation ProfileStatusCell

@synthesize status;
@synthesize gamerpic;
@synthesize activity;
@synthesize titleIcon;

-(NSString*)reuseIdentifier
{
    return @"statusCell";
}

@end
