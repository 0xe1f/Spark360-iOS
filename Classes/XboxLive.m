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
    else if (status == XBLFriendOffline)
        return NSLocalizedString(@"FriendOffline", nil);
    
    return NSLocalizedString(@"Unknown", nil);
}

+(BOOL)isPlayable:(NSString *)titleId
{
    if ([titleId isEqualToString:@"4293722112"])
        return NO; // Xbox.com
    else if ([titleId isEqualToString:@"0"])
        return NO; // Unknown
    else if ([titleId isEqualToString:@"4294838225"])
        return NO; // Xbox Dashboard
    
    return YES;
}
@end
