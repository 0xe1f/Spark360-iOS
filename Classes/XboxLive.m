//
//  XboxLive.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLive.h"

@implementation XboxLive

+(NSString*)descriptionFromFriendStatus:(XBLFriendStatus)status
{
    if (status == XBLFriendOnline)
        return NSLocalizedString(@"FriendOnline", nil);
    else if (status == XBLFriendPending)
        return NSLocalizedString(@"FriendPending", nil);
    else
        return NSLocalizedString(@"FriendOffline", nil);
}

@end
