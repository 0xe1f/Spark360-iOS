//
//  XboxLiveParser.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFParser.h"
#import "XboxLiveAccount.h"

@interface XboxLiveParser : CFParser

-(void)parseGames:(XboxLiveAccount*)account
           context:(NSManagedObjectContext*)context;
-(BOOL)authenticateAccount:(XboxLiveAccount*)account
               withContext:(NSManagedObjectContext*)context;

// Private

+(NSString*)getActionUrl:(NSString*)text;
+(NSDate*)parseDate:(NSString*)dateStr;
+(NSString*)getUniversalIcon:(NSString*)icon;
+(NSMutableDictionary*)getInputs:(NSString*)response
                     namePattern:(NSRegularExpression*)namePattern;

@end
