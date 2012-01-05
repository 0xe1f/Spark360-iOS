//
//  ProfileController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericProfileController.h"

@interface ProfileController : GenericProfileController

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account;

-(IBAction)refresh:(id)sender;
-(IBAction)addFriend:(id)sender;

@end
