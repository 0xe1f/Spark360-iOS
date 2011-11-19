//
//  ProfileContainer.h
//  BachZero
//
//  Created by Akop Karapetyan on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XboxLiveAccount.h"
#import "GameListController.h"

@interface ProfileContainerController : UIViewController<UITabBarControllerDelegate>
{
    IBOutlet UITabBarItem *gamesItem /*, *postsItem, *pagesItem, *statsItem*/;
    IBOutlet GameListController *gameListController;
}

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) XboxLiveAccount *account;

@end
