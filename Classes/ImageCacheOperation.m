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
