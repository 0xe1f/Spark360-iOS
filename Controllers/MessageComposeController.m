//
//  MessageComposeController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageComposeController.h"

@implementation MessageComposeController

@synthesize recipients = _recipients;

-(id)initWithRecipient:(id)recipients
               account:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"MessageCompose"])
    {
        _recipients = [[NSMutableArray alloc] init];
        
        if (recipients)
        {
            if ([recipients isKindOfClass:[NSArray class]])
                [self.recipients addObjectsFromArray:recipients];
            else
                [self.recipients addObject:(NSString*)recipients];
        }
    }
    
    return self;
}

-(void)dealloc
{
    self.recipients = nil;
    
    [super dealloc];
}

@end
