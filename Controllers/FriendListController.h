//
//  FriendListController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericTableViewController.h"

@interface FriendListController : GenericTableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(id)initWithAccount:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)findGamertag:(id)sender;
-(IBAction)viewRecentPlayers:(id)sender;

@end
