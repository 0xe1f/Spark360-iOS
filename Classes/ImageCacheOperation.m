//
//  CFImageRetrievalOperation.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCacheOperation.h"

@implementation ImageCacheOperation

@synthesize outputFile;

- (id)initWithURL:(NSString*)imageUrl
       outputFile:(NSString*)writeTo
     notifyObject:(id)notifyObject
   notifySelector:(SEL)notifySelector
         cropRect:(CGRect)rect
{
    if (self = [super init]) 
    {
        self->url = [imageUrl copy];
        self.outputFile = writeTo;
        self->notifyObj = [notifyObject retain];
        self->notifySel = notifySelector;
        self->cropRect = rect;
    }
    
    return self;
}

- (void)dealloc
{
    [self->url release];
    [self->notifyObj release];
    
    self.outputFile = nil;
    
    [super dealloc];
}

- (void)main
{
    if ([self isCancelled])
        return;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self->url]];
    
    if ([self isCancelled])
        return;
    
    if (data)
    {
        if (!CGRectIsNull(self->cropRect))
        {
            UIImage *image = [UIImage imageWithData:data];
            
            if (image)
            {
                CGRect intersection = CGRectIntersection(self->cropRect, 
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
        
        NSError *error = NULL;
        
        if (![data writeToFile:self.outputFile 
                       options:NSDataWritingAtomic
                         error:&error])
        {
            BACHLog(@"*** Error writing '%@' to '%@' to cache: %@", 
                    self->url, self.outputFile, error.localizedDescription);
        }
    }
    else
    {
        BACHLog(@"** %@ is null", self->url);
    }
    
    BACHLog(@"Downloaded %@ to %@", self->url, self->outputFile);
    
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
