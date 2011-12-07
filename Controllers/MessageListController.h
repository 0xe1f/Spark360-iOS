//
//  MessageListController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericListController.h"

@interface MessageListController : GenericListController <NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(id)initWithAccount:(XboxLiveAccount*)account;

@end
