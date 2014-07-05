/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
 *
 * Copyright (C) 2011-2014 Akop Karapetyan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

#import "XboxLiveAccount.h"

extern NSString* const BACHProfileSynced;
extern NSString* const BACHGamesSynced;
extern NSString* const BACHAchievementsSynced;
extern NSString* const BACHMessagesSynced;
extern NSString* const BACHFriendsSynced;
extern NSString* const BACHFriendProfileSynced;
extern NSString* const BACHBeaconsSynced;

extern NSString* const BACHProfileLoaded;
extern NSString* const BACHFriendsChanged;
extern NSString* const BACHGamesCompared;
extern NSString* const BACHAchievementsCompared;
extern NSString* const BACHRecentPlayersLoaded;
extern NSString* const BACHFriendsOfFriendLoaded;
extern NSString* const BACHGameOverviewLoaded;
extern NSString* const BACHXboxLiveStatusLoaded;

extern NSString* const BACHBeaconToggled;

extern NSString* const BACHMessageSynced;
extern NSString* const BACHMessagesChanged;
extern NSString* const BACHMessageSent;

extern NSString* const BACHError;

extern NSString* const BACHNotificationAccount;
extern NSString* const BACHNotificationUid;
extern NSString* const BACHNotificationScreenName;
extern NSString* const BACHNotificationData;
extern NSString* const BACHNotificationNSError;

@interface TaskControllerOperation : NSOperation

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, retain) NSDictionary *arguments;
@property (nonatomic, retain) id selectorOwner;
@property (nonatomic, assign) SEL backgroundSelector;
@property (nonatomic, assign) BOOL isNetworked;

- (id)initWithIdentifier:(NSString*)identifier
           selectorOwner:(id)selectorOwner
      backgroundSelector:(SEL)backgroundSelector
               arguments:(NSDictionary*)arguments;

@end

@interface TaskController : NSObject
{
    NSOperationQueue *opQueue;
}

+(id)sharedInstance;

-(BOOL)isOperationQueuedWithId:(NSString*)operationId;
-(void)addOperation:(TaskControllerOperation*)op;

-(void)synchronizeProfileForAccount:(XboxLiveAccount*)account
               managedObjectContext:(NSManagedObjectContext*)moc;

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

-(void)synchronizeFriendsForAccount:(XboxLiveAccount*)account
               managedObjectContext:(NSManagedObjectContext*)moc;
-(BOOL)isSynchronizingFriendsForAccount:(XboxLiveAccount*)account;

-(void)synchronizeFriendProfileForUid:(NSString*)uid
                              account:(XboxLiveAccount*)account
                 managedObjectContext:(NSManagedObjectContext*)moc;
-(BOOL)isSynchronizingFriendProfileForUid:(NSString*)uid
                                  account:(XboxLiveAccount*)account;

-(void)loadProfileForScreenName:(NSString*)screenName
                        account:(XboxLiveAccount*)account;

-(void)loadRecentPlayersForAccount:(XboxLiveAccount*)account;
-(BOOL)isLoadingRecentPlayersForAccount:(XboxLiveAccount*)account;

-(void)loadFriendsOfFriendForScreenName:(NSString*)screenName
                                 account:(XboxLiveAccount*)account;
-(BOOL)isLoadingFriendsOfFriendForScreenName:(NSString*)screenName
                                      account:(XboxLiveAccount*)account;

-(void)sendAddFriendRequestToScreenName:(NSString*)screenName
                                account:(XboxLiveAccount*)account;

-(void)removeFromFriendsScreenName:(NSString*)screenName
                           account:(XboxLiveAccount*)account
              managedObjectContext:(NSManagedObjectContext*)moc;

-(void)approveFriendRequestScreenName:(NSString*)screenName
                       account:(XboxLiveAccount*)account
          managedObjectContext:(NSManagedObjectContext*)moc;

-(void)rejectFriendRequestScreenName:(NSString*)screenName
                             account:(XboxLiveAccount*)account
                managedObjectContext:(NSManagedObjectContext*)moc;

-(void)cancelFriendRequestScreenName:(NSString*)screenName
                             account:(XboxLiveAccount*)account
                managedObjectContext:(NSManagedObjectContext*)moc;

-(void)compareGamesWithScreenName:(NSString*)screenName
                          account:(XboxLiveAccount*)account;
-(BOOL)isComparingGamesWithScreenName:(NSString*)screenName
                              account:(XboxLiveAccount*)account;

-(void)compareAchievementsForGameUid:(NSString*)uid
                          screenName:(NSString*)screenName
                             account:(XboxLiveAccount*)account;
-(BOOL)isComparingAchievementsForGameUid:(NSString*)uid
                              screenName:(NSString*)screenName
                                 account:(XboxLiveAccount*)account;

-(void)loadGameOverviewWithUrl:(NSString*)url
                       account:(XboxLiveAccount*)account;

-(void)loadXboxLiveStatus:(XboxLiveAccount*)account;
-(BOOL)isLoadingXboxLiveStatus:(XboxLiveAccount*)account;

-(void)deleteMessageWithUid:(NSString*)uid
                    account:(XboxLiveAccount*)account
       managedObjectContext:(NSManagedObjectContext*)moc;

-(void)sendMessageToRecipients:(NSArray*)recipients
                          body:(NSString*)body
                       account:(XboxLiveAccount*)account;

-(void)syncMessageWithUid:(NSString*)uid
                  account:(XboxLiveAccount*)account
     managedObjectContext:(NSManagedObjectContext*)moc;

-(void)setBeaconForGameUid:(NSString*)uid
                   account:(XboxLiveAccount*)account
                   message:(NSString*)message
      managedObjectContext:(NSManagedObjectContext*)moc;

-(void)clearBeaconForGameUid:(NSString*)uid
                     account:(XboxLiveAccount*)account
        managedObjectContext:(NSManagedObjectContext*)moc;

@end
