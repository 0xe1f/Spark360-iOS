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

@property (nonatomic, retain) NSRegularExpression *filenameSanitizer;

+ (id)sharedInstance;

- (void)purgeInMemCache;
- (NSString*)cacheFilenameForUrl:(NSString*)url
                        cropRect:(CGRect)cropRect;
- (UIImage*)getCachedFile:(NSString*)url
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;
- (UIImage*)getCachedFile:(NSString*)url
                 cropRect:(CGRect)rect
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;

@end
