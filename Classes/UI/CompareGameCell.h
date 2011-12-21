//
//  CompareGameCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompareGameCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *title;
@property (nonatomic, assign) IBOutlet UILabel *myAchievements;
@property (nonatomic, assign) IBOutlet UILabel *myGamerscore;
@property (nonatomic, assign) IBOutlet UILabel *yourAchievements;
@property (nonatomic, assign) IBOutlet UILabel *yourGamerscore;
@property (nonatomic, assign) IBOutlet UIImageView *boxArt;

@end
