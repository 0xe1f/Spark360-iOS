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

#import "ImageCache.h"
#import "ProfileGamertagCell.h"

@interface ProfileOverviewController (Private)

-(void)updateData;

@end

@implementation ProfileOverviewController

@synthesize tableView;

@synthesize screenName = _screenName;
@synthesize gamerpicUrl = _gamerpicUrl;

-(id)initWithAccount:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"ProfileOverview"])
    {
    }
    
    return self;
}

-(void)dealloc
{
    self.screenName = nil;
    self.gamerpicUrl = nil;
    
    [super dealloc];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 52;
    }
    
    return 42;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
    {
        return 1;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView 
  willDisplayCell:(UITableViewCell *)cell 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
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
            gtCell.gamerpic.image = [[ImageCache sharedInstance] getCachedFile:self.gamerpicUrl
                                                                  notifyObject:self
                                                                notifySelector:@selector(imageLoaded:)];
            
            cell = gtCell;
        }
    }
    /*
    CompareGameCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.row < [self.games count])
    {
        if (!cell)
        {
            [[NSBundle mainBundle] loadNibNamed:@"CompareGameCell"
                                          owner:self
                                        options:nil];
            
            cell = (CompareGameCell*)self.tableViewCell;
        }
        
        NSDictionary *game = [self.games objectAtIndex:indexPath.row];
        
        // Title
        cell.title.text = [game objectForKey:@"title"];
        
        // Achievement stats
        cell.myAchievements.text = [NSString localizedStringWithFormat:NSLocalizedString(@"ComparedAchievementStats", nil),
                                    [game objectForKey:@"myAchievesUnlocked"],
                                    [game objectForKey:@"achievesTotal"]];
        cell.yourAchievements.text = [NSString localizedStringWithFormat:NSLocalizedString(@"ComparedAchievementStats", nil),
                                      [game objectForKey:@"yourAchievesUnlocked"],
                                      [game objectForKey:@"achievesTotal"]];
        
        // Gamescore stats
        cell.myGamerscore.text = [NSString localizedStringWithFormat:NSLocalizedString(@"GameScoreStats", nil),
                                  [self.numberFormatter stringFromNumber:[game objectForKey:@"myGamerScoreEarned"]],
                                  [self.numberFormatter stringFromNumber:[game objectForKey:@"gamerScoreTotal"]]];
        cell.yourGamerscore.text = [NSString localizedStringWithFormat:NSLocalizedString(@"GameScoreStats", nil),
                                    [self.numberFormatter stringFromNumber:[game objectForKey:@"yourGamerScoreEarned"]],
                                    [self.numberFormatter stringFromNumber:[game objectForKey:@"gamerScoreTotal"]]];
        
        // Boxart
        UIImage *boxArt = [[ImageCache sharedInstance] getCachedFile:[game objectForKey:@"boxArtUrl"]
                                                            cropRect:CGRectMake(0, 16, 85, 85)
                                                        notifyObject:self
                                                      notifySelector:@selector(imageLoaded:)];
        
        cell.boxArt.image = boxArt;
    }
    
     */
    return cell;
}

#pragma mark - Actions

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

- (void)viewLiveStatus:(id)sender
{
    XboxLiveStatusController *ctlr = [[XboxLiveStatusController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MyProfile", nil);
    
    [self updateData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Notifications

- (void)imageLoaded:(NSString*)url
{
    [self.tableView reloadData];
}

#pragma mark - Misc

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
    
    self.screenName = self.account.screenName;
    self.gamerpicUrl = nil;
    
    if (profile)
    {
        self.gamerpicUrl = [profile valueForKey:@"iconUrl"];
        
        /*
        self.friendScreenName = [friend valueForKey:@"screenName"];
        self.isStale = [self.account isDataStale:[friend valueForKey:@"profileLastUpdated"]];
        
        if ([[friend valueForKey:@"isIncoming"] boolValue])
        {
            self.friendStatus = STATUS_INVITE_RCVD;
        }
        else if ([[friend valueForKey:@"isOutgoing"] boolValue])
        {
            self.friendStatus = STATUS_INVITE_SENT;
        }
        else
        {
            self.friendStatus = STATUS_FRIEND;
        }
        
        [self.properties removeAllObjects];
        
        NSArray *loadKeys = [NSArray arrayWithObjects:
                             @"screenName",
                             @"avatarUrl",
                             @"activityText",
                             @"activityTitleIconUrl",
                             @"iconUrl",
                             @"statusCode",
                             @"gamerScore",
                             @"rep",
                             @"name",
                             @"location",
                             @"motto",
                             @"bio",
                             nil];
        
        for (NSString *key in loadKeys) 
        {
            id value = [friend valueForKey:key];
            if (value)
                [self.properties setObject:value forKey:key];
        }
        */
    }
    
    [tableView reloadData];
}

@end
