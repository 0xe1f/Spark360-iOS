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
-(void)synchronizeAccount:(XboxAccount*)account;
-(void)synchronizeGames:(XboxAccount*)account;

@end
