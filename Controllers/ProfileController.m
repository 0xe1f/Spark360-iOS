//
//  ProfileController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileController.h"

#import "TaskController.h"
#import "ImageCache.h"

#define OK_BUTTON 1

@interface ProfileController (Private)

-(void)updateWithData:(NSDictionary*)profile;
-(void)requestRefresh;

@end

@implementation ProfileController

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account
{
    if (self = [super initWithScreenName:screenName
                                 account:account
                                 nibName:@"ProfileController"])
    {
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHProfileLoaded
                                               object:nil];
    
    [self requestRefresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHProfileLoaded
                                                  object:nil];
}

-(void)alertView:(UIAlertView *)alertView 
clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == OK_BUTTON)
    {
        [[TaskController sharedInstance] sendAddFriendRequestToScreenName:self.screenName
                                                                  account:self.account];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Notifications

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    
    if ([account isEqualToAccount:self.account])
        [self updateWithData:[notification.userInfo objectForKey:BACHNotificationData]];
}

-(void)onSyncError:(NSNotification *)notification
{
    [super onSyncError:notification];
    
    if (!self.profile)
    {
        // Assume the profile couldn't be found. Close the view
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Actions

-(void)refresh:(id)sender
{
    [self requestRefresh];
}

-(void)addFriend:(id)sender
{
    NSString *title = NSLocalizedString(@"AreYouSure", nil);
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"SendFriendRequestTo_f", nil),
                         self.screenName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title 
                                                        message:message
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
                                              otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    [alertView show];
    [alertView release];
}

#pragma mark - Misc

-(void)requestRefresh;
{
    [[TaskController sharedInstance] loadProfileForScreenName:self.screenName
                                                      account:self.account];
}

-(void)updateWithData:(NSDictionary *)profile
{
    self.screenName = [profile objectForKey:@"screenName"];
    self.profile = [NSMutableDictionary dictionary];
    
    self.title = self.screenName;
    
    NSArray *columns = [NSArray arrayWithObjects:
                        @"iconUrl",
                        @"motto",
                        @"activityText",
                        @"gamerScore",
                        @"rep",
                        @"name",
                        @"location",
                        @"bio",
                        nil];
    
    id value;
    for (NSString *column in columns)
    {
        if ((value = [profile objectForKey:column]))
            [self.profile setObject:value forKey:column];
    }
    
    NSDictionary *lastActivity = [profile objectForKey:@"lastActivity"];
    if (lastActivity)
    {
        if ((value = [lastActivity objectForKey:@"activityTitleId"]))
            [self.profile setObject:value forKey:@"activityTitleId"];
        if ((value = [lastActivity objectForKey:@"activityTitleName"]))
            [self.profile setObject:value forKey:@"activityTitleName"];
        if ((value = [lastActivity objectForKey:@"activityTitleIconUrl"]))
            [self.profile setObject:value forKey:@"activityTitleIconUrl"];
    }
    
    [self.beacons removeAllObjects];
    
    NSArray *beacons = [profile objectForKey:@"beacons"];
    for (NSManagedObject *beacon in beacons)
        [self.beacons addObject:beacon];
    
    [self.tableView reloadData];
}

@end
