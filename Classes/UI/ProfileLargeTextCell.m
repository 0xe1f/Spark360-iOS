//
//  ProfileLargeTextCell.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileLargeTextCell.h"

@implementation ProfileLargeTextCell

-(void)setText:(NSString*)text
{
    UILabel *label = self.value;
    label.text = text;
    
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width, 9999);
    CGSize expectedLabelSize = [text sizeWithFont:label.font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:label.lineBreakMode];
    
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
}

-(NSString*)reuseIdentifier
{
    return @"largeTextCell";
}

@end
