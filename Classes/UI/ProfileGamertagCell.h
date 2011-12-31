//
//  ProfileGamertagCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileGamertagCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *screenName;
@property (nonatomic, assign) IBOutlet UILabel *motto;
@property (nonatomic, assign) IBOutlet UIImageView *gamerpic;
@property (nonatomic, assign) IBOutlet UIView *gamerpicContainer;

@end
