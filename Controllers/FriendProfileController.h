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

@interface FriendProfileController : GenericController<UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *composeButton;

@property (nonatomic, retain) NSString *friendUid;
@property (nonatomic, retain) NSString *friendScreenName;
@property (nonatomic, assign) BOOL isStale;
@property (nonatomic, assign) NSInteger friendStatus;

@property (nonatomic, retain) NSMutableDictionary *properties;
@property (nonatomic, retain) NSArray *propertyKeys;
@property (nonatomic, retain) NSDictionary *propertyTitles;

-(id)initWithFriendUid:(NSString*)uid
               account:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)compareGames:(id)sender;
-(IBAction)compose:(id)sender;
-(IBAction)showActionMenu:(id)sender;
-(IBAction)viewFriends:(id)sender;

@end
