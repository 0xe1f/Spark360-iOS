//
//  MessageListController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageListController.h"

#import "MessageCell.h"
#import "ImageCache.h"
#import "TaskController.h"

#import "MessageComposeController.h"
#import "ViewMessageController.h"

@interface MessageListController (Private)

- (void)configureCell:(UITableViewCell *)cell 
          atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MessageListController

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

-(void)dealloc
{
    self.fetchedResultsController = nil;
    
    [super dealloc];
}

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    
    if ([account isEqualToAccount:self.account])
    {
        [self hideRefreshHeaderTableView];
    }
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
    
	[_refreshHeaderView refreshLastUpdatedDate];
    
    if ([self.account areMessagesStale])
        [self refreshUsingRefreshHeaderTableView];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHMessagesSynced
                                                  object:nil];
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
        
        cell = self.tableViewCell;
    }
    
    [self configureCell:cell 
            atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Message selected
    NSManagedObject *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ViewMessageController *ctlr = [[ViewMessageController alloc] initWithUid:[message valueForKey:@"uid"]
                                                                     account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)imageLoaded:(NSString*)url
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
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] 
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Actions

-(IBAction)refresh:(id)sender
{
    [self refreshUsingRefreshHeaderTableView];
}

-(IBAction)compose:(id)sender
{
    MessageComposeController *ctlr = [[MessageComposeController alloc] initWithRecipient:nil
                                                                                 account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

#pragma mark - Misc

- (void)configureCell:(UITableViewCell *)cell 
          atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MessageCell *messageCell = (MessageCell*)cell;
    
    NSString *excerptTemplate;
    if (![[managedObject valueForKey:@"isDirty"] boolValue])
        excerptTemplate = NSLocalizedString(@"MessageExcerptTemplate_f", nil);
    else
        excerptTemplate = NSLocalizedString(@"MessageDirtyExcerptTemplate_f", nil);
    
    messageCell.title.text = [NSString stringWithFormat:excerptTemplate,
                              [managedObject valueForKey:@"excerpt"]];
    messageCell.sender.text = [NSString localizedStringWithFormat:NSLocalizedString(@"From_f", nil), 
                        [managedObject valueForKey:@"sender"]];
    messageCell.sent.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Sent_f", nil), 
                      [self.shortDateFormatter stringFromDate:[managedObject valueForKey:@"sent"]]];
    messageCell.attachment.hidden = !([[managedObject valueForKey:@"hasPicture"] boolValue] || 
                                      [[managedObject valueForKey:@"hasVoice"] boolValue]);
    messageCell.unreadMarker.hidden = [[managedObject valueForKey:@"isRead"] boolValue];
    
    UIImage *gamerpic = [[ImageCache sharedInstance] getCachedFile:[managedObject valueForKey:@"senderIconUrl"]
                                                      notifyObject:self
                                                    notifySelector:@selector(imageLoaded:)];
    
    messageCell.gamerpic.image = gamerpic;
}

@end
