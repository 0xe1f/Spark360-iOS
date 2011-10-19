//
//  CFImageRetrievalOperation.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFImageCacheOperation : NSOperation
{
    NSString *url;
    NSString *outputFile;
    id notifyObj;
    SEL notifySel;
}

- (id)initWithURL:(NSString*)imageUrl
       outputFile:(NSString*)writeTo
     notifyObject:(id)notifyObject
   notifySelector:(SEL)notifySelector;

- (void)notifyDone;

@end
