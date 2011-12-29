//
//  GameOverviewController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
