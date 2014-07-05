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

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
{
    NSString *cacheDirectory;
    NSOperationQueue *opQueue;
    NSMutableDictionary *inMemCache;
}

@property (nonatomic, retain) NSRegularExpression *filenameSanitizer;

+ (id)sharedInstance;

- (void)purgeInMemCache;
- (BOOL)hasLocalCopyOfUrl:(NSString*)url;
- (BOOL)hasLocalCopyOfUrl:(NSString*)url
                 cropRect:(CGRect)cropRect;
- (NSString*)cacheFilenameForUrl:(NSString*)url
                        cropRect:(CGRect)cropRect;
- (NSString*)cacheFilenameForUrl:(NSString*)url;
- (UIImage*)getCachedFile:(NSString*)url
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;
- (UIImage*)getCachedFile:(NSString*)url
                 cropRect:(CGRect)rect
             notifyObject:(id)notifyObject
           notifySelector:(SEL)notifySelector;

@end
