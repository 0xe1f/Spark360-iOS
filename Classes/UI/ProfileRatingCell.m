//
//  ProfileRatingCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileRatingCell.h"

@implementation ProfileRatingCell

@synthesize starOne;
@synthesize starTwo;
@synthesize starThree;
@synthesize starFour;
@synthesize starFive;

-(void)setRating:(NSNumber *)rating
{
    int res;
    int rep = [rating intValue];
    
    NSArray *views = [NSArray arrayWithObjects:
                      self.starOne,
                      self.starTwo,
                      self.starThree,
                      self.starFour,
                      self.starFive, 
                      nil];
    
    for (int starPos = 0, j = 0, k = 4; starPos < 5; starPos++, j += 4, k += 4)
    {
        if (rep < j) 
            res = 0;
        else if (rep >= k) 
            res = 4;
        else 
            res = rep - j;
        
        NSString *imageName = [[NSBundle mainBundle] pathForResource:[@"xboxStar" stringByAppendingFormat:@"%i", res] 
                                                              ofType:@"png"];
        UIImage *starIcon = [[UIImage alloc] initWithContentsOfFile:imageName];
        
        UIImageView *view = [views objectAtIndex:starPos];
        [view setImage:starIcon];
        
        [starIcon release];
    }
}

-(NSString*)reuseIdentifier
{
    return @"ratingCell";
}

@end
