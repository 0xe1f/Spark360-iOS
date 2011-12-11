//
//  FriendListController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendListController.h"

#import "XboxLive.h"
#import "TaskController.h"
#import "CFImageCache.h"

@interface FriendListController (Private)

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation FriendListController

@synthesize fetchedResultsController = __fetchedResultsController;

-(id)initWithAccount:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"FriendListController"])
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHFriendsSynced
                                               object:nil];
    
    self.title = NSLocalizedString(@"MyFriends", nil);
    
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if ([self.account areFriendsStale])
        [self refreshUsingRefreshHeaderTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHFriendsSynced
                                                  object:nil];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [[TaskController sharedInstance] synchronizeFriendsForAccount:self.account
                                           managedObjectContext:managedObjectContext];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[TaskController sharedInstance] isSynchronizingFriendsForAccount:self.account];
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return self.account.lastFriendsUpdate;
}

#pragma mark - UITableViewDataSource

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [XboxLive descriptionFromFriendStatus:[[sectionInfo name] intValue]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FriendCell"
                                      owner:self
                                    options:nil];
        cell = self.tableViewCell;
    }
    
    [self configureCell:cell 
            atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Friend selected
    
}

- (void)configureCell:(UITableViewCell *)cell 
          atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *label;
    UIImageView *icon;
    
    label = (UILabel*)[cell viewWithTag:2];
    [label setText:[obj valueForKey:@"screenName"]];
    
    label = (UILabel*)[cell viewWithTag:3];
    [label setText:[obj valueForKey:@"activityText"]];
    
    label = (UILabel*)[cell viewWithTag:5];
    [label setText:[NSString localizedStringWithFormat:[self.numberFormatter stringFromNumber:[obj valueForKey:@"gamerscore"]]]];
    
    // Gamerpic
    
    UIImage *gamerpic = [[CFImageCache sharedInstance] getCachedFile:[obj valueForKey:@"iconUrl"]
                                                        notifyObject:self
                                                      notifySelector:@selector(imageLoaded:)];
    
    icon = (UIImageView*)[cell viewWithTag:6];
    [icon setImage:gamerpic];
    
    // Box art
    
    UIImage *boxArt = [[CFImageCache sharedInstance] getCachedFile:[obj valueForKey:@"activityTitleIconUrl"]
                                                      notifyObject:self
                                                    notifySelector:@selector(imageLoaded:)];
    
    // TODO: Inefficient, pre-scale
    CGImageRef imageRef = CGImageCreateWithImageInRect([boxArt CGImage], 
                                                       CGRectMake(0, 16, 85, 85));
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    
    icon = (UIImageView*)[cell viewWithTag:7];
    [icon setImage:thumbnail];
    [icon setClipsToBounds:YES];
    
    CGImageRelease(imageRef);
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XboxFriend" 
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortByStatus = [[NSSortDescriptor alloc] initWithKey:@"statusCode" 
                                                                 ascending:YES];
    NSSortDescriptor *sortByScreenName = [[NSSortDescriptor alloc] initWithKey:@"screenName" 
                                                                     ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByStatus, sortByScreenName, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:@"statusCode" 
                                                                                                           cacheName:nil]; // AK: cacheName was 'Root'
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortByStatus release];
    [sortByScreenName release];
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

-(void)refresh:(id)sender
{
    [self refreshUsingRefreshHeaderTableView];
}

@end
