//
//  ActivityInfoCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActivityInfoCell.h"

@implementation ActivityInfoCell

@synthesize titleIcon;
@synthesize titleName;
@synthesize activityInfo;

-(NSString*)reuseIdentifier
{
    return @"activityInfoCell";
}

@end
