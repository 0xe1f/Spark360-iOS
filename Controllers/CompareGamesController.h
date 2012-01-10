//
//  CompareGamesController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericTableViewController.h"

@interface CompareGamesController : GenericTableViewController <UITableViewDataSource>

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSDate *lastUpdated;

@property (nonatomic, retain) NSMutableArray *games;

@property (nonatomic, retain) NSString *myIconUrl;
@property (nonatomic, retain) NSString *yourIconUrl;

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;

@end
