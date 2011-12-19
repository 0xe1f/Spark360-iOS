//
//  ProfileController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"

@interface ProfileController : GenericController

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, assign) BOOL profileLoaded;

@property (nonatomic, retain) NSMutableDictionary *properties;
@property (nonatomic, retain) NSArray *propertyKeys;
@property (nonatomic, retain) NSDictionary *propertyTitles;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *composeButton;

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account;

-(void)syncCompleted:(NSNotification *)notification;
-(void)refreshProfile;

-(IBAction)refresh:(id)sender;
-(IBAction)addFriend:(id)sender;
-(IBAction)compareGames:(id)sender;
-(IBAction)compose:(id)sender;

@end
