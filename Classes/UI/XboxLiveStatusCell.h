//
//  XboxLiveStatusCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XboxLiveStatusCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *statusName;
@property (nonatomic, assign) IBOutlet UILabel *statusDescription;
@property (nonatomic, assign) IBOutlet UIImageView *statusIcon;

@end
