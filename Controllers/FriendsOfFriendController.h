//
//  FriendsOfFriendController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericTableViewController.h"

@interface FriendsOfFriendController : GenericTableViewController <UITableViewDataSource>

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSDate *lastUpdated;

@property (nonatomic, retain) NSMutableArray *friendsOfFriend;

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account;

@end
