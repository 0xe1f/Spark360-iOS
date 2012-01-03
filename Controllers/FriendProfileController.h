//
//  FriendProfileController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"
#import "ProfileInfoCell.h"

@interface FriendProfileController : GenericController<UIActionSheetDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *composeButton;

@property (nonatomic, retain) NSMutableDictionary *profile;
@property (nonatomic, retain) NSString *profileScreenName;

-(id)initWithFriendUid:(NSString*)uid
               account:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)compareGames:(id)sender;
-(IBAction)compose:(id)sender;
-(IBAction)showActionMenu:(id)sender;
-(IBAction)viewFriends:(id)sender;

@end
