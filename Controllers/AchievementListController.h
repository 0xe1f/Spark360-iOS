//
//  RootViewController.h
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "GenericTableViewController.h"

@interface AchievementListController : GenericTableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UILabel *gameTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *gameLastPlayedLabel;
@property (nonatomic, retain) IBOutlet UILabel *gameAchievesLabel;
@property (nonatomic, retain) IBOutlet UILabel *gameGamerScoreLabel;
@property (nonatomic, retain) IBOutlet UIImageView *gameBoxArtIcon;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSString *gameUid;
@property (nonatomic, retain) NSString *gameTitle;
@property (nonatomic, retain) NSString *gameDetailUrl;
@property (nonatomic, retain) NSDate *gameLastUpdated;
@property (nonatomic, assign) BOOL isGameDirty;
@property (nonatomic, assign) BOOL isBeaconSet;

-(IBAction)refresh:(id)sender;
-(IBAction)showDetails:(id)sender;

-(id)initWithAccount:(XboxLiveAccount*)account
         gameTitleId:(NSString*)gameTitleId;

@end
