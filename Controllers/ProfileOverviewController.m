/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
 *
 * Copyright (C) 2011-2014 Akop Karapetyan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

#import "ProfileOverviewController.h"

#import "GameListController.h"
#import "MessageListController.h"
#import "FriendListController.h"
#import "XboxLiveStatusController.h"
#import "AchievementListController.h"
#import "AboutAppController.h"

#import "AKImageCache.h"
#import "TaskController.h"

#import "ProfileCell.h"
#import "ProfileInfoCell.h"
#import "ProfileGamertagCell.h"
#import "ProfileGamerscoreCell.h"
#import "ProfileRatingCell.h"
#import "ProfileLargeTextCell.h"
#import "ProfileOptionsCell.h"
#import "BeaconInfoCell.h"

@interface ProfileOverviewController (Private)

-(void)updateData;
-(void)refreshProfile:(BOOL)forceRefresh;

@end

@implementation ProfileOverviewController
{
    NSArray *statSectionColumns;
    NSArray *statSectionLabels;
}

@synthesize tableView;
@synthesize optionsCell;

@synthesize messagesUnread = _messagesUnread;
@synthesize friendsOnline = _friendsOnline;
@synthesize profile = _profile;
@synthesize beacons = _beacons;
@synthesize popover = _popover;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.profile = nil;
        self.beacons = [NSMutableArray arrayWithCapacity:5];
        
        statSectionColumns = [[NSArray arrayWithObjects:
                               @"gamerScore",
                               @"rep",
                               @"name",
                               @"location",
                               @"pointsBalance",
                               @"accountType",
                               @"bio",
                               nil] retain];
        
        statSectionLabels = [[NSArray arrayWithObjects:
                              NSLocalizedString(@"InfoGamerscore", nil),
                              NSLocalizedString(@"InfoRep", nil),
                              NSLocalizedString(@"InfoName", nil),
                              NSLocalizedString(@"InfoLocation", nil), 
                              NSLocalizedString(@"InfoMsp", nil), 
                              NSLocalizedString(@"InfoMemberType", nil), 
                              NSLocalizedString(@"InfoBio", nil), 
                              nil] retain];
    }
    
    return self;
}

-(id)initWithAccount:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"ProfileOverviewController"])
    {
        self.profile = nil;
        self.beacons = [NSMutableArray arrayWithCapacity:5];
        
        statSectionColumns = [[NSArray arrayWithObjects:
                               @"gamerScore",
                               @"rep",
                               @"name",
                               @"location",
                               @"pointsBalance",
                               @"accountType",
                               @"bio",
                               nil] retain];
        
        statSectionLabels = [[NSArray arrayWithObjects:
                              NSLocalizedString(@"InfoGamerscore", nil),
                              NSLocalizedString(@"InfoRep", nil),
                              NSLocalizedString(@"InfoName", nil),
                              NSLocalizedString(@"InfoLocation", nil), 
                              NSLocalizedString(@"InfoMsp", nil), 
                              NSLocalizedString(@"InfoMemberType", nil), 
                              NSLocalizedString(@"InfoBio", nil), 
                              nil] retain];
    }
    
    return self;
}

-(void)dealloc
{
    self.profile = nil;
    self.beacons = nil;
    self.popover = nil;
    
    [statSectionColumns release];
    statSectionColumns = nil;
    [statSectionLabels release];
    statSectionLabels = nil;
    
    [super dealloc];
}

#pragma mark - AccountSelectionDelegate

-(void)accountDidChange:(XboxLiveAccount *)account
{
    self.account = account;
    
    [self updateData];
    [self refreshProfile:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return [self.beacons count];
    else if (section == 2)
        return [statSectionColumns count];
    else if (section == 3)
        return 1;
    
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
    else if (indexPath.section == 3)
    {
        return 111;
    }
    
    return 42;
}

- (void)tableView:(UITableView *)tableView 
  willDisplayCell:(UITableViewCell *)cell 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 3)
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
            
            gtCell.screenName.text = self.account.screenName;
            gtCell.gamerpic.image = [self imageFromUrl:[self.profile objectForKey:@"iconUrl"]
                                             parameter:nil];
            
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
        
        NSDictionary *beacon = [self.beacons objectAtIndex:indexPath.row];
        
        biCell.titleName.text = [beacon objectForKey:@"title"];
        biCell.message.text = [beacon objectForKey:@"beaconText"];
        biCell.titleIcon.image = [self imageFromUrl:[beacon objectForKey:@"boxArtUrl"]
                                           cropRect:CGRectMake(0, 16, 85, 85)
                                          parameter:nil];
        
        cell = biCell;
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
        else if ([column isEqualToString:@"pointsBalance"])
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
            
            [gsCell setMsp:[self.profile objectForKey:column]];
            
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
    else if (indexPath.section == 3)
    {
        ProfileOptionsCell *optCell = (ProfileOptionsCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        if (!optCell)
        {
            [[NSBundle mainBundle] loadNibNamed:@"ProfileOptionsCell"
                                          owner:self
                                        options:nil];
            
            optCell = (ProfileOptionsCell*)self.optionsCell;
        }
        
        if (self.friendsOnline > 0)
        {
            [optCell.friends setTitle:[NSString stringWithFormat:NSLocalizedString(@"FriendsOnline_f", nil),
                                       self.friendsOnline]
                             forState:UIControlStateNormal];
        }
        else
        {
            [optCell.friends setTitle:NSLocalizedString(@"FriendsNoneOnline", nil)
                             forState:UIControlStateNormal];
        }
        
        if (self.messagesUnread > 0)
        {
            [optCell.messages setTitle:[NSString stringWithFormat:NSLocalizedString(@"MessagesUnread_f", nil),
                                        self.messagesUnread]
                              forState:UIControlStateNormal];
        }
        else
        {
            [optCell.messages setTitle:NSLocalizedString(@"MessagesNoneUnread", nil)
                              forState:UIControlStateNormal];
        }
        
        optCell.games.titleLabel.text = NSLocalizedString(@"Games", nil);
        
        cell = optCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        // Beacon selected
        
        NSDictionary *beacon = [self.beacons objectAtIndex:indexPath.row];
        NSString *uid = [beacon objectForKey:@"uid"];
        
        AchievementListController *ctlr = [[AchievementListController alloc] initWithAccount:self.account
                                                                                 gameTitleId:uid];
        
        [self.navigationController pushViewController:ctlr
                                             animated:YES];
        
        [ctlr release];
    }
}

#pragma mark - Actions

-(void)refresh:(id)sender
{
    [self refreshProfile:YES];
}

- (void)viewLiveStatus:(id)sender
{
    XboxLiveStatusController *ctlr = [[XboxLiveStatusController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)viewGames:(id)sender
{
    GameListController *ctlr = [[GameListController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)viewMessages:(id)sender
{
    MessageListController *ctlr = [[MessageListController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)viewFriends:(id)sender
{
    FriendListController *ctlr = [[FriendListController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)about:(id)sender
{
    AboutAppController *ctlr = [[AboutAppController alloc] initAbout];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHMessagesSynced
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHMessagesChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHFriendsSynced
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHFriendsChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHBeaconsSynced
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHBeaconToggled
                                               object:nil];
    
	self.tableView.backgroundColor = [UIColor clearColor];
    
    [self updateData];
    [self refreshProfile:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.popover = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHMessagesSynced
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHMessagesChanged
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHFriendsSynced
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHFriendsChanged
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHBeaconsSynced
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHBeaconToggled
                                                  object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateData];
}

#pragma mark UISplitViewControllerDelegate

- (void)splitViewController: (UISplitViewController*)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem*)barButtonItem 
       forPopoverController: (UIPopoverController*)pc 
{
    barButtonItem.title = NSLocalizedString(@"Accounts", nil);
    
    UINavigationItem *navItem = [self navigationItem];
    [navItem setLeftBarButtonItem:barButtonItem animated:YES];
    
    self.popover = pc;
}

- (void)splitViewController: (UISplitViewController*)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
    UINavigationItem *navItem = [self navigationItem];
    [navItem setLeftBarButtonItem:nil animated:YES];
    
    self.popover = nil;
}

#pragma mark - Notifications

-(void)receivedImage:(NSString *)url 
           parameter:(id)parameter
{
    [self.tableView reloadData];
}

-(void)syncCompleted:(NSNotification *)notification
{
    BACHLog(@"Got sync completed notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    
    if ([account isEqualToAccount:self.account])
    {
        [self updateData];
    }
}

#pragma mark - Misc

-(void)refreshProfile:(BOOL)forceRefresh
{
    if (forceRefresh || [self.account isProfileStale])
    {
        [[TaskController sharedInstance] synchronizeProfileForAccount:self.account
                                                 managedObjectContext:managedObjectContext];
    }
    
    if (forceRefresh || [self.account areFriendsStale])
    {
        [[TaskController sharedInstance] synchronizeFriendsForAccount:self.account
                                                 managedObjectContext:managedObjectContext];
    }
    
    if (forceRefresh || [self.account areMessagesStale])
    {
        [[TaskController sharedInstance] synchronizeMessagesForAccount:self.account
                                                  managedObjectContext:managedObjectContext];
    }
}

-(void)updateData
{
    self.title = [NSString stringWithFormat:NSLocalizedString(@"MyProfile_f", nil),
                  self.account.screenName];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxProfile"
                                                         inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", 
                              self.account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:request 
                                                         error:nil];
    
    NSManagedObject *profile = [array lastObject];
    
    [request release];
    
    if (profile)
    {
        self.profile = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [profile valueForKey:@"iconUrl"], @"iconUrl",
                        [profile valueForKey:@"motto"], @"motto",
                        nil];
        
        for (NSString *column in statSectionColumns)
        {
            id value;
            if ((value = [profile valueForKey:column]))
                [self.profile setObject:value forKey:column];
        }
    }
    
    // Online friends
    
    entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                    inManagedObjectContext:managedObjectContext];
    
    predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@ AND isOnline == TRUE", 
                 self.account.uuid];
    
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    array = [managedObjectContext executeFetchRequest:request error:nil];
    
    self.friendsOnline = [array count];
    
    [request release];
    
    // Unread messages
    
    entityDescription = [NSEntityDescription entityForName:@"XboxMessage"
                                    inManagedObjectContext:managedObjectContext];
    
    predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@ AND isRead == FALSE", 
                 self.account.uuid];
    
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    array = [managedObjectContext executeFetchRequest:request error:nil];
    
    self.messagesUnread = [array count];
    
    [request release];
    
    // Beacons
    
    entityDescription = [NSEntityDescription entityForName:@"XboxGame"
                                    inManagedObjectContext:managedObjectContext];
    
    predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@ AND isBeaconSet == TRUE", 
                 self.account.uuid];
    
    request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    array = [managedObjectContext executeFetchRequest:request error:nil];
    
    [self.beacons removeAllObjects];
    for (NSManagedObject *game in array)
    {
        [self.beacons addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [game valueForKey:@"title"], @"title", 
                                 [game valueForKey:@"boxArtUrl"], @"boxArtUrl", 
                                 [game valueForKey:@"beaconText"], @"beaconText", 
                                 [game valueForKey:@"uid"], @"uid", 
                                 nil]];
    }
    
    [request release];
    
    [tableView reloadData];
}

@end
