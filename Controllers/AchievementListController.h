/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
 *
 * Copyright (C) 2011-2014 Akop Karapetyan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "GenericTableViewController.h"

@interface AchievementListController : GenericTableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UIActionSheetDelegate>

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
-(IBAction)toggleBeacon:(id)sender;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *beaconButton;

-(id)initWithAccount:(XboxLiveAccount*)account
         gameTitleId:(NSString*)gameTitleId;

@end
