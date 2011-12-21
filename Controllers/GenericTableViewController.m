//
//  GenericTableViewController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericTableViewController.h"

#import "BachAppDelegate.h"
#import "ImageCache.h"
#import "TaskController.h"

@implementation GenericTableViewController

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
    _refreshHeaderView = nil;
    
    [super dealloc];
}

#pragma mark - UIViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
	if (_refreshHeaderView == nil) 
    {
        CGRect rect = CGRectMake(0.0f, 
                                 0.0f - _tableView.bounds.size.height, 
                                 self.view.frame.size.width, 
                                 _tableView.bounds.size.height);
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:rect];
		view.delegate = self;
		[_tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
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
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return false;
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return nil;
}

#pragma mark - Notifications

-(void)onSyncError:(NSNotification *)notification
{
    NSLog(@"Got sync error notification");
    
    [self hideRefreshHeaderTableView];
    
    NSError *error = [notification.userInfo objectForKey:BACHNotificationNSError];
    
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

#pragma mark - Helper methods

-(void)refreshUsingRefreshHeaderTableView
{
    CGPoint offset = _tableView.contentOffset;
    offset.y = - 65.0f;
    _tableView.contentOffset = offset;
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:_tableView];
}

-(void)hideRefreshHeaderTableView
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
}

@end
