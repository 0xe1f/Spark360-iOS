//
//  BeaconInfoCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BeaconInfoCell.h"

@implementation BeaconInfoCell

@synthesize titleIcon;
@synthesize titleName;
@synthesize message;

-(NSString*)reuseIdentifier
{
    return @"beaconInfoCell";
}

@end
