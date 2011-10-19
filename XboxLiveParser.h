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

- (NSString*)getUniversalIcon:(NSString*)icon;
- (void)parseGames:(XboxLiveAccount*)account
           context:(NSManagedObjectContext*)context;

@end
