//
//  ProfileOverviewController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XboxLiveAccount.h"

@interface ProfileOverviewController : UIViewController
{
    IBOutlet UIButton *gamesButton;
}

@property (nonatomic, retain) XboxLiveAccount *account;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)viewGames:(id)sender;

@end
