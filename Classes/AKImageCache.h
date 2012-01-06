//
//  CFImageCache.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const AKImageRetrieved;

extern NSString* const AKImageUrl;
extern NSString* const AKImageRequestor;
extern NSString* const AKImageParameter;

@interface AKImageCache : NSObject

+ (id)sharedInstance;

- (void)purgeInMemCache;

- (BOOL)hasLocalCopyOfUrl:(NSString*)url;
- (BOOL)hasLocalCopyOfUrl:(NSString*)url
                 cropRect:(CGRect)cropRect;

- (UIImage*)imageFromUrl:(NSString*)url
               requestor:(id)requestor
               parameter:(id)parameter;
- (UIImage*)imageFromUrl:(NSString*)url
                cropRect:(CGRect)rect
               requestor:(id)requestor
               parameter:(id)parameter;

@end
