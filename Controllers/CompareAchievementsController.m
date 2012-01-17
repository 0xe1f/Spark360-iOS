//
//  CompareAchievementsController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CompareAchievementsController.h"

#import "TaskController.h"
#import "CompareAchievementCell.h"

#import "GameOverviewController.h"

@implementation CompareAchievementsController

@synthesize achievements = _achievements;
@synthesize screenName = _screenName;
@synthesize gameUid = _gameUid;
@synthesize lastUpdated = _lastUpdated;
@synthesize gameTitle = _gameTitle;
@synthesize gameDetailUrl = _gameDetailUrl;

@synthesize myIconUrl = _myIconUrl;
@synthesize yourIconUrl = _yourIconUrl;

-(id)initWithGameUid:(NSString*)gameUid
          screenName:(NSString*)screenName
             account:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"CompareAchievementsController"])
    {
        self.screenName = screenName;
        self.gameUid = gameUid;
        self.lastUpdated = nil;
        self.gameTitle = nil;
        self.gameDetailUrl = nil;
        
        _achievements = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    self.achievements = nil;
    self.screenName = nil;
    self.gameUid = nil;
    self.lastUpdated = nil;
    self.gameDetailUrl = nil;
    self.gameTitle = nil;
    
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(achievementsCompared:)
                                                 name:BACHAchievementsCompared
                                               object:nil];
    
    self.title = NSLocalizedString(@"CompareAchievements", nil);
    
    [self synchronizeWithRemote];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHAchievementsCompared
                                                  object:nil];
}

#pragma mark - GenericTableViewController

- (NSDate*)lastSynchronized
{
	return self.lastUpdated;
}

- (void)mustSynchronizeWithRemote
{
    [super mustSynchronizeWithRemote];
    
    [[TaskController sharedInstance] compareAchievementsForGameUid:self.gameUid
                                                        screenName:self.screenName
                                                           account:self.account];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[TaskController sharedInstance] isComparingAchievementsForGameUid:self.gameUid
                                                                   screenName:self.screenName
                                                                      account:self.account];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    return [self.achievements count];
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    CompareAchievementCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.row < [self.achievements count])
    {
        if (!cell)
        {
            [[NSBundle mainBundle] loadNibNamed:@"CompareAchievementCell"
                                          owner:self
                                        options:nil];
            
            cell = (CompareAchievementCell*)self.tableViewCell;
        }
        
        NSDictionary *achievement = [self.achievements objectAtIndex:indexPath.row];
        
        cell.title.text = [achievement objectForKey:@"title"];
        cell.description.text = [achievement objectForKey:@"achDescription"];
        cell.gamerScore.text = [[achievement objectForKey:@"gamerScore"] stringValue];

        NSString *unlockedText;
        
        if ([[achievement objectForKey:@"myIsLocked"] boolValue])
        {
            unlockedText = NSLocalizedString(@"AchieveLocked", nil);
        }
        else
        {
            NSDate *acquired = [achievement objectForKey:@"myAcquired"];
            if ([acquired isEqualToDate:[NSDate distantPast]])
            {
                unlockedText = NSLocalizedString(@"AchieveUnlockedOffline", nil);
            }
            else
            {
                unlockedText = [NSString localizedStringWithFormat:NSLocalizedString(@"AchieveUnlockedBrief_f", nil), 
                                [self.dateFormatter stringFromDate:acquired]];
            }
        }
        
        cell.myAcquired.text = unlockedText;
        
        if ([[achievement objectForKey:@"yourIsLocked"] boolValue])
        {
            unlockedText = NSLocalizedString(@"AchieveLocked", nil);
        }
        else
        {
            NSDate *acquired = [achievement objectForKey:@"yourAcquired"];
            if ([acquired isEqualToDate:[NSDate distantPast]])
            {
                unlockedText = NSLocalizedString(@"AchieveUnlockedOffline", nil);
            }
            else
            {
                unlockedText = [NSString localizedStringWithFormat:NSLocalizedString(@"AchieveUnlockedBrief_f", nil), 
                                [self.dateFormatter stringFromDate:acquired]];
            }
        }
        
        cell.yourAcquired.text = unlockedText;
        
        UIImage *icon = [self tableCellImageFromUrl:[achievement objectForKey:@"iconUrl"]
                                          indexPath:indexPath];
        
        if (icon)
            cell.icon.image = icon;
        
        UIImage *myGamerpic = [self tableCellImageFromUrl:self.myIconUrl
                                                indexPath:indexPath];
        
        if (myGamerpic)
            cell.myGamerpic.image = myGamerpic; 
        
        UIImage *yourGamerpic = [self tableCellImageFromUrl:self.yourIconUrl
                                                  indexPath:indexPath];
        
        if (yourGamerpic)
            cell.yourGamerpic.image = yourGamerpic;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *achievement = [self.achievements objectAtIndex:indexPath.row];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[achievement objectForKey:@"title"] 
                                                        message:[achievement objectForKey:@"achDescription"]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK",nil) 
                                              otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
}

#pragma mark - Notifications

-(void)achievementsCompared:(NSNotification *)notification
{
    BACHLog(@"Got achievements compared notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    NSString *screenName = [notification.userInfo objectForKey:BACHNotificationScreenName];
    NSString *gameUid = [notification.userInfo objectForKey:BACHNotificationUid];
    
    if ([self.account isEqualToAccount:account] && 
        [self.screenName isEqualToString:screenName] &&
        [self.gameUid isEqualToString:gameUid])
    {
        [self hideRefreshHeaderTableView];
        
        NSDictionary *payload = [notification.userInfo objectForKey:BACHNotificationData];
        NSArray *achievements = [payload objectForKey:@"achievements"];
        
        self.myIconUrl = [payload objectForKey:@"meIconUrl"];
        self.yourIconUrl = [payload objectForKey:@"youIconUrl"];
        
        self.gameTitle = [payload objectForKey:@"title"];
        self.gameDetailUrl = [payload objectForKey:@"detailUrl"];
        
        [self.achievements removeAllObjects];
        [self.achievements addObjectsFromArray:achievements];
        
        self.lastUpdated = [NSDate date];
        [self.tableView reloadData];
        
        [self updateSynchronizationDate];
    }
}

#pragma mark - Actions

-(IBAction)refresh:(id)sender
{
    [self synchronizeWithRemote];
}

-(IBAction)showDetails:(id)sender
{
    if (self.gameDetailUrl)
    {
        GameOverviewController *ctlr =  [[GameOverviewController alloc] initWithTitle:self.gameTitle
                                                                            detailUrl:self.gameDetailUrl
                                                                              account:self.account];
        
        [self.navigationController pushViewController:ctlr animated:YES];
        [ctlr release];
    }
}

@end
