//
//  XboxLiveParser.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFParser.h"
#import "XboxLiveAccount.h"
#import "XboxAccount.h"

@interface XboxLiveParser : CFParser

-(void)parseGames:(XboxLiveAccount*)account
           context:(NSManagedObjectContext*)context;
-(BOOL)authenticateAccount:(XboxLiveAccount*)account
               withContext:(NSManagedObjectContext*)context;

@end
