//
//  XboxAccount.h
//  BachZero
//
//  Created by Akop Karapetyan on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface XboxAccount : NSManagedObject

@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSNumber * isGold;
@property (nonatomic, retain) NSDate * lastGameSync;
@property (nonatomic, retain) NSDate * lastFriendSync;
@property (nonatomic, retain) NSDate * lastMessageSync;
@property (nonatomic, retain) NSDate * lastSummarySync;
@property (nonatomic, retain) NSNumber * pointsBalance;
@property (nonatomic, retain) NSNumber * rep;
@property (nonatomic, retain) NSString * tier;
@property (nonatomic, retain) NSNumber * unreadMessages;
@property (nonatomic, retain) NSNumber * unreadNotifications;
@property (nonatomic, retain) NSNumber * gamerscore;

- (void)save;

@end
