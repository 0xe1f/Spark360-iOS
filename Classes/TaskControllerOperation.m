//
//  CFImageRetrievalOperation.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskControllerOperation.h"

@implementation TaskControllerOperation

@synthesize backgroundSelector = _backgroundSelector;
@synthesize identifier = _identifier;
@synthesize arguments = _arguments;
@synthesize selectorOwner = _selectorOwner;
@synthesize isNetworked;

- (id)initWithIdentifier:(NSString*)identifier
           selectorOwner:(id)selectorOwner
      backgroundSelector:(SEL)backgroundSelector
               arguments:(NSDictionary*)arguments
{
    if (self = [super init]) 
    {
        self.isNetworked = YES;
        self.identifier = identifier;
        self.selectorOwner = selectorOwner;
        self.backgroundSelector = backgroundSelector;
        self.arguments = arguments;
    }
    
    return self;
}

- (void)dealloc
{
    self.identifier = nil;
    self.selectorOwner = nil;
    self.backgroundSelector = nil;
    self.arguments = nil;
    
    [super dealloc];
}

- (void)toggleNetworkIndicator:(BOOL)isShowing
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = isShowing;
}

- (void)main
{
    if ([self isCancelled])
        return;
    
    [self.selectorOwner performSelector:self.backgroundSelector
                             withObject:self.arguments];
}

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[TaskControllerOperation class]])
        return NO;
    
    TaskControllerOperation *op = (TaskControllerOperation*)object;
    return [self.identifier isEqualToString:op.identifier];
}

-(NSUInteger)hash
{
    return [self.identifier hash];
}

@end
