//
//  XboxLiveStatusController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericTableViewController.h"

@interface XboxLiveStatusController : GenericTableViewController<UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray *statuses;
@property (nonatomic, retain) NSDate *lastUpdated;

-(id)initWithAccount:(XboxLiveAccount *)account;

-(IBAction)refresh:(id)sender;

@end
