//
//  RootViewController.m
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AchievementListController.h"

#import "TaskController.h"
#import "XboxLiveParser.h"
#import "GTMNSString+URLArguments.h"

#import "WebController.h"
#import "GameOverviewController.h"

#define ALERTVIEW_ACH_DETAILS   100
#define ALERTVIEW_SET_BEACON    101

#define ALERTVIEW_ACH_HELP_BUTTON 1

#define ACTIONSHEET_SET_BEACON   1
#define ACTIONSHEET_CLEAR_BEACON 2

@interface AchievementListController (Private)

-(void)updateGameStats;
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation AchievementListController

@synthesize fetchedResultsController = __fetchedResultsController;

@synthesize gameTitleLabel;
@synthesize gameLastPlayedLabel;
@synthesize gameAchievesLabel;
@synthesize gameGamerScoreLabel;
@synthesize gameBoxArtIcon;
@synthesize beaconButton;

@synthesize gameUid;
@synthesize gameDetailUrl;
@synthesize gameTitle;
@synthesize isGameDirty;
@synthesize isBeaconSet;
@synthesize gameLastUpdated;

-(void)beaconToggled:(NSNotification *)notification
{
    BACHLog(@"Got beacon toggled notification");
    
    if ([self.account isEqualToAccount:[notification.userInfo objectForKey:BACHNotificationAccount]])
    {
        [self updateGameStats];
    }
}

-(void)syncCompleted:(NSNotification *)notification
{
    BACHLog(@"Got sync completed notification");
    
    if ([self.account isEqualToAccount:[notification.userInfo objectForKey:BACHNotificationAccount]])
    {
        [self updateGameStats];
        [self hideRefreshHeaderTableView];
        
        [self.tableView reloadData];
    }
}

-(id)initWithAccount:(XboxLiveAccount*)account
         gameTitleId:(NSString*)gameTitleId
{
    if (self = [super initWithAccount:account
                              nibName:@"AchievementListController"])
    {
        self.gameUid = gameTitleId;
    }
    
    return self;
}

-(void)dealloc
{
    [__fetchedResultsController release];
    
    self.gameTitle = nil;
    self.gameUid = nil;
    self.gameLastUpdated = nil;
    self.gameDetailUrl = nil;
    
    [super dealloc];
}

-(void)updateGameStats
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxGame"
                                                         inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile.uuid == %@", 
                              self.gameUid, self.account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:request 
                                                         error:nil];
    
    NSManagedObject *game = [array lastObject];
    
    [request release];
    
    if (game)
    {
        self.gameTitle = [game valueForKey:@"title"];
        self.gameDetailUrl = [game valueForKey:@"gameUrl"];
        self.isGameDirty = [[game valueForKey:@"achievesDirty"] boolValue];
        self.gameLastUpdated = [game valueForKey:@"lastUpdated"];
        self.isBeaconSet = [[game valueForKey:@"isBeaconSet"] boolValue];
        
        self.gameTitleLabel.text = self.gameTitle;
        self.gameLastPlayedLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"GameLastPlayed", nil), 
                                         [self.dateFormatter stringFromDate:[game valueForKey:@"lastPlayed"]]];
        self.gameAchievesLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"GameAchievementStats", nil), 
                                       [game valueForKey:@"achievesUnlocked"],
                                       [game valueForKey:@"achievesTotal"]];
        self.gameGamerScoreLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"GameScoreStats", nil), 
                                         [self.numberFormatter stringFromNumber:[game valueForKey:@"gamerScoreEarned"]],
                                         [self.numberFormatter stringFromNumber:[game valueForKey:@"gamerScoreTotal"]]];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHAchievementsSynced 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(beaconToggled:)
                                                 name:BACHBeaconToggled 
                                               object:nil];
    
    [self updateGameStats];
    
    self.title = [NSString localizedStringWithFormat:NSLocalizedString(@"Achievements_f", nil),
                  gameTitle];
    
    if (self.isGameDirty)
        [self synchronizeWithRemote];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateGameStats];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHAchievementsSynced
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHBeaconToggled
                                                  object:nil];
}

-(void)alertView:(UIAlertView *)alertView 
clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (alertView.tag == ALERTVIEW_ACH_DETAILS)
    {
        if (buttonIndex == ALERTVIEW_ACH_HELP_BUTTON)
        {
            // Achievement help
            
            NSString *searchTerm = [NSString stringWithFormat:NSLocalizedString(@"AchievementHelpTerm_f", nil),
                                    self.gameTitle, alertView.title];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:NSLocalizedString(@"AchievementHelpUrl_f", nil),
                                               [searchTerm gtm_stringByEscapingForURLArgument]]];
            
            WebController *ctlr = [[WebController alloc] initWithUrl:url
                                                           pageTitle:NSLocalizedString(@"AchievementHelp", nil)
                                                             account:self.account];
            
            [self.navigationController pushViewController:ctlr animated:YES];
            [ctlr release];
        }
    }
    else if (alertView.tag == ALERTVIEW_SET_BEACON)
    {
        if (buttonIndex == INPUT_ALERTVIEW_OK_BUTTON)
        {
            NSString *message = [self inputDialogText:alertView];
            
            if (message && [message length] > 0)
            {
                [[TaskController sharedInstance] setBeaconForGameUid:self.gameUid
                                                             account:self.account
                                                             message:message
                                                managedObjectContext:managedObjectContext];
            }
        }
    }
}

#pragma mark - GenericTableViewController

- (NSDate*)lastSynchronized
{
    return self.gameLastUpdated;
}

-(void)mustSynchronizeWithRemote
{
    [super mustSynchronizeWithRemote];
    
    [[TaskController sharedInstance] synchronizeAchievementsForGame:self.gameUid
                                                            account:self.account
                                               managedObjectContext:managedObjectContext];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return [[TaskController sharedInstance] isSynchronizingAchievementsForGame:self.gameUid
                                                                       account:self.account];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"AchievementCell"
                                      owner:self
                                    options:nil];
        cell = self.tableViewCell;
    }
    
    [self configureCell:cell 
            atIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *achievement = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[achievement valueForKey:@"title"] 
                                                        message:[achievement valueForKey:@"achDescription"]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Close",nil) 
                                              otherButtonTitles:NSLocalizedString(@"OnlineHelp",nil),
                                                                 nil];
    alertView.tag = ALERTVIEW_ACH_DETAILS;
    
    [alertView show];
    [alertView release];
}

-(void)configureCell:(UITableViewCell *)cell 
          atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Title
    
    UILabel *label = (UILabel*)[cell viewWithTag:2];
    [label setText:[managedObject valueForKey:@"title"]];
    
    // Description
    
    label = (UILabel*)[cell viewWithTag:6];
    [label setText:[managedObject valueForKey:@"achDescription"]];
    
    // Acquired
    
    NSString *unlockedText;
    if ([[managedObject valueForKey:@"isLocked"] boolValue])
    {
        unlockedText = NSLocalizedString(@"AchieveLocked", nil);
    }
    else
    {
        NSDate *acquired = [managedObject valueForKey:@"acquired"];
        if ([acquired isEqualToDate:[NSDate distantPast]])
        {
            unlockedText = NSLocalizedString(@"AchieveUnlockedOffline", nil);
        }
        else
        {
            unlockedText = [NSString localizedStringWithFormat:NSLocalizedString(@"AchieveUnlocked_f", nil), 
                            [self.dateFormatter stringFromDate:acquired]];
        }
    }
    
    label = (UILabel*)[cell viewWithTag:3];
    [label setText:unlockedText];
    
    // Gamescore
    
    label = (UILabel*)[cell viewWithTag:5];
    [label setText:[[managedObject valueForKey:@"gamerScore"] stringValue]];
    
    // Icon

    UIImageView *view = (UIImageView*)[cell viewWithTag:7];
    UIImage *icon = [self tableCellImageFromUrl:[managedObject valueForKey:@"iconUrl"]
                                      indexPath:indexPath];
    
    if (icon)
        [view setImage:icon];
}

#pragma mark - Fetched results controller

-(NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game.uid == %@ AND game.profile.uuid == %@", 
                              gameUid, self.account.uuid];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XboxAchievement" 
                                              inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" 
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:nil]; // AK: cacheName was 'Root'
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
	    BACHLog(@"Unresolved error %@, %@", error, [error userInfo]);
    
    return __fetchedResultsController;
}    

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet 
didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (actionSheet.tag == ACTIONSHEET_CLEAR_BEACON)
    {
        if (buttonIndex == 0) // Unset beacon
        {
            [[TaskController sharedInstance] clearBeaconForGameUid:self.gameUid
                                                           account:self.account
                                              managedObjectContext:managedObjectContext];
        }
    }
    else if (actionSheet.tag == ACTIONSHEET_SET_BEACON)
    {
        if (buttonIndex == 0) // Set beacon - prompt for message
        {
            UIAlertView *inputDialog = [self inputDialogWithTitle:NSLocalizedString(@"SetBeacon", nil)
                                                          message:NSLocalizedString(@"BeaconMessage", nil)
                                                             text:NSLocalizedString(@"IWantToPlayThisGameWithFriends", nil)];
            
            inputDialog.tag = ALERTVIEW_SET_BEACON;
            [inputDialog show];
        }
    }
}

#pragma mark - Actions

-(void)refresh:(id)sender
{
    [self synchronizeWithRemote];
}

-(void)showDetails:(id)sender
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

-(void)toggleBeacon:(id)sender
{
    UIActionSheet *actionSheet = nil;
    if (!self.isBeaconSet)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:
                       NSLocalizedString(@"SetBeacon", nil), 
                       nil];
        
        actionSheet.tag = ACTIONSHEET_SET_BEACON;
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self 
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:
                       NSLocalizedString(@"ClearBeacon", nil), 
                       nil];
        
        actionSheet.tag = ACTIONSHEET_CLEAR_BEACON;
    }
    
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

@end
