//
//  XboxLive.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XboxLive : NSObject

typedef enum _XBLFriendStatus
{
    XBLFriendUnknown = 0,
    XBLFriendPending = 1,
    XBLFriendOnline = 2,
    XBLFriendOffline = 3,
} XBLFriendStatus;

+(NSString*)descriptionFromFriendStatus:(XBLFriendStatus)status;

@end
