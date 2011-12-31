//
//  ProfileOptionsCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileOptionsCell.h"

@implementation ProfileOptionsCell

@synthesize friends;
@synthesize messages;
@synthesize games;

-(NSString*)reuseIdentifier
{
    return @"optionsCell";
}

@end
