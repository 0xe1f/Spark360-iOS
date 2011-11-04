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

-(void)parseGames:(XboxAccount*)account
          context:(NSManagedObjectContext*)context;
-(BOOL)authenticate:(NSString*)emailAddress
       withPassword:(NSString*)password;
-(void)synchronizeAccount:(XboxAccount*)account
              withContext:(NSManagedObjectContext*)context;

@end
