//
//  ProfileStatusCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileStatusCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *status;
@property (nonatomic, assign) IBOutlet UILabel *activity;
@property (nonatomic, assign) IBOutlet UIImageView *gamerpic;
@property (nonatomic, assign) IBOutlet UIImageView *titleIcon;

@end
