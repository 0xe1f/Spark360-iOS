/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
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

#import "AKImageCache.h"

NSString* const AKImageRetrieved = @"BachCacheImageRetrieved";

NSString* const AKImageUrl = @"url";
NSString* const AKImageRequestor = @"requestor";
NSString* const AKImageParameter = @"parameter";

NSString* const AKInternalImageLoaded = @"AKICImageLoaded";
NSString* const AKInternalOutputFile = @"outputFile";
NSString* const AKInternalImageData = @"imageData";

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
        BACHLog(@"** %@ is null", self.url);
        return;
    }
    
    id blob = data;
    
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
                blob = cropped;
            }
        }
    }
    
    if (![data writeToFile:self.outputFile 
                   options:NSDataWritingAtomic
                     error:&error])
    {
        BACHLog(@"*** Error writing '%@' to '%@' to cache: %@", 
                self.url, self.outputFile, error.localizedDescription);
        
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AKInternalImageLoaded
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                self.outputFile, AKInternalOutputFile,
                                                                blob, AKInternalImageData,
                                                                nil]];
    
    [self performSelectorOnMainThread:@selector(postNotification:) 
                           withObject:nil
                        waitUntilDone:NO];
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
        self->inMemCache = [[NSMutableDictionary alloc] init];
        self->filenameSanitizer = [[NSRegularExpression regularExpressionWithPattern:@"\\W" 
                                                                             options:0
                                                                               error:nil] retain];
        
        self->opQueue = [[NSOperationQueue alloc] init];
        [self->opQueue setMaxConcurrentOperationCount:2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onImageLoaded:)
                                                     name:AKInternalImageLoaded
                                                   object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self->opQueue release];
    [self->inMemCache release];
    [self->cacheDirectory release];
    [self->filenameSanitizer release];
    
    [super dealloc];
}

#pragma mark - Private implementation

-(void)onImageLoaded:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *outputFile = [userInfo objectForKey:AKInternalOutputFile];
    id imageBlob = [userInfo objectForKey:AKInternalImageData];
    
    UIImage *image = nil;
    if ([imageBlob isKindOfClass:[NSData class]])
        image = [UIImage imageWithData:imageBlob]; // raw image data
    else if ([imageBlob isKindOfClass:[UIImage class]])
        image = imageBlob; // actual image
    
    if (image)
        [inMemCache setValue:image forKey:outputFile];
}

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
    id image = [inMemCache valueForKey:cacheFile];
    if (image != nil)
    {
        if (image == [NSNull null])
            return nil; // It's being fetched
        
        return image; // We have it now
    }
    
    // Try loading from storage
    if ((image = [UIImage imageWithData:[NSData dataWithContentsOfFile:cacheFile]]))
    {
        [inMemCache setValue:image forKey:cacheFile];
        
        return image;
    }
    
    // Load from network - add a placeholder to prevent dup. requests
    [inMemCache setValue:[NSNull null] forKey:cacheFile];
    
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