//
//  TaskController.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskControllerOperation.h"
#import "XboxLiveAccount.h"

extern NSString* const BACHGamesSynced;
extern NSString* const BACHAchievementsSynced;
extern NSString* const BACHMessagesSynced;
extern NSString* const BACHError;

extern NSString* const BACHNotificationGameTitleId;
extern NSString* const BACHNotificationAccount;
extern NSString* const BACHNotificationNSError;

@interface TaskController : NSObject
{
    NSOperationQueue *opQueue;
}

+(id)sharedInstance;

-(BOOL)isOperationQueuedWithId:(NSString*)operationId;
-(void)addOperation:(TaskControllerOperation*)op;

-(void)synchronizeGamesForAccount:(XboxLiveAccount*)account
             managedObjectContext:(NSManagedObjectContext*)moc;
-(BOOL)isSynchronizingGamesForAccount:(XboxLiveAccount*)account;

-(void)synchronizeAchievementsForGame:(NSString*)gameUid
                              account:(XboxLiveAccount*)account
                 managedObjectContext:(NSManagedObjectContext*)moc;
-(BOOL)isSynchronizingAchievementsForGame:(NSString*)gameUid
                                  account:(XboxLiveAccount*)account;

-(void)synchronizeMessagesForAccount:(XboxLiveAccount*)account
                managedObjectContext:(NSManagedObjectContext*)moc;
-(BOOL)isSynchronizingMessagesForAccount:(XboxLiveAccount*)account;

@end
