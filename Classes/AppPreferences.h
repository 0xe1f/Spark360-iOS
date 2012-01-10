//
//  AppPreferences.h
//  BachZero
//
//  Created by Akop Karapetyan on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XboxLiveAccount.h"

@interface AppPreferences : NSObject

+(XboxLiveAccount*)createAndAddAccount;
+(XboxLiveAccount*)findAccountWithEmailAddress:(NSString*)emailAddress;
+(void)deleteAccountWithUuid:(NSString*)uuid
        managedObjectContext:(NSManagedObjectContext*)context;


@end
