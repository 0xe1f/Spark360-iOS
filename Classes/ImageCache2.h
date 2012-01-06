//
//  CFImageCache.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+ (id)sharedInstance;

- (void)purgeInMemCache;

- (BOOL)hasLocalCopyOfUrl:(NSString*)url;
- (BOOL)hasLocalCopyOfUrl:(NSString*)url
                 cropRect:(CGRect)cropRect;

- (UIImage*)getCachedFile:(NSString*)url;
- (UIImage*)getCachedFile:(NSString*)url
                 cropRect:(CGRect)rect;

@end
