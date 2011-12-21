//
//  CompareGamesController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CompareGamesController.h"

#import "TaskController.h"
#import "ImageCache.h"
#import "CompareGameCell.h"

@implementation CompareGamesController

@synthesize games = _games;
@synthesize screenName = _screenName;

-(id)initWithScreenName:(NSString *)screenName 
                account:(XboxLiveAccount *)account
{
    if (self = [super initWithAccount:account
                              nibName:@"CompareGamesController"])
    {
        self.screenName = screenName;
        
        _games = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    self.screenName = nil;
    self.games = nil;
    
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gamesCompared:)
                                                 name:BACHGamesCompared
                                               object:nil];
    
    self.title = NSLocalizedString(@"CompareGames", nil);
    
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self refreshUsingRefreshHeaderTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHGamesCompared
                                                  object:nil];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [[TaskController sharedInstance] compareGamesWithScreenName:self.screenName
                                                        account:self.account];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[TaskController sharedInstance] isComparingGamesWithScreenName:self.screenName
                                                                   account:self.account];
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate distantPast];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    return [self.games count];
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
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
        cell.myAchievements.text = [NSString localizedStringWithFormat:NSLocalizedString(@"GameAchievementStats", nil),
                                    [game objectForKey:@"myAchievesUnlocked"],
                                    [game objectForKey:@"achievesTotal"]];
        cell.yourAchievements.text = [NSString localizedStringWithFormat:NSLocalizedString(@"GameAchievementStats", nil),
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
    
    return cell;
    /*
    CompareGameCell *cell = (CompareGameCell*)[self.tableView dequeueReusableCellWithIdentifier:@"compareGameCell"];
    
    if (!cell)
    {
        UINib *cellNib = [UINib nibWithNibName:@"CompareGameCell"
                                        bundle:nil];
        
        NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil
                                                         options:nil];
        
        for (id object in topLevelObjects)
        {
            if ([object isKindOfClass:[UITableViewCell class]])
            {
                cell = (CompareGameCell*)cell
            }
        }
    }
     */
    /*
    ProfileStatusCell *statusCell = (ProfileStatusCell*)[self.tableView dequeueReusableCellWithIdentifier:@"statusCell"];
    
    if (!statusCell)
    {
        UINib *cellNib = [UINib nibWithNibName:@"ProfileStatusCell" 
                                        bundle:nil];
        
        NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil options:nil];
        
        for (id object in topLevelObjects)
        {
            if ([object isKindOfClass:[UITableViewCell class]])
            {
                statusCell = (ProfileStatusCell *)object;
                break;
            }
        }
    }
    
    int statusCode = [[self.properties objectForKey:@"statusCode"] intValue];
    
    statusCell.status.text = [XboxLive descriptionFromFriendStatus:statusCode];
    statusCell.activity.text = [self.properties objectForKey:@"activityText"];
    
    UIImage *boxArt = [[CFImageCache sharedInstance]
                       getCachedFile:[self.properties objectForKey:@"activityTitleIconUrl"]
                       notifyObject:self
                       notifySelector:@selector(imageLoaded:)];
    
    [statusCell.titleIcon setImage:boxArt];
    
    UIImage *gamerpic = [[CFImageCache sharedInstance]
                         getCachedFile:[self.properties objectForKey:@"iconUrl"]
                         notifyObject:self
                         notifySelector:@selector(imageLoaded:)];
    
    [statusCell.gamerpic setImage:gamerpic];
    
    return statusCell;
     */
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSManagedObject *obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    /* TODO
    FriendProfileController *ctlr = [[FriendProfileController alloc] initWithFriendUid:[friend valueForKey:@"uid"]
                                                                               account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
     */
}

#pragma mark - Notifications

- (void)imageLoaded:(NSString*)url
{
    // TODO: this causes a full data reload; not a good idea
    [self.tableView reloadData];
}

-(void)gamesCompared:(NSNotification *)notification
{
    NSLog(@"Got games compared notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    NSString *screenName = [notification.userInfo objectForKey:BACHNotificationUid];
    
    if ([self.account isEqualToAccount:account] && [self.screenName isEqualToString:screenName])
    {
        [self hideRefreshHeaderTableView];
        
        NSDictionary *payload = [notification.userInfo objectForKey:BACHNotificationData];
        NSArray *games = [payload objectForKey:@"games"];
        
        [self.games removeAllObjects];
        [self.games addObjectsFromArray:games];
        
        [self.tableView reloadData];
    }
}

@end
