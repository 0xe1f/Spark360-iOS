//
//  RecentPlayersController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericTableViewController.h"

@interface RecentPlayersController : GenericTableViewController <UITableViewDataSource>

@property (nonatomic, retain) NSDate *lastUpdated;

@property (nonatomic, retain) NSMutableArray *players;

-(id)initWithAccount:(XboxLiveAccount*)account;

@end
