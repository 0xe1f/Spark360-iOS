/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
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

#import "GenericTableViewController.h"

#import "BachAppDelegate.h"
#import "AKImageCache.h"
#import "TaskController.h"

@implementation GenericTableViewController
{
    EGORefreshTableHeaderView *_refreshHeaderView;
};

@synthesize tableView = _tableView;
@synthesize tableViewCell;

#pragma mark - Initialization

-(id)initWithAccount:(XboxLiveAccount*)account
             nibName:(NSString*)nibName
{
    if (self = [super initWithAccount:account
                              nibName:nibName])
    {
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

#pragma mark - UIViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
	if ([self useRefreshTableHeaderView] && !_refreshHeaderView) 
    {
        CGRect rect = CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, 
                                 self.view.frame.size.width, 
                                 _tableView.bounds.size.height);
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:rect];
		view.delegate = self;
		[_tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
    
	[_refreshHeaderView refreshLastUpdatedDate];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    _refreshHeaderView = nil;
}

#pragma mark - UIScrollViewDelegate Methods

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
    [self mustSynchronizeWithRemote];
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [self lastSynchronized];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return false;
}

#pragma mark - Notifications

-(void)onSyncError:(NSNotification *)notification
{
    [super onSyncError:notification];
    
    [self hideRefreshHeaderTableView];
}

#pragma mark - Helper methods

-(void)updateSynchronizationDate
{
    [_refreshHeaderView refreshLastUpdatedDate];
}

-(BOOL)useRefreshTableHeaderView
{
    return NO;
}

-(NSDate*)lastSynchronized
{
    return nil;
}

-(void)synchronizeWithRemote
{
    if ([self useRefreshTableHeaderView])
    {
        CGPoint offset = _tableView.contentOffset;
        offset.y = - 65.0f;
        _tableView.contentOffset = offset;
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:_tableView];
    }
    else
    {
        [self mustSynchronizeWithRemote];
    }
}

-(void)mustSynchronizeWithRemote
{
}

-(void)hideRefreshHeaderTableView
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}

#pragma mark - Misc

-(void)receivedImage:(NSString*)url
           parameter:(id)parameter
{
    //NSIndexPath *indexPath = (NSIndexPath*)parameter;
    
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationNone];
}

-(UIImage*)tableCellImageFromUrl:(NSString*)url
                        cropRect:(CGRect)cropRect
                       indexPath:(NSIndexPath*)indexPath
{
    return [self imageFromUrl:url
                     cropRect:cropRect
                    parameter:indexPath];
}

-(UIImage*)tableCellImageFromUrl:(NSString*)url
                       indexPath:(NSIndexPath*)indexPath
{
    return [self imageFromUrl:url
                    parameter:indexPath];
}

@end
