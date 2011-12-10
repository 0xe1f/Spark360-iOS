//
//  MessageListController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"

@interface MessageListController : GenericController <UITableViewDataSource, NSFetchedResultsControllerDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    IBOutlet UITableView *myTableView;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *refreshButton;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(id)initWithAccount:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)compose:(id)sender;

@end
