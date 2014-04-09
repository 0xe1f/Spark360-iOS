/*
 * Spark 360 for iOS
 * https://github.com/Melllvar/Spark360-iOS
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

extern NSString* const BachErrorDomain;

typedef enum _XboxLiveParserErrorType
{
    XBLPGeneralError = 0,
    XBLPAuthenticationError = 1,
    XBLPNetworkError = 2,
    XBLPParsingError = 3,
    XBLPCoreDataError = 4,
} XboxLiveParserErrorType;

@interface XboxLiveParser : NSObject

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSError *lastError;

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)context;

-(BOOL)authenticateAccount:(XboxLiveAccount*)account
                     error:(NSError**)error;
-(BOOL)authenticate:(NSString*)emailAddress
       withPassword:(NSString*)password
              error:(NSError**)error;

// Used by the account creator/editor controllers
-(NSDictionary*)retrieveProfileWithEmailAddress:(NSString*)emailAddress
                                       password:(NSString*)password
                                          error:(NSError**)error;
-(BOOL)writeProfileOfAccount:(XboxLiveAccount*)account
         withRetrievedObject:(NSDictionary*)dict
                       error:(NSError**)error;

-(void)synchronizeProfile:(NSDictionary*)arguments;
-(void)synchronizeAchievements:(NSDictionary*)arguments;
-(void)synchronizeGames:(NSDictionary*)arguments;
-(void)synchronizeMessages:(NSDictionary*)arguments;
-(void)synchronizeFriends:(NSDictionary*)arguments;
-(void)synchronizeFriendProfile:(NSDictionary*)arguments;
-(void)syncMessage:(NSDictionary*)arguments;

-(void)sendAddFriendRequest:(NSDictionary*)arguments;
-(void)removeFromFriends:(NSDictionary*)arguments;
-(void)approveFriendRequest:(NSDictionary*)arguments;
-(void)rejectFriendRequest:(NSDictionary*)arguments;
-(void)cancelFriendRequest:(NSDictionary*)arguments;

-(void)loadProfile:(NSDictionary*)arguments;
-(void)compareGames:(NSDictionary*)arguments;
-(void)compareAchievements:(NSDictionary*)arguments;
-(void)loadRecentPlayers:(NSDictionary*)arguments;
-(void)loadFriendsOfFriend:(NSDictionary*)arguments;
-(void)loadGameOverview:(NSDictionary*)arguments;
-(void)loadXboxLiveStatus:(NSDictionary*)arguments;

-(void)deleteMessage:(NSDictionary*)arguments;
-(void)sendMessage:(NSDictionary*)arguments;

-(void)toggleBeacon:(NSDictionary*)arguments;

@end
