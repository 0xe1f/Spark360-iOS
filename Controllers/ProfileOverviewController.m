//
//  ProfileOverviewController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileOverviewController.h"

#import "GameListController.h"
#import "MessageListController.h"
#import "FriendListController.h"

@implementation ProfileOverviewController

@synthesize account;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    account = nil;
    managedObjectContext = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewGames:(id)sender
{
    GameListController *ctlr = [[GameListController alloc] initWithAccount:account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)viewMessages:(id)sender
{
    MessageListController *ctlr = [[MessageListController alloc] initWithAccount:account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)viewFriends:(id)sender
{
    FriendListController *ctlr = [[FriendListController alloc] initWithAccount:account];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MyProfile", nil);
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
