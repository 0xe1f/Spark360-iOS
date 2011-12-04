//
//  CFImageRetrievalOperation.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFImageCacheOperation.h"

@implementation CFImageCacheOperation

- (id)initWithURL:(NSString*)imageUrl
       outputFile:(NSString*)writeTo
     notifyObject:(id)notifyObject
   notifySelector:(SEL)notifySelector
{
    if (self = [super init]) 
    {
        self->url = [imageUrl copy];
        self->outputFile = [writeTo copy];
        self->notifyObj = [notifyObject retain];
        self->notifySel = notifySelector;
    }
    
    return self;
}

- (void)dealloc
{
    [self->url release];
    [self->outputFile release];
    [self->notifyObj release];
    
    [super dealloc];
}

- (void)main
{
    if ([self isCancelled])
        return;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self->url]];
    
    [data writeToFile:self->outputFile 
           atomically:YES];
    
#ifdef CF_LOGV
    NSLog(@"Downloaded %@ to %@", self->url, self->outputFile);
#endif
    
    if (![self isCancelled])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageLoadedFromWeb"
                                                            object:self];
    }
}

- (void)notifyDone
{
    if (self->notifySel != nil && self->notifyObj != nil)
    {
        [self->notifyObj performSelector:self->notifySel 
                              withObject:self->url];
    }
}
@end
