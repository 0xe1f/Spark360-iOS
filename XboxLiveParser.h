//
//  XboxLiveParser.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxAccount.h"

extern NSString* const BachErrorDomain;

typedef enum _XboxLiveParserErrorType
{
    XBLPGeneralError = 0,
    XBLPAuthenticationError = 1,
    XBLPNetworkError = 2,
    XBLPParsingError = 3,
} XboxLiveParserErrorType;

@interface XboxLiveParser : NSObject

-(BOOL)authenticate:(NSString*)emailAddress
       withPassword:(NSString*)password
              error:(NSError**)error;
//-(void)synchronizeGames:(XboxAccount*)account;

// Retrieve* are expected to be called from background threads, and have a
// valid autorelease pool
-(NSDictionary*)retrieveProfileWithEmailAddress:(NSString*)emailAddress
                                       password:(NSString*)password
                                          error:(NSError**)error;

// Synchronize* are expected to be called from the main thread
-(void)synchronizeProfileWithAccount:(XboxAccount*)account
                 withRetrievedObject:(NSDictionary*)retrieved;

@end
