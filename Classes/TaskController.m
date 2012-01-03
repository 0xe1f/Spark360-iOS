//
//  TaskController.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskController.h"

#import "XboxLiveAccount.h"
#import "XboxLiveParser.h"

NSString* const BACHProfileSynced = @"BachProfileSynced";
NSString* const BACHGamesSynced = @"BachGamesSynced";
NSString* const BACHAchievementsSynced = @"BachAchievementsSynced";
NSString* const BACHMessagesSynced = @"BachMessagesSynced";
NSString* const BACHFriendsSynced = @"BachFriendsSynced";
NSString* const BACHFriendProfileSynced = @"BachFriendProfileSynced";
NSString* const BACHBeaconsSynced = @"BachBeaconsSynced";

NSString* const BACHProfileLoaded = @"BachProfileLoaded";
NSString* const BACHFriendsChanged = @"BachFriendsChanged";

NSString* const BACHGamesCompared = @"BachGamesCompared";
NSString* const BACHAchievementsCompared = @"BachAchievementsCompared";
NSString* const BACHRecentPlayersLoaded = @"BachRecentPlayersLoaded";
NSString* const BACHFriendsOfFriendLoaded = @"BachFriendsOfFriendLoaded";
NSString* const BACHGameOverviewLoaded = @"BachGameOverviewLoaded";
NSString* const BACHXboxLiveStatusLoaded = @"BachXboxLiveStatusLoaded";

NSString* const BACHMessageSynced = @"BachMessageSynced";
NSString* const BACHMessagesChanged = @"BachMessageDeleted";
NSString* const BACHMessageSent = @"BachMessageSent";
NSString* const BACHError = @"BachError";

NSString* const BACHNotificationAccount = @"BachNotifAccount";
NSString* const BACHNotificationUid = @"BachNotifUid";
NSString* const BACHNotificationScreenName = @"BachNotifScreenName";
NSString* const BACHNotificationData = @"BachNotifData";
NSString* const BACHNotificationNSError = @"BachNotifNSError";

@implementation TaskController

static TaskController *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (TaskController*)sharedInstance 
{
    if (sharedInstance == nil) 
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    if (self = [super init]) 
    {
        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

#pragma mark - Controller Generics

-(void)addOperation:(TaskControllerOperation*)op
{
    if ([[opQueue operations] containsObject:op])
    {
        NSLog(@"! Task: %@ in queue", op.identifier);
        return;
    }
    
    [opQueue addOperation:op];
    
    NSLog(@"+ Task: %@", op.identifier);
}

-(BOOL)isOperationQueuedWithId:(NSString*)operationId
{
    for (TaskControllerOperation *op in [opQueue operations])
        if ([op.identifier isEqualToString:operationId])
            return YES;
    
    return NO;
}

#pragma mark - Specifics

-(void)synchronizeProfileForAccount:(XboxLiveAccount*)account
               managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Profile",
                            account.uuid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(synchronizeProfile:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)synchronizeGamesForAccount:(XboxLiveAccount*)account
             managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Games",
                            account.uuid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(synchronizeGames:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isSynchronizingGamesForAccount:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Games", 
                            account.uuid];
    return [self isOperationQueuedWithId:identifier];
}

-(void)synchronizeAchievementsForGame:(NSString*)gameUid
                              account:(XboxLiveAccount*)account
                 managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Achievements:%@",
                            account.uuid, gameUid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               gameUid, @"id", nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(synchronizeAchievements:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isSynchronizingAchievementsForGame:(NSString*)gameUid
                                  account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Achievements:%@", 
                            account.uuid, gameUid];
    return [self isOperationQueuedWithId:identifier];
}

-(void)synchronizeMessagesForAccount:(XboxLiveAccount*)account
                managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Messages",
                            account.uuid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(synchronizeMessages:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isSynchronizingMessagesForAccount:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Messages", 
                            account.uuid];
    return [self isOperationQueuedWithId:identifier];
}

-(void)synchronizeFriendsForAccount:(XboxLiveAccount*)account
               managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Friends",
                            account.uuid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(synchronizeFriends:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)loadRecentPlayersForAccount:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.RecentPlayers",
                            account.uuid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(loadRecentPlayers:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isLoadingRecentPlayersForAccount:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.RecentPlayers",
                            account.uuid];
    return [self isOperationQueuedWithId:identifier];
}

-(void)loadFriendsOfFriendForScreenName:(NSString*)screenName
                                 account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.FriendsOfFriends:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(loadFriendsOfFriend:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isLoadingFriendsOfFriendForScreenName:(NSString*)screenName
                                      account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.FriendsOfFriend:%@",
                            account.uuid, screenName];
    return [self isOperationQueuedWithId:identifier];
}

-(BOOL)isSynchronizingFriendsForAccount:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Friends", 
                            account.uuid];
    return [self isOperationQueuedWithId:identifier];
}

-(void)synchronizeFriendProfileForUid:(NSString*)uid
                              account:(XboxLiveAccount*)account
                 managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Friend:%@",
                            account.uuid, uid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               uid, @"uid",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(synchronizeFriendProfile:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isSynchronizingFriendProfileForUid:(NSString*)uid
                                  account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Friend:%@",
                            account.uuid, uid];
    return [self isOperationQueuedWithId:identifier];
}

-(void)loadProfileForScreenName:(NSString*)screenName
                        account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Profile:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(loadProfile:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)sendAddFriendRequestToScreenName:(NSString*)screenName
                                account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.AddFriend:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(sendAddFriendRequest:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)removeFromFriendsScreenName:(NSString*)screenName
                           account:(XboxLiveAccount*)account
              managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.RemoveFriend:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(removeFromFriends:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)approveFriendRequestScreenName:(NSString *)screenName 
                              account:(XboxLiveAccount *)account 
                 managedObjectContext:(NSManagedObjectContext *)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.ApproveFriendRequest:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(approveFriendRequest:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)rejectFriendRequestScreenName:(NSString *)screenName 
                             account:(XboxLiveAccount *)account
                managedObjectContext:(NSManagedObjectContext *)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.RejectFriendRequest:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(rejectFriendRequest:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)cancelFriendRequestScreenName:(NSString *)screenName
                             account:(XboxLiveAccount *)account 
                managedObjectContext:(NSManagedObjectContext *)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.CancelFriendRequest:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(cancelFriendRequest:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)compareGamesWithScreenName:(NSString*)screenName
                          account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.CompareGames:%@",
                            account.uuid, screenName];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(compareGames:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isComparingGamesWithScreenName:(NSString*)screenName
                              account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.CompareGames:%@",
                            account.uuid, screenName];
    return [self isOperationQueuedWithId:identifier];
}

-(void)compareAchievementsForGameUid:(NSString*)uid
                          screenName:(NSString*)screenName
                             account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.CompareAch:%@/%@",
                            account.uuid, screenName, uid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               uid, @"uid",
                               screenName, @"screenName",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(compareAchievements:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isComparingAchievementsForGameUid:(NSString*)uid
                              screenName:(NSString*)screenName
                                 account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.CompareAch:%@/%@",
                            account.uuid, screenName, uid];
    return [self isOperationQueuedWithId:identifier];
}
                                 
-(void)deleteMessageWithUid:(NSString*)uid
                    account:(XboxLiveAccount*)account
       managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.DeleteMessage:%@",
                            account.uuid, uid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               uid, @"uid",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(deleteMessage:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)sendMessageToRecipients:(NSArray*)recipients
                          body:(NSString*)body
                       account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.SendMessage:%i",
                            account.uuid, [body hash]];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               recipients, @"recipients",
                               body, @"body",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(sendMessage:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)syncMessageWithUid:(NSString*)uid
                  account:(XboxLiveAccount*)account
     managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.SyncMessage:%@",
                            account.uuid, uid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               uid, @"uid",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(syncMessage:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)loadGameOverviewWithUrl:(NSString*)url
                       account:(XboxLiveAccount*)account
{
    NSString *identifier = [NSString stringWithFormat:@"%@.GameOverview:%@",
                            account.uuid, url];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               url, @"url",
                               account, @"account",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(loadGameOverview:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(void)loadXboxLiveStatus:(XboxLiveAccount*)account
{
    NSString *identifier = @"XboxLiveStatus";
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:nil];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(loadXboxLiveStatus:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
    [op release];
}

-(BOOL)isLoadingXboxLiveStatus:(XboxLiveAccount*)account
{
    return [self isOperationQueuedWithId:@"XboxLiveStatus"];
}

#pragma mark Singleton stuff

// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    [opQueue release];
    
    // I'm never called!
    [super dealloc];
}

// We don't want to allocate a new instance, so return the current one.
+(id)allocWithZone:(NSZone*)zone 
{
    return [[self sharedInstance] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
-(id)copyWithZone:(NSZone *)zone 
{
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
-(id)retain 
{
    return self;
}

// Replace the retain counter so we can never release this object.
-(NSUInteger)retainCount 
{
    return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
-(oneway void)release 
{
    
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
-(id)autorelease 
{
    return self;
}

@end