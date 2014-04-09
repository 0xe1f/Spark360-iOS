/*
 * Spark 360 for iOS
 * https://github.com/Melllvar/Spark360-iOS
 *
 * Copyright (C) 2011-2014 Akop Karapetyan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

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
