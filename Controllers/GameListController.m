//
//  RootViewController.m
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameListController.h"

#import "TaskController.h"
#import "ImageCache.h"
#import "XboxLiveParser.h"

#import "AchievementListController.h"

@interface GameListController (Private)

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation GameListController

@synthesize fetchedResultsController = __fetchedResultsController;

-(id)initWithAccount:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"GameListController"])
    {
    }
    
    return self;
}

-(void)dealloc
{
    [__fetchedResultsController release];
    
    [super dealloc];
}

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    [self hideRefreshHeaderTableView];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHGamesSynced
                                               object:nil];
    
    self.title = NSLocalizedString(@"MyPlayedGames", nil);
    
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if ([self.account areGamesStale])
        [self refreshUsingRefreshHeaderTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHGamesSynced
                                                  object:nil];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [[TaskController sharedInstance] synchronizeGamesForAccount:self.account
                                           managedObjectContext:managedObjectContext];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[TaskController sharedInstance] isSynchronizingGamesForAccount:self.account];
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return self.account.lastGamesUpdate;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"GameCell"
                                      owner:self
                                    options:nil];
        cell = [self tableViewCell];
    }
    
    [self configureCell:cell 
            atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Game selected
    
    NSManagedObject *game = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *uid = [game valueForKey:@"uid"];
    
    AchievementListController *ctlr = [[AchievementListController alloc] initWithAccount:self.account
                                                                             gameTitleId:uid];
    
    [self.navigationController pushViewController:ctlr
                                         animated:YES];
    
    [ctlr release];
}

- (void)configureCell:(UITableViewCell *)cell 
          atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Title
    
    UILabel *label = (UILabel*)[cell viewWithTag:2];
    [label setText:[managedObject valueForKey:@"title"]];
    
    // Last played
    
    label = (UILabel*)[cell viewWithTag:3];
    
    NSDate *lastPlayed = [managedObject valueForKey:@"lastPlayed"];
    [label setText:[NSString localizedStringWithFormat:NSLocalizedString(@"GameLastPlayed", nil), 
                    [self.dateFormatter stringFromDate:lastPlayed]]];
    
    // Achievement stats
    
    label = (UILabel*)[cell viewWithTag:4];
    [label setText:[NSString localizedStringWithFormat:NSLocalizedString(@"GameAchievementStats", nil), 
                    [managedObject valueForKey:@"achievesUnlocked"],
                    [managedObject valueForKey:@"achievesTotal"]]];
    
    // Gamescore stats
    
    label = (UILabel*)[cell viewWithTag:5];
    [label setText:[NSString localizedStringWithFormat:NSLocalizedString(@"GameScoreStats", nil), 
                    [self.numberFormatter stringFromNumber:[managedObject valueForKey:@"gamerScoreEarned"]],
                    [self.numberFormatter stringFromNumber:[managedObject valueForKey:@"gamerScoreTotal"]]]];
    
    // Icon
    
    UIImageView *view = (UIImageView*)[cell viewWithTag:6];
    UIImage *boxArt = [[ImageCache sharedInstance]
                       getCachedFile:[managedObject valueForKey:@"boxArtUrl"]
                       cropRect:CGRectMake(0, 16, 85, 85)
                       notifyObject:self
                       notifySelector:@selector(imageLoaded:)];
    
    [view setImage:boxArt];
}

- (void)imageLoaded:(NSString*)url
{
    // TODO: this causes a full data reload; not a good idea
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@", 
                              self.account.uuid];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XboxGame" 
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"listOrder" 
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
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
    return __fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
