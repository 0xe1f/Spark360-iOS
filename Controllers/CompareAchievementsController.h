//
//  CompareAchievementsController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericTableViewController.h"

@interface CompareAchievementsController : GenericTableViewController <UITableViewDataSource>

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSString *gameUid;
@property (nonatomic, retain) NSString *gameTitle;
@property (nonatomic, retain) NSString *gameDetailUrl;
@property (nonatomic, retain) NSDate *lastUpdated;

@property (nonatomic, retain) NSMutableArray *achievements;

-(id)initWithGameUid:(NSString*)gameUid
          screenName:(NSString*)screenName
             account:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)showDetails:(id)sender;

@end
