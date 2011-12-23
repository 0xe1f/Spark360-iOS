//
//  CompareAchievementCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompareAchievementCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *title;
@property (nonatomic, assign) IBOutlet UILabel *description;
@property (nonatomic, assign) IBOutlet UILabel *gamerScore;
@property (nonatomic, assign) IBOutlet UILabel *myAcquired;
@property (nonatomic, assign) IBOutlet UILabel *yourAcquired;
@property (nonatomic, assign) IBOutlet UIImageView *icon;

@end
