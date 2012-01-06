//
//  CFImageCache.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AKImageCache.h"

NSString* const AKImageRetrieved = @"BachCacheImageRetrieved";

NSString* const AKImageUrl = @"url";
NSString* const AKImageRequestor = @"requestor";
NSString* const AKImageParameter = @"parameter";

#pragma mark ImageCacheOperation

@interface ImageCacheOp : NSOperation

- (id)initWithUrl:(NSString*)url
       outputFile:(NSString*)outputFile
         cropRect:(CGRect)rect
        requestor:(id)requestor
        parameter:(id)parameter;

@property (nonatomic, copy) NSString *outputFile;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, retain) id requestor;
@property (nonatomic, retain) id parameter;

@end

@implementation ImageCacheOp

@synthesize outputFile = _outputFile;
@synthesize url = _url;
@synthesize cropRect = _cropRect;
@synthesize requestor = _requestor;
@synthesize parameter = _parameter;

- (id)initWithUrl:(NSString*)url
       outputFile:(NSString*)outputFile
         cropRect:(CGRect)cropRect
        requestor:(id)requestor 
        parameter:(id)parameter
{
    if (self = [super init]) 
    {
        self.url = url;
        self.outputFile = outputFile;
        self.cropRect = cropRect;
        self.requestor = requestor;
        self.parameter = parameter;
    }
    
    return self;
}

- (void)dealloc
{
    self.url = nil;
    self.outputFile = nil;
    self.requestor = nil;
    self.parameter = nil;
    
    [super dealloc];
}

- (void)main
{
    if ([self isCancelled])
        return;
    
    NSError *error = NULL;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.url]];
    
    if (!data)
    {
        NSLog(@"** %@ is null", self.url);
        return;
    }
    
    if (!CGRectIsNull(self.cropRect))
    {
        UIImage *image = [UIImage imageWithData:data];
        
        if (image)
        {
            CGRect intersection = CGRectIntersection(self.cropRect, 
                                                     CGRectMake(0, 0, 
                                                                image.size.width, 
                                                                image.size.height));
            
            if (!CGRectIsNull(intersection))
            {
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], intersection);
                UIImage *cropped = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                
                data = UIImagePNGRepresentation(cropped);
            }
        }
    }
    
    if (![data writeToFile:self.outputFile 
                   options:NSDataWritingAtomic
                     error:&error])
    {
        NSLog(@"*** Error writing '%@' to '%@' to cache: %@", 
              self.url, self.outputFile, error.localizedDescription);
        
        return;
    }
    
    [self performSelectorOnMainThread:@selector(postNotification:) 
                           withObject:nil
                        waitUntilDone:YES];
}

- (void)postNotification:(id)args
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AKImageRetrieved
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                self.url, AKImageUrl,
                                                                self.requestor, AKImageRequestor,
                                                                self.parameter, AKImageParameter,
                                                                nil]];
}

@end

#pragma mark - ImageCache

@interface AKImageCache (Private)

- (NSString*)cacheFilenameForUrl:(NSString*)url;
- (NSString*)cacheFilenameForUrl:(NSString*)url
                        cropRect:(CGRect)cropRect;

@end

@implementation AKImageCache
{
    NSString *cacheDirectory;
    NSOperationQueue *opQueue;
    NSMutableDictionary *inMemCache;
    NSRegularExpression *filenameSanitizer;
}

static AKImageCache *sharedInstance = nil;

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

- (UIImage*)imageFromUrl:(NSString*)url
               requestor:(id)requestor
               parameter:(id)parameter
{
    return [self imageFromUrl:url
                     cropRect:CGRectNull
                    requestor:requestor
                    parameter:parameter];
}

- (UIImage*)imageFromUrl:(NSString*)url
                cropRect:(CGRect)cropRect
               requestor:(id)requestor
               parameter:(id)parameter
{
    if (!url)
        return nil;
    
    NSString *cacheFile = [self cacheFilenameForUrl:url
                                           cropRect:cropRect];
    
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
    
    // Load from network
    
    // Make sure we're not already queued
    NSArray *operations = [self->opQueue operations];
    for (ImageCacheOp *op in operations) 
    {
        if ([op.outputFile isEqualToString:cacheFile])
        {
            NSLog(@"Will not add %@ to queue - already queued", cacheFile);
            return nil;
        }
    }
    
    // Create a caching op and add it to queue
    NSOperation *op = [[ImageCacheOp alloc] initWithUrl:url
                                             outputFile:cacheFile
                                               cropRect:cropRect
                                              requestor:requestor
                                              parameter:parameter];
    
    [self->opQueue addOperation:op];
    [op release];
    
    return nil;
}

#pragma mark - Singleton-related

// Get the shared instance and create it if necessary.
+ (AKImageCache*)sharedInstance 
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