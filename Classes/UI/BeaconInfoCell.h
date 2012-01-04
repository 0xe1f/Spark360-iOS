//
//  BeaconInfoCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconInfoCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *titleIcon;
@property (nonatomic, assign) IBOutlet UILabel *titleName;
@property (nonatomic, assign) IBOutlet UILabel *message;

@end
