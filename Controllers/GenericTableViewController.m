//
//  GenericTableViewController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
    NSIndexPath *indexPath = (NSIndexPath*)parameter;
    
    if ([self.tableView cellForRowAtIndexPath:indexPath])
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
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
