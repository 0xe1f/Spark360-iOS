//
//  RootViewController.m
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AchievementListController.h"

#import "ImageCache.h"
#import "TaskController.h"

#import "XboxLiveParser.h"

@interface AchievementListController (Private)

-(void)updateGameStats;
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation AchievementListController

@synthesize tvCell;
@synthesize fetchedResultsController = __fetchedResultsController;

@synthesize gameUid;
@synthesize gameTitle;
@synthesize isGameDirty;
@synthesize gameLastUpdated;

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    [self updateGameStats];
    [self hideRefreshHeaderTableView];
}

-(id)initWithAccount:(XboxLiveAccount*)account
         gameTitleId:(NSString*)gameTitleId
{
    if (self = [super initWithNibName:@"AchievementListController" 
                               bundle:nil])
    {
        self.account = account;
        self.gameUid = gameTitleId;
    }
    
    return self;
}

-(void)dealloc
{
    [__fetchedResultsController release];
    
    gameTitle = nil;
    gameUid = nil;
    gameLastUpdated = nil;
    
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
        self.isGameDirty = [[game valueForKey:@"achievesDirty"] boolValue];
        self.gameLastUpdated = [game valueForKey:@"lastUpdated"];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHAchievementsSynced 
                                               object:nil];
    
    [self updateGameStats];
    
    self.title = [NSString localizedStringWithFormat:NSLocalizedString(@"Achievements_f", nil),
                  gameTitle];
    
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if (self.isGameDirty)
        [self refreshUsingRefreshHeaderTableView];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHAchievementsSynced
                                                  object:nil];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [[TaskController sharedInstance] synchronizeAchievementsForGame:self.gameUid
                                                            account:self.account
                                               managedObjectContext:managedObjectContext];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return [[TaskController sharedInstance] isSynchronizingAchievementsForGame:self.gameUid
                                                                       account:self.account];
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return self.gameLastUpdated;
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
        cell = [self tvCell];
    }
    
    [self configureCell:cell 
            atIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Achievement selected
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
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        unlockedText = [NSString localizedStringWithFormat:NSLocalizedString(@"AchieveUnlocked_f", nil), 
                        [formatter stringFromDate:acquired]];
    }
    
    label = (UILabel*)[cell viewWithTag:3];
    [label setText:unlockedText];
    
    // Gamescore
    
    label = (UILabel*)[cell viewWithTag:5];
    [label setText:[[managedObject valueForKey:@"points"] stringValue]];
    
    // Icon

    UIImageView *view = (UIImageView*)[cell viewWithTag:7];
    UIImage *icon = [[ImageCache sharedInstance] getCachedFile:[managedObject valueForKey:@"iconUrl"]
                                                  notifyObject:self
                                                notifySelector:@selector(imageLoaded:)];
    
    [view setImage:icon];
    [view setClipsToBounds:YES];
}

-(void)imageLoaded:(NSString*)url
{
    // TODO: this causes a full data reload; not a good idea
    [self.tableView reloadData];
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
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    
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

@end
