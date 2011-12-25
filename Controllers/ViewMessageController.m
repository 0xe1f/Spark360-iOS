//
//  ViewMessageController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewMessageController.h"

@implementation ViewMessageController

@synthesize messageUid = _messageUid;

-(id)initWithUid:(NSString*)uid
         account:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"ViewMessageController"])
    {
        self.messageUid = uid;
    }
    
    return self;
}

-(void)dealloc
{
    self.messageUid = nil;
    
    [super dealloc];
}

/*
 [[TaskController sharedInstance] syncMessageWithUid:[message valueForKey:@"uid"]
 account:self.account
 managedObjectContext:managedObjectContext];
 */
@end
