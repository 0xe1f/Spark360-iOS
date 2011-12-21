//
//  XboxLiveParser.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

// Retrieve* are expected to be called from background threads, and have a
// valid autorelease pool. They don't need a managed context
-(NSDictionary*)retrieveProfileWithEmailAddress:(NSString*)emailAddress
                                       password:(NSString*)password
                                          error:(NSError**)error;
-(NSDictionary*)retrieveProfileWithAccount:(XboxLiveAccount*)account
                                     error:(NSError**)error;

// Synchronize* are expected to be called from the main thread
-(BOOL)synchronizeProfileWithAccount:(XboxLiveAccount*)account
                 withRetrievedObject:(NSDictionary*)retrieved
                               error:(NSError**)error;

-(void)synchronizeAchievements:(NSDictionary*)arguments;
-(void)synchronizeGames:(NSDictionary*)arguments;
-(void)synchronizeMessages:(NSDictionary*)arguments;
-(void)synchronizeFriends:(NSDictionary*)arguments;
-(void)synchronizeFriendProfile:(NSDictionary*)arguments;

-(void)loadProfile:(NSDictionary*)arguments;

-(void)sendAddFriendRequest:(NSDictionary*)arguments;
-(void)removeFromFriends:(NSDictionary*)arguments;
-(void)approveFriendRequest:(NSDictionary*)arguments;
-(void)rejectFriendRequest:(NSDictionary*)arguments;
-(void)cancelFriendRequest:(NSDictionary*)arguments;

-(void)compareGames:(NSDictionary*)arguments;

-(void)deleteMessage:(NSDictionary*)arguments;
-(void)sendMessage:(NSDictionary*)arguments;

@end
