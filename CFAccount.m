//
//  CFAccount.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFAccount.h"

@implementation CFAccount

@synthesize accountId;
@synthesize username;
@synthesize password;

- (id)init
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuid = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    return [self initWithAccountId:uuid];
}

- (id)initWithAccountId:(NSString*)accountGuid
{
    self = [super init];
    if (self) 
    {
        self.accountId = accountGuid;
    }
    
    return self;
}

- (void)dealloc
{
    [self.accountId release];
    [self.username release];
    [self.password release];
    
    [super dealloc];
}

@end
