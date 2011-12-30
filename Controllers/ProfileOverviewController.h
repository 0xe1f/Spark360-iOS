//
//  ProfileOverviewController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"

@interface ProfileOverviewController : GenericController<UITableViewDataSource>

-(id)initWithAccount:(XboxLiveAccount*)account;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSString *gamerpicUrl;

- (IBAction)viewGames:(id)sender;
- (IBAction)viewMessages:(id)sender;
- (IBAction)viewFriends:(id)sender;
- (IBAction)viewLiveStatus:(id)sender;

@end
