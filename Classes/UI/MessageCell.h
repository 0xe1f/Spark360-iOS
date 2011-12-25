//
//  MessageCell.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *title;
@property (nonatomic, assign) IBOutlet UILabel *sender;
@property (nonatomic, assign) IBOutlet UILabel *sent;
@property (nonatomic, assign) IBOutlet UIImageView *gamerpic;
@property (nonatomic, assign) IBOutlet UIImageView *attachment;
@property (nonatomic, assign) IBOutlet UIImageView *unreadMarker;

@end
