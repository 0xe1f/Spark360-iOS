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
    XBLFriendPending = 0,
    XBLFriendOnline = 1,
    XBLFriendOffline = 2,
} XBLFriendStatus;

+(NSString*)descriptionFromFriendStatus:(XBLFriendStatus)status;

@end
