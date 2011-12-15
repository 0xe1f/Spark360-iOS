//
//  ProfileGamerscoreCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileGamerscoreCell.h"

@implementation ProfileGamerscoreCell

-(void)setGamerscore:(NSNumber *)score
{
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.value.text = [numFormatter stringFromNumber:score];
    
    [numFormatter release];
}

-(NSString*)reuseIdentifier
{
    return @"gamerscoreCell";
}

@end
