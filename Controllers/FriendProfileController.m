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

#import "MessageCompositionController.h"
#import "CompareGamesController.h"
#import "FriendsOfFriendController.h"

#import "ProfileInfoCell.h"
#import "ProfileGamerscoreCell.h"
#import "ProfileRatingCell.h"
#import "ProfileLargeTextCell.h"
#import "ProfileStatusCell.h"
#import "ProfileGamertagCell.h"
#import "BeaconInfoCell.h"
#import "ActivityInfoCell.h"

#define OK_BUTTON_INDEX 1

#define STATUS_FRIEND      1000
#define STATUS_INVITE_SENT 1001
#define STATUS_INVITE_RCVD 1002

@interface FriendProfileController (Private) 

-(BOOL)updateData;
-(void)syncCompleted:(NSNotification *)notification;

@end

@implementation FriendProfileController
{
    NSArray *statSectionColumns;
    NSArray *statSectionLabels;
    NSInteger profileStatus;
}

@synthesize tableView;

@synthesize composeButton;

@synthesize profile = _profile;
@synthesize beacons = _beacons;
@synthesize profileScreenName = _profileScreenName;

-(id)initWithFriendUid:(NSString*)uid
               account:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"FriendProfileController"])
    {
        self.beacons = [[NSMutableArray alloc] init];
        self.profileScreenName = uid;
        self.profile = nil;
        
        statSectionColumns = [[NSArray arrayWithObjects:
                               @"gamerScore",
                               @"rep",
                               @"name",
                               @"location",
                               @"bio",
                               nil] retain];
        
        statSectionLabels = [[NSArray arrayWithObjects:
                              NSLocalizedString(@"InfoGamerscore", nil),
                              NSLocalizedString(@"InfoRep", nil),
                              NSLocalizedString(@"InfoName", nil),
                              NSLocalizedString(@"InfoLocation", nil), 
                              NSLocalizedString(@"InfoBio", nil), 
                              nil] retain];
    }
    
    return self;
}

-(void)dealloc
{
    self.profile = nil;
    self.beacons = nil;
    
    [statSectionColumns release];
    statSectionColumns = nil;
    [statSectionLabels release];
    statSectionLabels = nil;
    
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
    
    self.title = self.profileScreenName;
    self.composeButton.enabled = [self.account canSendMessages];
    
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return [self.beacons count] + 1; // extra for latest activity
    else if (section == 2)
        return [statSectionColumns count];
    
    return 0;
}

- (CGFloat)tableView:tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 52;
    }
    else if (indexPath.section == 1)
    {
        return 44;
    }
    else if (indexPath.section == 2)
    {
        NSString *column = [statSectionColumns objectAtIndex:indexPath.row];
        
        if ([column isEqualToString:@"bio"])
        {
            NSString *text = [self.profile objectForKey:column];
            
            CGSize s = [text sizeWithFont:[UIFont systemFontOfSize:12] 
                        constrainedToSize:CGSizeMake(280, 500)];
            
            return s.height + 24;
        }
        
        return 24;
    }
    
    return 42;
}

- (void)tableView:(UITableView *)tableView 
  willDisplayCell:(UITableViewCell *)cell 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // Make the background of the cell transparent
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
        
        [backView release];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            ProfileGamertagCell *gtCell = (ProfileGamertagCell*)[self.tableView dequeueReusableCellWithIdentifier:@"gamertagCell"];
            
            if (!gtCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileGamertagCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        gtCell = (ProfileGamertagCell*)object;
                        break;
                    }
                }
            }
            
            gtCell.screenName.text = self.profileScreenName;
            gtCell.gamerpic.image = [[ImageCache sharedInstance] getCachedFile:[self.profile objectForKey:@"iconUrl"]
                                                                  notifyObject:self
                                                                notifySelector:@selector(imageLoaded:)];
            
            NSString *motto = nil;
            if ([self.profile objectForKey:@"motto"])
            {
                motto = [NSString stringWithFormat:NSLocalizedString(@"MottoTemplate_f", nil),
                         [self.profile objectForKey:@"motto"]];
            }
            
            gtCell.motto.text = motto;
            
            cell = gtCell;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            // Latest activity
            
            ActivityInfoCell *aiCell = (ActivityInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:@"activityInfoCell"];
            
            if (!aiCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ActivityInfoCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        aiCell = (ActivityInfoCell*)object;
                        break;
                    }
                }
            }
            
            aiCell.titleName.text = [self.profile objectForKey:@"activityTitleName"];
            aiCell.activityInfo.text = [self.profile objectForKey:@"activityText"];
            aiCell.titleIcon.image = [[ImageCache sharedInstance] getCachedFile:[self.profile objectForKey:@"activityTitleIconUrl"]
                                                                       cropRect:CGRectMake(0, 16, 85, 85)
                                                                   notifyObject:self
                                                                 notifySelector:@selector(imageLoaded:)];
            
            cell = aiCell;
        }
        else
        {
            // Beacon
            
            BeaconInfoCell *biCell = (BeaconInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:@"beaconInfoCell"];
            
            if (!biCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"BeaconInfoCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        biCell = (BeaconInfoCell*)object;
                        break;
                    }
                }
            }
            
            NSDictionary *beacon = [self.beacons objectAtIndex:indexPath.row - 1];
            
            biCell.titleName.text = [beacon objectForKey:@"gameName"];
            biCell.message.text = [beacon objectForKey:@"message"];
            biCell.titleIcon.image = [[ImageCache sharedInstance] getCachedFile:[beacon objectForKey:@"gameBoxArtUrl"]
                                                                       cropRect:CGRectMake(0, 16, 85, 85)
                                                                   notifyObject:self
                                                                 notifySelector:@selector(imageLoaded:)];
            
            cell = biCell;
        }
    }
    else if (indexPath.section == 2)
    {
        NSString *column = [statSectionColumns objectAtIndex:indexPath.row];
        ProfileCell *pCell = nil;
        
        if ([column isEqualToString:@"gamerScore"])
        {
            ProfileGamerscoreCell *gsCell = (ProfileGamerscoreCell*)[self.tableView dequeueReusableCellWithIdentifier:@"gamerscoreCell"];
            
            if (!gsCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileGamerscoreCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        gsCell = (ProfileGamerscoreCell*)object;
                        break;
                    }
                }
            }
            
            [gsCell setGamerscore:[self.profile objectForKey:column]];
            
            pCell = gsCell;
        }
        else if ([column isEqualToString:@"rep"])
        {
            ProfileRatingCell *starCell = (ProfileRatingCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
            
            if (!starCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileRatingCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        starCell = (ProfileRatingCell*)object;
                        break;
                    }
                }
            }
            
            [starCell setRating:[self.profile objectForKey:column]];
            
            pCell = starCell;
        }
        else if ([column isEqualToString:@"bio"])
        {
            ProfileLargeTextCell *bioCell = (ProfileLargeTextCell*)[self.tableView dequeueReusableCellWithIdentifier:@"largeTextCell"];
            
            if (!bioCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileLargeTextCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        bioCell = (ProfileLargeTextCell*)object;
                        break;
                    }
                }
            }
            
            [bioCell setText:[self.profile objectForKey:column]];
            
            pCell = bioCell;
        }
        else
        {
            ProfileInfoCell *infoCell = (ProfileInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:@"infoCell"];
            
            if (!infoCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileInfoCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        infoCell = (ProfileInfoCell*)object;
                        break;
                    }
                }
            }
            
            infoCell.value.text = [self.profile objectForKey:column];
            
            pCell = infoCell;
        }
        
        pCell.name.text = [statSectionLabels objectAtIndex:indexPath.row];
        cell = pCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && [self.account canSendMessages])
    {
        NSString *titleName = nil;
        NSString *titleId = nil;
        
        if (indexPath.row == 0)
        {
            // Activity cell
            
            titleName = [self.profile objectForKey:@"activityTitleName"];
            titleId = [self.profile objectForKey:@"activityTitleId"];
        }
        else
        {
            // Beacon selected
            
            NSDictionary *beacon = [self.beacons objectAtIndex:indexPath.row - 1];
            
            titleName = [beacon objectForKey:@"gameName"];
            titleId = [beacon objectForKey:@"gameUid"];
        }
        
        if (titleName && [XboxLive isPlayable:titleId])
        {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"LetsPlay_f", nil),
                                 titleName];
            
            MessageCompositionController *ctlr = [[MessageCompositionController alloc] initWithRecipient:self.profileScreenName
                                                                                             messageBody:message
                                                                                                 account:self.account];
            
            [self.navigationController pushViewController:ctlr
                                                 animated:YES];
            
            [ctlr release];
        }
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet 
didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (actionSheet.tag == STATUS_FRIEND)
    {
        if (buttonIndex == 0) // Delete friend
        {
            [[TaskController sharedInstance] removeFromFriendsScreenName:self.profileScreenName
                                                                 account:self.account
                                                    managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (actionSheet.tag == STATUS_INVITE_RCVD)
    {
        if (buttonIndex == 0) // Approve request
        {
            [[TaskController sharedInstance] approveFriendRequestScreenName:self.profileScreenName
                                                                    account:self.account
                                                       managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (buttonIndex == 1) // Reject request
        {
            [[TaskController sharedInstance] rejectFriendRequestScreenName:self.profileScreenName
                                                                   account:self.account
                                                      managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (actionSheet.tag == STATUS_INVITE_SENT)
    {
        if (buttonIndex == 0) // Cancel request
        {
            [[TaskController sharedInstance] cancelFriendRequestScreenName:self.profileScreenName
                                                                   account:self.account
                                                      managedObjectContext:managedObjectContext];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Notifications

- (void)imageLoaded:(NSString*)url
{
    // TODO: this causes a full data reload; not a good idea
    [self.tableView reloadData];
}

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    NSString *uid = [notification.userInfo objectForKey:BACHNotificationUid];
    
    if ([account isEqualToAccount:self.account] && 
        [uid isEqualToString:self.profileScreenName])
    {
        [self updateData];
    }
}

#pragma mark - Misc

-(NSString*)valueOrEmptyString:(NSString*)value
{
    if (value)
        return value;
    
    return @"";
}

-(void)removeFriend
{
    NSString *title = NSLocalizedString(@"AreYouSure", nil);
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"RemoveFromFriends_f", nil),
                         self.profileScreenName];
    
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
                              self.profileScreenName, self.account.uuid];
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
        
        self.profileScreenName = [profile valueForKey:@"screenName"];
        self.profile = [NSMutableDictionary dictionary];
        
        if ((value = [profile valueForKey:@"iconUrl"]))
            [self.profile setObject:value forKey:@"iconUrl"];
        if ((value = [profile valueForKey:@"motto"]))
            [self.profile setObject:value forKey:@"motto"];
        
        if ((value = [profile valueForKey:@"activityText"]))
            [self.profile setObject:value forKey:@"activityText"];
        if ((value = [profile valueForKey:@"activityTitleIconUrl"]))
            [self.profile setObject:value forKey:@"activityTitleIconUrl"];
        if ((value = [profile valueForKey:@"activityTitleName"]))
            [self.profile setObject:value forKey:@"activityTitleName"];
        if ((value = [profile valueForKey:@"activityTitleId"]))
            [self.profile setObject:value forKey:@"activityTitleId"];
        
        for (NSString *column in statSectionColumns)
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
    
    entityDescription = [NSEntityDescription entityForName:@"XboxFriendBeacon"
                                    inManagedObjectContext:managedObjectContext];
    
    predicate = [NSPredicate predicateWithFormat:@"friend.uid == %@ AND friend.profile.uuid == %@",
                 self.profileScreenName, self.account.uuid];
    request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
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
    
    [tableView reloadData];
    
    return isStale;
}

#pragma mark - Actions

-(void)refresh:(id)sender
{
    [[TaskController sharedInstance] synchronizeFriendProfileForUid:self.profileScreenName
                                                            account:self.account
                                               managedObjectContext:managedObjectContext];
}

-(void)compareGames:(id)sender
{
    CompareGamesController *ctlr = [[CompareGamesController alloc] initWithScreenName:self.profileScreenName
                                                                              account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)compose:(id)sender
{
    MessageCompositionController *ctlr = [[MessageCompositionController alloc] initWithRecipient:self.profileScreenName
                                                                                 account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
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
    FriendsOfFriendController *ctlr = [[FriendsOfFriendController alloc] initWithScreenName:self.profileScreenName
                                                                                    account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

@end
