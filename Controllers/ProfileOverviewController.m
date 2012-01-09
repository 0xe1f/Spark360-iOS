//
//  ProfileOverviewController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileOverviewController.h"

#import "GameListController.h"
#import "MessageListController.h"
#import "FriendListController.h"
#import "XboxLiveStatusController.h"

#import "AKImageCache.h"
#import "TaskController.h"

#import "ProfileCell.h"
#import "ProfileInfoCell.h"
#import "ProfileGamertagCell.h"
#import "ProfileGamerscoreCell.h"
#import "ProfileRatingCell.h"
#import "ProfileLargeTextCell.h"
#import "ProfileOptionsCell.h"

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

-(id)initWithAccount:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"ProfileOverviewController"])
    {
        self.profile = nil;
        
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
    
    [statSectionColumns release];
    statSectionColumns = nil;
    [statSectionLabels release];
    statSectionLabels = nil;
    
    [super dealloc];
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
        return [statSectionColumns count];
    else if (section == 2)
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
    else if (indexPath.section == 2)
    {
        return 111;
    }
    
    return 42;
}

- (void)tableView:(UITableView *)tableView 
  willDisplayCell:(UITableViewCell *)cell 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 2)
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
    else if (indexPath.section == 2)
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MyProfile", nil);
    
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
    
    [self updateData];
    
    [self refreshProfile:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateData];
}

#pragma mark - Notifications

-(void)receivedImage:(NSString *)url 
           parameter:(id)parameter
{
    [self.tableView reloadData];
}

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
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
    
    [tableView reloadData];
}

@end
