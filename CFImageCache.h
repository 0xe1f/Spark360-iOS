//
//  CFImageCache.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFImageCache : NSObject
{
    NSString *cacheDirectory;
    NSOperationQueue *opQueue;
    NSMutableDictionary *inMemCache;
}

+ (id)sharedInstance;

- (void)purgeInMemCache;
- (NSString*)cacheFilenameForUrl:(NSString*)url;
- (UIImage*)getCachedFile:(NSString*)url
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;

@end
