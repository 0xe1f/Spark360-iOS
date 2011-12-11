//
//  MessageListController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageListController.h"

#import "CFImageCache.h"
#import "TaskController.h"

@interface MessageListController (Private)

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)imageLoaded:(NSString*)url;
-(void)refreshUsingTableViewHeader;

@end

@implementation MessageListController

@synthesize tvCell;
@synthesize fetchedResultsController = __fetchedResultsController;

-(id)initWithAccount:(XboxLiveAccount*)account
{
    if (self = [super initWithNibName:@"MessageListController" 
                               bundle:nil])
    {
        self.account = account;
    }
    
    return self;
}

-(void)didReceiveMemoryWarning
{
    [[CFImageCache sharedInstance] purgeInMemCache];
}

-(void)dealloc
{
    [__fetchedResultsController release];
    
    [super dealloc];
}

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:myTableView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHMessagesSynced
                                               object:nil];
    
    self.title = NSLocalizedString(@"MyMessages", nil);
    
	if (_refreshHeaderView == nil) 
    {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - myTableView.bounds.size.height, self.view.frame.size.width, myTableView.bounds.size.height)];
		view.delegate = self;
		[myTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
    
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if ([self.account areMessagesStale])
        [self refreshUsingTableViewHeader];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHMessagesSynced
                                                  object:nil];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [[TaskController sharedInstance] synchronizeMessagesForAccount:self.account
                                           managedObjectContext:managedObjectContext];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[TaskController sharedInstance] isSynchronizingMessagesForAccount:self.account];
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return self.account.lastMessagesUpdate;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObject *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[TaskController sharedInstance] deleteMessageWithUid:[message valueForKey:@"uid"]
                                                      account:self.account
                                         managedObjectContext:managedObjectContext];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"MessageCell"
                                      owner:self
                                    options:nil];
        cell = [self tvCell];
    }
    
    [self configureCell:cell 
            atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Message selected
    
    /* TODO
    NSManagedObject *game = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *uid = [game valueForKey:@"uid"];
    
    AchievementListController *ctlr = [[AchievementListController alloc] initWithAccount:self.account
                                                                             gameTitleId:uid];
    
    [self.navigationController pushViewController:ctlr
                                         animated:YES];
    
    [ctlr release];
     */
}

- (void)configureCell:(UITableViewCell *)cell 
          atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Excerpt
    UILabel *label = (UILabel*)[cell viewWithTag:2];
    [label setText:[managedObject valueForKey:@"excerpt"]];
    
    // Sender
    label = (UILabel*)[cell viewWithTag:3];
    [label setText:[NSString localizedStringWithFormat:NSLocalizedString(@"From_f", nil),
                    [managedObject valueForKey:@"sender"]]];
    
    // Sent
    NSDate *sent = [managedObject valueForKey:@"sent"];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    label = (UILabel*)[cell viewWithTag:4];
    [label setText:[NSString localizedStringWithFormat:NSLocalizedString(@"Sent_f", nil), 
                    [formatter stringFromDate:sent]]];
    
    // Icon
    UIImageView *view = (UIImageView*)[cell viewWithTag:6];
    UIImage *boxArt = [[CFImageCache sharedInstance]
                       getCachedFile:[managedObject valueForKey:@"senderIconUrl"]
                       notifyObject:self
                       notifySelector:@selector(imageLoaded:)];
    
    [view setImage:boxArt];
    [view setClipsToBounds:YES];
    
    /* TODO
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
    
     */
}

/* TODO
 */

-(void)imageLoaded:(NSString*)url
{
    // TODO: this causes a full data reload; not a good idea
    [myTableView reloadData];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XboxMessage" 
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent" 
                                                                   ascending:NO];
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
    [myTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[myTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [myTableView endUpdates];
}

#pragma mark - Actions

-(IBAction)refresh:(id)sender
{
    [self refreshUsingTableViewHeader];
}

-(IBAction)compose:(id)sender
{
    // TODO
}

#pragma mark - Helpers

-(void)refreshUsingTableViewHeader
{
    CGPoint offset = myTableView.contentOffset;
    offset.y = - 65.0f;
    myTableView.contentOffset = offset;
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:myTableView];
}

@end
