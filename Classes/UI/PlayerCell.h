//
//  PlayerCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *screenName;
@property (nonatomic, assign) IBOutlet UILabel *activity;
@property (nonatomic, assign) IBOutlet UILabel *gamerscore;
@property (nonatomic, assign) IBOutlet UIImageView *gamerpic;
@property (nonatomic, assign) IBOutlet UIImageView *titleIcon;

@end
