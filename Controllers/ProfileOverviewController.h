//
//  ProfileOverviewController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"
#import "AccountListController.h"

@interface ProfileOverviewController : GenericController<UITableViewDataSource, AccountSelectionDelegate, UISplitViewControllerDelegate>

-(id)initWithAccount:(XboxLiveAccount*)account;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) IBOutlet UITableViewCell *optionsCell;

@property (nonatomic, retain) NSMutableDictionary *profile;
@property (nonatomic, retain) NSMutableArray *beacons;
@property (nonatomic, assign) NSInteger messagesUnread;
@property (nonatomic, assign) NSInteger friendsOnline;

@property (nonatomic, retain) UIPopoverController *popover;

- (IBAction)viewGames:(id)sender;
- (IBAction)viewMessages:(id)sender;
- (IBAction)viewFriends:(id)sender;

-(IBAction)refresh:(id)sender;
-(IBAction)viewLiveStatus:(id)sender;
-(IBAction)about:(id)sender;

@end
