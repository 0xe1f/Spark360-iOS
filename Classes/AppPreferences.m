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
        managedObjectContext:(NSManagedObjectContext*)context
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
        
        NSEntityDescription *entityDescription;
        NSPredicate *predicate;
        NSArray *objects;
        NSFetchRequest *request;
        
        // XboxAchievement
        
        predicate = [NSPredicate predicateWithFormat:@"game.profile.uuid == %@", uuid];
        entityDescription = [NSEntityDescription entityForName:@"XboxAchievement"
                                        inManagedObjectContext:context];
        
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        objects = [context executeFetchRequest:request 
                                         error:NULL];
        
        [request release];
        
        for (NSManagedObject *obj in objects)
            [context deleteObject:obj];
        
        // XboxGame
        
        predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@", uuid];
        entityDescription = [NSEntityDescription entityForName:@"XboxGame"
                                        inManagedObjectContext:context];
        
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        objects = [context executeFetchRequest:request 
                                                  error:NULL];
        
        [request release];
        
        for (NSManagedObject *obj in objects)
            [context deleteObject:obj];
        
        // XboxMessage
        
        predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@", uuid];
        entityDescription = [NSEntityDescription entityForName:@"XboxMessage"
                                        inManagedObjectContext:context];
        
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        objects = [context executeFetchRequest:request 
                                         error:NULL];
        
        [request release];
        
        for (NSManagedObject *obj in objects)
            [context deleteObject:obj];
        
        // XboxFriendBeacon
        
        predicate = [NSPredicate predicateWithFormat:@"friend.profile.uuid == %@", uuid];
        entityDescription = [NSEntityDescription entityForName:@"XboxFriendBeacon"
                                        inManagedObjectContext:context];
        
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        objects = [context executeFetchRequest:request 
                                         error:NULL];
        
        [request release];
        
        for (NSManagedObject *obj in objects)
            [context deleteObject:obj];
        
        // XboxFriend
        
        predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@", uuid];
        entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                        inManagedObjectContext:context];
        
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        objects = [context executeFetchRequest:request 
                                         error:NULL];
        
        [request release];
        
        for (NSManagedObject *obj in objects)
            [context deleteObject:obj];
        
        // XboxProfile
        
        predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
        entityDescription = [NSEntityDescription entityForName:@"XboxProfile"
                                        inManagedObjectContext:context];
        
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        objects = [context executeFetchRequest:request 
                                         error:NULL];
        
        [request release];
        
        for (NSManagedObject *obj in objects)
            [context deleteObject:obj];
    }
}

@end
