//
//  ProfileInfoCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileInfoCell.h"

@implementation ProfileInfoCell

@synthesize name;
@synthesize value;

-(NSString*)reuseIdentifier
{
    return @"infoCell";
}

@end
