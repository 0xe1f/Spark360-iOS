//
//  XboxLiveAccountPreferences.h
//  BachZero
//
//  Created by Akop Karapetyan on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const BACHGamesSynced;

@interface XboxLiveAccount : NSObject

@property (nonatomic, assign) BOOL isSyncingGames;

-(id)initWithUuid:(NSString*)uuid;
+(id)preferencesForUuid:(NSString*)uuid;

-(void)reload;
-(void)save;
-(void)purge;

-(NSString*)uuid;

-(NSString*)screenName;
-(void)setScreenName:(NSString*)screenName;

-(NSDate*)lastGamesUpdate;
-(void)setLastGamesUpdate:(NSDate*)lastUpdate;

-(NSNumber*)stalePeriodInSeconds;
-(void)setStalePeriodInSeconds:(NSNumber*)browseRefreshPeriodInSeconds;

-(NSString*)emailAddress;
-(void)setEmailAddress:(NSString*)emailAddress;

-(NSString*)password;
-(void)setPassword:(NSString*)password;

-(BOOL)isEqualToAccount:(XboxLiveAccount*)account;

-(BOOL)areGamesStale;

-(void)syncGamesInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
