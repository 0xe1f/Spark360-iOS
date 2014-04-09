/*
 * Spark 360 for iOS
 * https://github.com/Melllvar/Spark360-iOS
 *
 * Copyright (C) 2011-2014 Akop Karapetyan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

#import "ImageCache.h"

#import "ImageCacheOperation.h"

@implementation ImageCache

@synthesize filenameSanitizer;

static ImageCache *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (ImageCache*)sharedInstance 
{
    if (sharedInstance == nil) 
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    if (self = [super init]) 
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
        
        self->cacheDirectory = [[paths objectAtIndex:0] retain];
        self->inMemCache = [[NSMutableDictionary alloc] init];
        
        self.filenameSanitizer = [NSRegularExpression regularExpressionWithPattern:@"\\W" 
                                                                           options:0
                                                                             error:nil];
        
        self->opQueue = [[NSOperationQueue alloc] init];
        [self->opQueue setMaxConcurrentOperationCount:2];
    }
    
    return self;
}

// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    [self->opQueue release];
    [self->inMemCache release];
    [self->cacheDirectory release];
    
    self.filenameSanitizer = nil;
    
    // I'm never called!
    [super dealloc];
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone 
{
    return [[self sharedInstance] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone 
{
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain 
{
    return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount 
{
    return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
- (oneway void)release 
{
    
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease 
{
    return self;
}

#pragma mark Caching

- (NSString*)cacheFilenameForUrl:(NSString*)url
{
    return [self cacheFilenameForUrl:url
                            cropRect:CGRectNull];
}

- (NSString*)cacheFilenameForUrl:(NSString*)url
                        cropRect:(CGRect)cropRect
{
    if (url == nil)
        return nil;
    
    NSString *cacheFile = [self.filenameSanitizer stringByReplacingMatchesInString:url
                                                                           options:0
                                                                             range:NSMakeRange(0, [url length])
                                                                      withTemplate:@"_"];
    
    if (!CGRectIsNull(cropRect))
    {
        cacheFile = [cacheFile stringByAppendingFormat:@"@%i,%i-%ix%i", 
                     (int)cropRect.origin.x, (int)cropRect.origin.y, 
                     (int)cropRect.size.width, (int)cropRect.size.height];
    }
    
    return [cacheDirectory stringByAppendingPathComponent:cacheFile];
}

- (BOOL)hasLocalCopyOfUrl:(NSString*)url
{
    return [self hasLocalCopyOfUrl:url 
                          cropRect:CGRectNull];
}

- (BOOL)hasLocalCopyOfUrl:(NSString*)url
                 cropRect:(CGRect)cropRect
{
    NSString *cacheFile = [self cacheFilenameForUrl:url
                                           cropRect:cropRect];
    
    if ([inMemCache valueForKey:cacheFile])
        return YES;
    
    return [[NSFileManager defaultManager] fileExistsAtPath:cacheFile];
}

- (UIImage*)getCachedFile:(NSString*)url
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;
{
    return [self getCachedFile:url
                      cropRect:CGRectNull
                  notifyObject:notifyObject
                notifySelector:notifySelector];
}

- (UIImage*)getCachedFile:(NSString*)url
                 cropRect:(CGRect)rect
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;
{
    if (!url)
        return nil;
    
    NSString *cacheFile = [self cacheFilenameForUrl:url
                                           cropRect:rect];
    
    // Try the in-memory cache
    UIImage *image;
    if ((image = [inMemCache valueForKey:cacheFile]))
        return image;
    
    // Try loading from storage
    if ((image = [UIImage imageWithData:[NSData dataWithContentsOfFile:cacheFile]]))
    {
        [inMemCache setValue:image
                      forKey:cacheFile];
        
        return image;
    }
    
    if (!notifyObject || !notifySelector)
        return nil;
    
    // Load from network
    
    // Make sure we're not already queued
    NSArray *operations = [self->opQueue operations];
    for (ImageCacheOperation *op in operations) 
    {
        if ([op.outputFile isEqualToString:cacheFile])
        {
            BACHLog(@"Will not add %@ to queue - already queued", cacheFile);
            return nil;
        }
    }
    
    // Create a caching op and add it to queue
    NSOperation *op = [[ImageCacheOperation alloc] initWithURL:url
                                                    outputFile:cacheFile
                                                  notifyObject:notifyObject
                                                notifySelector:notifySelector
                                                      cropRect:rect];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(operationFinished:) 
                                                 name:@"ImageLoadedFromWeb"
                                               object:op];
    
    [self->opQueue addOperation:op];
    [op release];
    
    return nil;
}

- (void)operationFinished:(NSNotification*)n
{
    [self performSelectorOnMainThread:@selector(imageLoaded:)
                           withObject:[n object]
                        waitUntilDone:NO];
}

- (void)imageLoaded:(ImageCacheOperation*)op
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ImageLoadedFromWeb"
                                                  object:op];
    
    [op notifyDone];
}

- (void)purgeInMemCache
{
    [self->inMemCache removeAllObjects];
}

@end