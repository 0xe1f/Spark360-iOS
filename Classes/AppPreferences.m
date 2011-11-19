//
//  AppPreferences.m
//  BachZero
//
//  Created by Akop Karapetyan on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppPreferences.h"

@interface AppPreferences (Private)

+(NSString*)createUuid;

@end

@implementation AppPreferences

+(NSString*)createUuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return [uuidString autorelease];
}

+(XboxLiveAccount*)createAndAddAccount
{
    NSString *uuid = [AppPreferences createUuid];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *uuidList = [prefs objectForKey:@"accountUuids"];
    
    NSMutableArray *uuids = [NSMutableArray arrayWithArray:[uuidList componentsSeparatedByString:@","]];
    [uuids addObject:uuid];
    
    [prefs setObject:[uuids componentsJoinedByString:@","] forKey:@"accountUuids"];
    
    return [[[XboxLiveAccount alloc] initWithUuid:uuid] autorelease];
}

+(XboxLiveAccount*)findAccountWithEmailAddress:(NSString*)emailAddress
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *uuidList = [prefs objectForKey:@"accountUuids"];
    
    NSArray *uuids = [uuidList componentsSeparatedByString:@","];
    for (NSString *uuid in uuids)
    {
        XboxLiveAccount *account = [XboxLiveAccount preferencesForUuid:uuid];
        if ([[account emailAddress] isEqualToString:emailAddress])
            return account;
    }
    
    return nil;
}

+(void)deleteAccountWithUuid:(NSString*)uuid
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *uuidList = [prefs objectForKey:@"accountUuids"];
    NSMutableArray *uuids = [NSMutableArray arrayWithArray:[uuidList componentsSeparatedByString:@","]];
    
    if ([uuids containsObject:uuid])
    {
        XboxLiveAccount *account = [XboxLiveAccount preferencesForUuid:uuid];
        [account purge];
        
        [uuids removeObject:uuid];
        
        [prefs setObject:[uuids componentsJoinedByString:@","]
                  forKey:@"accountUuids"];
    }
}

@end
