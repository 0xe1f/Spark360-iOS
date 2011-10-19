//
//  ICFParser.h
//  RandomPossessions
//
//  Created by Akop Karapetyan on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CFParser : NSObject {
}

- (NSString*)htmlDecode:(NSString*)str;

- (NSString*)loadWithMethod:(NSString*)method
                        url:(NSString*)url 
                     fields:(NSDictionary*)fields;
- (NSString*)loadWithGET:(NSString*)url 
                  fields:(NSDictionary*)fields;
- (NSString*)loadWithPOST:(NSString*)url 
                   fields:(NSDictionary*)fields;

@end
