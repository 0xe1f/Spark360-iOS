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

#import "AQGridView.h"
#import "GenericController.h"

@interface GameOverviewController : GenericController <AQGridViewDelegate, AQGridViewDataSource>

@property (nonatomic, retain) NSString *gameTitle;
@property (nonatomic, retain) NSString *detailUrl;
@property (nonatomic, retain) NSDictionary *gameDetails;
@property (nonatomic, retain) NSMutableArray *screenshots;

@property (nonatomic, retain) IBOutlet AQGridView * gridView;
@property (nonatomic, retain) IBOutlet UITextView *gameDescription;
@property (nonatomic, retain) IBOutlet UILabel *gameTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *boxArt;

-(id)initWithTitle:(NSString*)title
         detailUrl:(NSString*)detailUrl
           account:(XboxLiveAccount *)account;

@end
