//
//  XboxLiveParser.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFParser.h"
#import "XboxAccount.h"

@interface XboxLiveParser : CFParser

-(BOOL)authenticate:(NSString*)emailAddress
       withPassword:(NSString*)password;
//-(void)synchronizeAccount:(XboxAccount*)account;
-(void)synchronizeGames:(XboxAccount*)account;

// Retrieve* are expected to be called from background threads, and have a
// valid autorelease pool
-(NSDictionary*)retrieveProfileWithEmailAddress:(NSString*)emailAddress
                                       password:(NSString*)password;

// Synchronize* are expected to be called from the main thread
-(void)synchronizeProfileWithAccount:(XboxAccount*)account
                 withRetrievedObject:(NSDictionary*)retrieved;

@end
