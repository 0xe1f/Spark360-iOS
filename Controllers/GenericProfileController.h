//
//  GenericProfileController.h
//  BachZero
//
//  Created by Akop Karapetyan on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"

@interface GenericProfileController : GenericController<UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *composeButton;

@property (nonatomic, retain) NSMutableDictionary *profile;
@property (nonatomic, retain) NSMutableArray *beacons;
@property (nonatomic, copy) NSString *screenName;

+(void)showProfileWithScreenName:(NSString*)screenName
                         account:(XboxLiveAccount*)account
            managedObjectContext:(NSManagedObjectContext*)moc
            navigationController:(UINavigationController*)nc;

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account
                nibName:(NSString*)nibName;

-(IBAction)compareGames:(id)sender;
-(IBAction)compose:(id)sender;

@end
