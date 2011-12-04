//
//  CFImageCache.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFImageCache.h"

#import "CFImageCacheOperation.h"

@implementation CFImageCache

static CFImageCache *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (CFImageCache*)sharedInstance 
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
        self->opQueue = [[NSOperationQueue alloc] init];
        self->inMemCache = [[NSMutableDictionary alloc] init];
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
    if (url == nil)
        return nil;
    
    NSError *error = NULL;
    
	NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:@"\\W" 
                                              options:NSRegularExpressionCaseInsensitive 
                                                error:&error];
    
    NSString *cacheFile = [regex stringByReplacingMatchesInString:url
                                                          options:0
                                                            range:NSMakeRange(0, [url length])
                                                     withTemplate:@"_"];
    
    return [cacheDirectory stringByAppendingPathComponent:cacheFile];
}

- (UIImage*)getCachedFile:(NSString*)url
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;
{
    // TODO: what if files are already in queue?
    
    UIImage *image;
    if ((image = [inMemCache valueForKey:url]) != nil)
        return image;
    
    NSString *cacheFile = [self cacheFilenameForUrl:url];
    image = [UIImage imageWithData:[NSData dataWithContentsOfFile:cacheFile]];
    
    if (image == nil)
    {
#ifdef CF_LOGV
        NSLog(@"Added %@ to fetch queue", url);
#endif
        NSOperation *op = [[CFImageCacheOperation alloc] initWithURL:url
                                                          outputFile:cacheFile
                                                        notifyObject:notifyObject
                                                      notifySelector:notifySelector];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(operationFinished:) 
                                                     name:@"ImageLoadedFromWeb"
                                                   object:op];
        
        [self->opQueue addOperation:op];
        [op release];
    }
    else
    {
        [inMemCache setValue:image
                      forKey:url];
        
#ifdef CF_LOGV
        NSLog(@"Returning %@ from cache (%d in memory)", url, [inMemCache count]);
#endif
    }
    
    return image;
}

- (void)operationFinished:(NSNotification*)n
{
    [self performSelectorOnMainThread:@selector(imageLoaded:)
                           withObject:[n object]
                        waitUntilDone:NO];
}

- (void)imageLoaded:(CFImageCacheOperation*)op
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:@"ImageLoadedFromWeb"
     object:op];
    
    [op notifyDone];
}

- (void)purgeInMemCache
{
    [self->inMemCache removeAllObjects];
}

@end