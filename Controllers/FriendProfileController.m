//
//  FriendProfileController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendProfileController.h"

#import "XboxLive.h"
#import "ImageCache.h"
#import "TaskController.h"

#import "FriendsOfFriendController.h"

#define OK_BUTTON 1

#define STATUS_FRIEND      1000
#define STATUS_INVITE_SENT 1001
#define STATUS_INVITE_RCVD 1002

@interface FriendProfileController (Private) 

-(BOOL)updateData;

@end

@implementation FriendProfileController
{
    NSInteger profileStatus;
}

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account
{
    if (self = [super initWithScreenName:screenName
                                 account:account
                                 nibName:@"FriendProfileController"])
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
    
    BOOL isStale = [self updateData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHFriendProfileSynced
                                               object:nil];
    
    if (isStale)
        [self refresh:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHFriendProfileSynced
                                                  object:nil];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet 
didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (actionSheet.tag == STATUS_FRIEND)
    {
        if (buttonIndex == 0) // Delete friend
        {
            [[TaskController sharedInstance] removeFromFriendsScreenName:self.screenName
                                                                 account:self.account
                                                    managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (actionSheet.tag == STATUS_INVITE_RCVD)
    {
        if (buttonIndex == 0) // Approve request
        {
            [[TaskController sharedInstance] approveFriendRequestScreenName:self.screenName
                                                                    account:self.account
                                                       managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (buttonIndex == 1) // Reject request
        {
            [[TaskController sharedInstance] rejectFriendRequestScreenName:self.screenName
                                                                   account:self.account
                                                      managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (actionSheet.tag == STATUS_INVITE_SENT)
    {
        if (buttonIndex == 0) // Cancel request
        {
            [[TaskController sharedInstance] cancelFriendRequestScreenName:self.screenName
                                                                   account:self.account
                                                      managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Notifications

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    NSString *uid = [notification.userInfo objectForKey:BACHNotificationUid];
    
    if ([account isEqualToAccount:self.account] && 
        [uid isEqualToString:self.screenName])
    {
        [self updateData];
    }
}

#pragma mark - Misc

-(void)removeFriend
{
    NSString *title = NSLocalizedString(@"AreYouSure", nil);
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"RemoveFromFriends_f", nil),
                         self.screenName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title 
                                                        message:message
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
                                              otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    [alertView show];
    [alertView release];
}

-(BOOL)updateData
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                                         inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile.uuid == %@", 
                              self.screenName, self.account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:request 
                                                         error:nil];
    
    NSManagedObject *profile = [array lastObject];
    
    [request release];
    
    BOOL isStale = YES;
    
    if (profile)
    {
        isStale = [self.account isDataStale:[profile valueForKey:@"profileLastUpdated"]];
        
        id value;
        
        self.screenName = [profile valueForKey:@"screenName"];
        self.profile = [NSMutableDictionary dictionary];
        
        self.title = self.screenName;
        
        NSArray *columns = [NSArray arrayWithObjects:
                            @"iconUrl",
                            @"motto",
                            @"activityText",
                            @"activityTitleIconUrl",
                            @"activityTitleName",
                            @"activityTitleId",
                            @"gamerScore",
                            @"rep",
                            @"name",
                            @"location",
                            @"bio",
                            nil];
        
        for (NSString *column in columns)
        {
            if ((value = [profile valueForKey:column]))
                [self.profile setObject:value forKey:column];
        }
        
        if ([[profile valueForKey:@"isIncoming"] boolValue])
        {
            profileStatus = STATUS_INVITE_RCVD;
        }
        else if ([[profile valueForKey:@"isOutgoing"] boolValue])
        {
            profileStatus = STATUS_INVITE_SENT;
        }
        else
        {
            profileStatus = STATUS_FRIEND;
        }
    }
    
    // Beacons
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"listOrder"
                                                                     ascending:YES];
    
    entityDescription = [NSEntityDescription entityForName:@"XboxFriendBeacon"
                                    inManagedObjectContext:managedObjectContext];
    
    predicate = [NSPredicate predicateWithFormat:@"friend.uid == [c] %@ AND friend.profile.uuid == %@",
                 self.screenName, self.account.uuid];
    
    request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *beacons = [managedObjectContext executeFetchRequest:request 
                                                           error:nil];
    
    [request release];
    
    [self.beacons removeAllObjects];
    
    for (NSManagedObject *beacon in beacons)
    {
        [self.beacons addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [beacon valueForKey:@"gameBoxArtUrl"], @"gameBoxArtUrl",
                                 [beacon valueForKey:@"gameName"], @"gameName",
                                 [beacon valueForKey:@"gameUid"], @"gameUid",
                                 [beacon valueForKey:@"message"], @"message",
                                 nil]];
    }
    
    [self.tableView reloadData];
    
    return isStale;
}

#pragma mark - Actions

-(void)refresh:(id)sender
{
    [[TaskController sharedInstance] synchronizeFriendProfileForUid:self.screenName
                                                            account:self.account
                                               managedObjectContext:managedObjectContext];
}

-(void)showActionMenu:(id)sender
{
    UIActionSheet *actionSheet = nil;
    if (profileStatus == STATUS_FRIEND)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:
                       NSLocalizedString(@"RemoveFriend", nil), 
                       nil];
    }
    else if (profileStatus == STATUS_INVITE_RCVD)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:
                       NSLocalizedString(@"ApproveRequest", nil),
                       NSLocalizedString(@"RejectRequest", nil),
                       nil];
    }
    else if (profileStatus == STATUS_INVITE_SENT)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:
                       NSLocalizedString(@"CancelRequest", nil),
                       nil];
    }
    
    if (actionSheet)
    {
        actionSheet.tag = profileStatus;
        actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        
        [actionSheet showInView:self.view];
        [actionSheet release];	
    }
}

-(void)viewFriends:(id)sender
{
    FriendsOfFriendController *ctlr = [[FriendsOfFriendController alloc] initWithScreenName:self.screenName
                                                                                    account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

@end
