//
//  CFImageRetrievalOperation.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCacheOperation : NSOperation
{
    NSString *url;
    id notifyObj;
    SEL notifySel;
    CGRect cropRect;
}

@property (nonatomic, retain) NSString *outputFile;

- (id)initWithURL:(NSString*)imageUrl
       outputFile:(NSString*)writeTo
     notifyObject:(id)notifyObject
   notifySelector:(SEL)notifySelector
         cropRect:(CGRect)rect;

- (void)notifyDone;

@end
