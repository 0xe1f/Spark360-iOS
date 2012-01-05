//
//  FriendProfileController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericProfileController.h"

@interface FriendProfileController : GenericProfileController<UIActionSheetDelegate>

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)showActionMenu:(id)sender;
-(IBAction)viewFriends:(id)sender;

@end
