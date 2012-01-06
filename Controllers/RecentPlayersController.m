//
//  RecentPlayersController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentPlayersController.h"

#import "TaskController.h"
#import "PlayerCell.h"

#import "ProfileController.h"

@implementation RecentPlayersController

@synthesize players = _players;
@synthesize lastUpdated = _lastUpdated;

-(id)initWithAccount:(XboxLiveAccount*)account;
{
    if (self = [super initWithAccount:account
                              nibName:@"RecentPlayersController"])
    {
        self.lastUpdated = nil;
        
        _players = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    self.players = nil;
    self.lastUpdated = nil;
    
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playersLoaded:)
                                                 name:BACHRecentPlayersLoaded
                                               object:nil];
    
    self.title = NSLocalizedString(@"RecentPlayers", nil);
    
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self refreshUsingRefreshHeaderTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHRecentPlayersLoaded
                                                  object:nil];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [[TaskController sharedInstance] loadRecentPlayersForAccount:self.account];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[TaskController sharedInstance] isLoadingRecentPlayersForAccount:self.account];
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return self.lastUpdated;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    return [self.players count];
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    PlayerCell *playerCell = (PlayerCell*)[self.tableView dequeueReusableCellWithIdentifier:@"playerCell"];
    
    if (indexPath.row < [self.players count])
    {
        if (!playerCell)
        {
            UINib *cellNib = [UINib nibWithNibName:@"PlayerCell" 
                                            bundle:nil];
            
            NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil options:nil];
            
            for (id object in topLevelObjects)
            {
                if ([object isKindOfClass:[UITableViewCell class]])
                {
                    playerCell = (PlayerCell *)object;
                    break;
                }
            }
        }
        
        NSDictionary *player = [self.players objectAtIndex:indexPath.row];
        
        playerCell.screenName.text = [player objectForKey:@"screenName"];
        playerCell.activity.text = [player objectForKey:@"activityText"];
        playerCell.gamerScore.text = [NSString localizedStringWithFormat:[self.numberFormatter stringFromNumber:[player objectForKey:@"gamerScore"]]];
        
        UIImage *gamerpic = [self tableCellImageFromUrl:[player objectForKey:@"iconUrl"]
                                              indexPath:indexPath];
        
        UIImage *boxArt = [self tableCellImageFromUrl:[player objectForKey:@"activityTitleIconUrl"]
                                             cropRect:CGRectMake(0,16,85,85)
                                            indexPath:indexPath];
        
        playerCell.gamerpic.image = gamerpic;
        playerCell.titleIcon.image = boxArt;
    }
    
    return playerCell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *player = [self.players objectAtIndex:indexPath.row];
    
    [ProfileController showProfileWithScreenName:[player objectForKey:@"screenName"]
                                         account:self.account
                            managedObjectContext:managedObjectContext
                            navigationController:self.navigationController];
}

#pragma mark - Notifications

-(void)playersLoaded:(NSNotification *)notification
{
    NSLog(@"Got players loaded notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    
    if ([self.account isEqualToAccount:account])
    {
        [self hideRefreshHeaderTableView];
        
        NSArray *players = [notification.userInfo objectForKey:BACHNotificationData];
        
        [self.players removeAllObjects];
        [self.players addObjectsFromArray:players];
        
        self.lastUpdated = [NSDate date];
        [self.tableView reloadData];
        
        [_refreshHeaderView refreshLastUpdatedDate];
    }
}

@end
