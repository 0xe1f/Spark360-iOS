/*
 * Spark 360 for iOS
 * https://github.com/Melllvar/Spark360-iOS
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
