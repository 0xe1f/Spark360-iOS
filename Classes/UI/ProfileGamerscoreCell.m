//
//  ProfileGamerscoreCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
