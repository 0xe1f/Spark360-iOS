//
//  RootViewController.m
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericListController.h"

#import "BachAppDelegate.h"
#import "CFImageCache.h"

@implementation GenericListController

@synthesize tvCell;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize numberFormatter = __numberFormatter;

@synthesize account;

-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    BachAppDelegate *bachApp = [BachAppDelegate sharedApp];
    managedObjectContext = bachApp.managedObjectContext;
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    return self;
}

-(void)dealloc
{
    self.numberFormatter = nil;
    self.account = nil;
    self.fetchedResultsController = nil;
    
    [managedObjectContext release];
    managedObjectContext = nil;
    
    [_refreshHeaderView release];
    _refreshHeaderView = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[CFImageCache sharedInstance] purgeInMemCache];
    
    // EGORefreshHeaderTableView
	if (_refreshHeaderView == nil) 
    {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
	
	[_refreshHeaderView refreshLastUpdatedDate];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[CFImageCache sharedInstance] purgeInMemCache];
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

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

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

#pragma mark -
#pragma mark Etc...

-(void)refreshUsingRefreshHeaderTableView
{
    CGPoint offset = self.tableView.contentOffset;
    offset.y = - 65.0f;
    self.tableView.contentOffset = offset;
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
}

@end
