//
//  XboxAccount.m
//  BachZero
//
//  Created by Akop Karapetyan on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxAccount.h"


@implementation XboxAccount

@dynamic emailAddress;
@dynamic password;
@dynamic screenName;
@dynamic iconUrl;
@dynamic isGold;
@dynamic lastGameSync;
@dynamic lastFriendSync;
@dynamic lastMessageSync;
@dynamic lastSummarySync;
@dynamic pointsBalance;
@dynamic rep;
@dynamic tier;
@dynamic unreadMessages;
@dynamic unreadNotifications;
@dynamic gamerscore;

- (void)save
{
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) 
    {
        NSLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

@end
