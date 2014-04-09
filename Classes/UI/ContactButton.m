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

#import "ContactButton.h"

@interface ContactButton (Private)

-(void)resizeButton;

@end

@implementation ContactButton

@synthesize highColor;
@synthesize lowColor;
@synthesize gradientLayer;

#define LOW_GRADIENT  (0xbec9ff)
#define HIGH_GRADIENT (0xdde7f9)
#define BORDER_COLOR  (0xafb5e7)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

-(void)resizeButton
{
    CGSize fits = [self sizeThatFits:self.bounds.size];
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              fits.width + 24, 
                              self.frame.size.height)];
}

- (void)setButtonText:(NSString *)text
{
    [self setTitle:text forState:UIControlStateNormal];
    [self resizeButton];
}

- (void)awakeFromNib;
{
    self.lowColor = UIColorFromRGB(LOW_GRADIENT);
    self.highColor = UIColorFromRGB(HIGH_GRADIENT);
    
    gradientLayer = [[CAGradientLayer alloc] init];
    
    [gradientLayer setBounds:[self bounds]];
    [gradientLayer setPosition:CGPointMake([self bounds].size.width/2, 
                                           [self bounds].size.height/2)];
    
    [[self layer] insertSublayer:gradientLayer atIndex:0];
    
    [[self layer] setCornerRadius:12.0f];
    [[self layer] setMasksToBounds:YES];
    [[self layer] setBorderWidth:1.0f];
    [[self layer] setBorderColor:[UIColorFromRGB(BORDER_COLOR) CGColor]];
    
    [self resizeButton];
    //self.titleLabel.textColor = [UIColor blackColor];
}

- (void)drawRect:(CGRect)rect;
{
    if (self.highColor && self.lowColor)
    {
        [gradientLayer setColors:[NSArray arrayWithObjects:
                                  (id)[self.highColor CGColor], 
                                  (id)[self.lowColor CGColor], 
                                  nil]];
    }
    
    [super drawRect:rect];
}

- (void)dealloc 
{
    self.lowColor = nil;
    self.highColor = nil;
    self.gradientLayer = nil;
    
    [super dealloc];
}

@end
