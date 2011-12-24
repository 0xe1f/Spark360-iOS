//
//  MessageListController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericTableViewController.h"

@interface MessageListController : GenericTableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(id)initWithAccount:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)compose:(id)sender;

@end
