//
//  CFImageCache.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCache2.h"

#pragma mark ImageCacheOperation

@interface ImageCacheOperation : NSOperation

- (id)initWithUrl:(NSString*)url
       outputFile:(NSString*)outputFile
         cropRect:(CGRect)rect;

@end

@implementation ImageCacheOperation
{
    NSString *_url;
    NSString *_outputFile;
    CGRect _cropRect;
}

- (id)initWithUrl:(NSString*)url
       outputFile:(NSString*)outputFile
         cropRect:(CGRect)cropRect
{
    if (self = [super init]) 
    {
        _url = [url copy];
        _outputFile = [outputFile copy];
        _cropRect = cropRect;
    }
    
    return self;
}

- (void)dealloc
{
    [_url release];
    [_outputFile release];
    
    [super dealloc];
}

- (void)main
{
    if ([self isCancelled])
        return;
    
    NSError *error = NULL;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_url]];
    
    if (data)
    {
        if (!CGRectIsNull(_cropRect))
        {
            UIImage *image = [UIImage imageWithData:data];
            
            if (image)
            {
                CGRect intersection = CGRectIntersection(_cropRect, 
                                                         CGRectMake(0, 0, image.size.width, image.size.height));
                
                if (!CGRectIsNull(intersection))
                {
                    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], intersection);
                    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    data = UIImagePNGRepresentation(cropped);
                }
            }
        }
        
        if (![data writeToFile:_outputFile 
                       options:NSDataWritingAtomic
                         error:&error])
        {
            NSLog(@"*** Error writing '%@' to '%@' to cache: %@", 
                  _url, _outputFile, error.localizedDescription);
        }
    }
    else
    {
        NSLog(@"** %@ is null", _url);
    }
    
// TODO
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageLoadedFromWeb"
                                                        object:self];
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

#pragma mark - ImageCache

@interface ImageCache (Private)

- (NSString*)cacheFilenameForUrl:(NSString*)url;
- (NSString*)cacheFilenameForUrl:(NSString*)url
                        cropRect:(CGRect)cropRect;

@end

@implementation ImageCache
{
    NSString *cacheDirectory;
    NSOperationQueue *opQueue;
    NSMutableDictionary *inMemCache;
    NSRegularExpression *filenameSanitizer;
}

static ImageCache *sharedInstance = nil;

- (id)init
{
    if (self = [super init]) 
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
        
        self->cacheDirectory = [[paths objectAtIndex:0] retain];
        self->opQueue = [[NSOperationQueue alloc] init];
        self->inMemCache = [[NSMutableDictionary alloc] init];
        self->filenameSanitizer = [[NSRegularExpression regularExpressionWithPattern:@"\\W" 
                                                                             options:0
                                                                               error:nil] retain];
    }
    
    return self;
}

-(void)dealloc
{
    [self->opQueue release];
    [self->inMemCache release];
    [self->cacheDirectory release];
    [self->filenameSanitizer release];
    
    [super dealloc];
}

#pragma mark - Private implementation

- (NSString*)cacheFilenameForUrl:(NSString*)url
{
    return [self cacheFilenameForUrl:url
                            cropRect:CGRectNull];
}

- (NSString*)cacheFilenameForUrl:(NSString*)url
                        cropRect:(CGRect)cropRect
{
    if (!url)
        return nil;
    
    NSString *cacheFile = [self->filenameSanitizer stringByReplacingMatchesInString:url
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

#pragma mark - Main

- (void)purgeInMemCache
{
    [self->inMemCache removeAllObjects];
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
            NSLog(@"Will not add %@ to queue - already queued", cacheFile);
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

#pragma mark - Singleton-related

// Get the shared instance and create it if necessary.
+ (ImageCache*)sharedInstance 
{
    if (sharedInstance == nil) 
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
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

@end