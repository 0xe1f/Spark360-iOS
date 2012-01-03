//
//  ProfileGamerscoreCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProfileInfoCell.h"

@interface ProfileGamerscoreCell : ProfileInfoCell

@property (nonatomic, assign) IBOutlet UIImageView *icon;

-(void)setGamerscore:(NSNumber*)score;
-(void)setMsp:(NSNumber *)points;

@end
