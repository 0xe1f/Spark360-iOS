//
//  AccountListController.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "GenericTableViewController.h"

@protocol AccountSelectionDelegate
- (void)accountDidChange:(XboxLiveAccount*)account;
@end

@interface AccountListController : GenericTableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) IBOutlet id<AccountSelectionDelegate> selectionDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(IBAction)refresh:(id)sender;
-(IBAction)about:(id)sender;
-(IBAction)viewLiveStatus:(id)sender;

@end