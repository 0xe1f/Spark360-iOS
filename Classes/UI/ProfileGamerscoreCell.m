/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
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

#import "ProfileGamerscoreCell.h"

@interface ProfileGamerscoreCell (Private)

-(void)recomputeWidth;

@end

@implementation ProfileGamerscoreCell

@synthesize icon;

-(void)recomputeWidth
{
    UILabel *label = self.value;
    
    CGFloat right = label.frame.origin.x + label.frame.size.width;
    
    CGSize maximumLabelSize = CGSizeMake(9999, label.frame.size.height);
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:label.lineBreakMode];
    
    CGRect newLabelFrame = label.frame;
    
    newLabelFrame.origin.x = right - expectedLabelSize.width;
    newLabelFrame.size.width = expectedLabelSize.width;
    
    label.frame = newLabelFrame;
    
    CGRect newIconFrame = self.icon.frame;
    
    newIconFrame.origin.x = newLabelFrame.origin.x - newIconFrame.size.width - 5;
    
    self.icon.frame = newIconFrame;
}

-(void)setGamerscore:(NSNumber *)score
{
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.value.text = [numFormatter stringFromNumber:score];
    [numFormatter release];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xboxGamerscore"
                                                          ofType:@"png"];
    
    self.icon.image = [UIImage imageWithContentsOfFile:imagePath];
    
    //[self recomputeWidth];
}

-(void)setMsp:(NSNumber *)points
{
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.value.text = [numFormatter stringFromNumber:points];
    [numFormatter release];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xboxMsp"
                                                          ofType:@"png"];
    
    self.icon.image = [UIImage imageWithContentsOfFile:imagePath];
    
    //[self recomputeWidth];
}

-(NSString*)reuseIdentifier
{
    return @"gamerscoreCell";
}

@end
