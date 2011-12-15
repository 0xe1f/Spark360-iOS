//
//  ProfileRatingCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileRatingCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *name;
@property (nonatomic, assign) IBOutlet UIImageView *starOne;
@property (nonatomic, assign) IBOutlet UIImageView *starTwo;
@property (nonatomic, assign) IBOutlet UIImageView *starThree;
@property (nonatomic, assign) IBOutlet UIImageView *starFour;
@property (nonatomic, assign) IBOutlet UIImageView *starFive;

-(void)setRating:(NSNumber*)rating;

@end
