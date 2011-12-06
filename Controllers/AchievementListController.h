//
//  RootViewController.h
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "GenericListController.h"

@interface AchievementListController : GenericListController <NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSString *gameUid;
@property (nonatomic, retain) NSString *gameTitle;
@property (nonatomic, retain) NSDate *gameLastUpdated;
@property (nonatomic, assign) BOOL isGameDirty;

-(id)initWithAccount:(XboxLiveAccount*)account
         gameTitleId:(NSString*)gameTitleId;

@end
