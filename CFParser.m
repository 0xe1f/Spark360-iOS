//
//  ICFParser.m
//  RandomPossessions
//
//  Created by Akop Karapetyan on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CFParser.h"
#import "GTMNSString+HTML.h"

@implementation CFParser

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString*)htmlDecode:(NSString*)str
{
    return [str gtm_stringByUnescapingFromHTML];
}

- (NSString*)loadWithMethod:(NSString*)method
                        url:(NSString*)url 
                     fields:(NSDictionary*)fields
{
    NSString *httpBody = nil;
    
    // TODO: timeouts
    
    if (fields)
    {
        NSMutableArray *urlBuilder = [[NSMutableArray alloc] init];
        
        for (NSString *key in fields)
        {
            NSString *ueKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *ueValue = [[fields objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [urlBuilder addObject:[NSString stringWithFormat:@"%@=%@", ueKey, ueValue]];
        }
        
        httpBody = [urlBuilder componentsJoinedByString:@"&"];
        [urlBuilder release];
    }
    
    NSURL *webServiceURL = [NSURL URLWithString:url];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:webServiceURL];
    
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setValue:[NSString stringWithFormat:@"%d",
                          [httpBody lengthOfBytesUsingEncoding:NSUTF8StringEncoding]] 
      forHTTPHeaderField:@"Content-Length"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:&response
                                                     error:&error];
    
    if (!data)
    {
        // TODO: error!
        if (error)
        {
            // TODO: which?
        }
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString*)loadWithGET:(NSString*)url 
                  fields:(NSDictionary*)fields
{
    return [self loadWithMethod:@"GET"
                            url:url
                         fields:fields];
}

- (NSString*)loadWithPOST:(NSString*)url 
                   fields:(NSDictionary*)fields
{
    return [self loadWithMethod:@"POST"
                            url:url
                         fields:fields];
}

+ (NSString*)getSingleMatch:(NSRegularExpression*)regex
                   inString:(NSString*)inString
               captureGroup:(NSUInteger)captureGroup
{
    NSTextCheckingResult *match = [regex 
                                   firstMatchInString:inString
                                   options:0
                                   range:NSMakeRange(0, [inString length])];
    
    if (!match)
        return nil;
    
    return [inString substringWithRange:[match rangeAtIndex:captureGroup]];
}

@end
