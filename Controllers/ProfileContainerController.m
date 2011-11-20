//
//  ProfileContainer.m
//  BachZero
//
//  Created by Akop Karapetyan on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileContainerController.h"

@implementation ProfileContainerController

@synthesize tabBarController;
@synthesize selectedViewController;
@synthesize account;
@synthesize managedObjectContext;

- (void)dealloc 
{
    self.tabBarController = nil;
    self.selectedViewController = nil;
    self.managedObjectContext = nil;
    
    self.account = nil;
    
    [gameListController release]; 
    gameListController = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark UITabBarControllerDelegate Methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController 
{
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController 
{
    /*
	self.navigationItem.titleView = nil;
	self.navigationItem.rightBarButtonItem = nil;
	if (viewController == postsViewController) {
		[[NSUserDefaults standardUserDefaults] setValue:@"Posts" forKey:@"WPSelectedContentType"];
		self.navigationItem.rightBarButtonItem = postsViewController.newButtonItem;
	} 
	else if (viewController == pagesViewController) {
		[[NSUserDefaults standardUserDefaults] setValue:@"Pages" forKey:@"WPSelectedContentType"];
		self.navigationItem.rightBarButtonItem = pagesViewController.newButtonItem;
	} 
	else if (viewController == commentsViewController) {
		[self configureCommentsTab];
	}
	//uncomment me to add stats back
	else if (viewController == statsTableViewController) {
		[[NSUserDefaults standardUserDefaults] setValue:@"Stats" forKey:@"WPSelectedContentType"];
	}
	
	[viewController viewWillAppear:NO];
    */
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view = tabBarController.view;
    self.title = account.screenName;
    
    gamesItem.title = NSLocalizedString(@"Games", @"");
    
    gameListController.account = account;
    gameListController.managedObjectContext = self.managedObjectContext;
    
	if (self.selectedViewController)
    {
		[self tabBarController].selectedViewController = self.selectedViewController;
    }
	else
    {
		[self tabBarController].selectedViewController = gameListController;
    }
    
    [self tabBarController:tabBarController didSelectViewController:tabBarController.selectedViewController];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
