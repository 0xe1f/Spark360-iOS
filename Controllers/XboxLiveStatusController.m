/*
 * Spark 360 for iOS
 * https://github.com/Melllvar/Spark360-iOS
 *
 * Copyright (C) 2011-2014 Akop Karapetyan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

#import "XboxLiveStatusController.h"

#import "TaskController.h"

#import "XboxLiveStatusCell.h"

@implementation XboxLiveStatusController

@synthesize statuses = _statuses;
@synthesize lastUpdated = _lastUpdated;

-(id)initWithAccount:(XboxLiveAccount *)account;
{
    if ((self = [super initWithAccount:account
                               nibName:@"XboxLiveStatusController"]))
    {
        _statuses = [[NSMutableArray alloc] init];
        self.lastUpdated = nil;
    }
    
    return self;
}

-(void)dealloc
{
    self.statuses = nil;
    self.lastUpdated = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"XboxLiveStatus", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusLoaded:)
                                                 name:BACHXboxLiveStatusLoaded
                                               object:nil];
    
	self.tableView.backgroundColor = [UIColor clearColor];
    
    [self synchronizeWithRemote];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHXboxLiveStatusLoaded
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
    
    [[TaskController sharedInstance] loadXboxLiveStatus:self.account];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return [[TaskController sharedInstance] isLoadingXboxLiveStatus:self.account];
}

#pragma mark - UITableViewDataSource

- (NSString*)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return NSLocalizedString(@"Services", nil);
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    XboxLiveStatusCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.row < [self.statuses count])
    {
        if (!cell)
        {
            [[NSBundle mainBundle] loadNibNamed:@"XboxLiveStatusCell"
                                          owner:self
                                        options:nil];
            
            cell = (XboxLiveStatusCell*)self.tableViewCell;
        }
        
        NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
        
        cell.statusName.text = [status objectForKey:@"name"];
        cell.statusDescription.text = [status objectForKey:@"description"];
        
        NSString *statusIconFile;
        if ([[status objectForKey:@"isOk"] boolValue])
            statusIconFile = @"xboxStatusOk";
        else 
            statusIconFile = @"xboxStatusNotOk";
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:statusIconFile
                                                              ofType:@"png"];
        
        cell.statusIcon.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[status objectForKey:@"name"] 
                                                        message:[status objectForKey:@"description"]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK",nil) 
                                              otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
}

#pragma mark - Notifications

-(void)statusLoaded:(NSNotification *)notification
{
    BACHLog(@"Got statusLoaded notification");
    
    NSDictionary *data = [notification.userInfo objectForKey:BACHNotificationData];
    NSArray *statuses = [data objectForKey:@"statusList"];
    
    [self hideRefreshHeaderTableView];
    
    [self.statuses removeAllObjects];
    [self.statuses addObjectsFromArray:statuses];
    
    self.lastUpdated = [NSDate date];
    [self.tableView reloadData];
    
    [self updateSynchronizationDate];
}

#pragma mark - Actions

-(IBAction)refresh:(id)sender
{
    [self synchronizeWithRemote];
}

@end
