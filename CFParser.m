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

#define TIMEOUT_SECONDS 30

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
                        url:(NSString*)requestUrl
                     fields:(NSDictionary*)fields
{
    NSString *httpBody = nil;
    NSURL *url = [NSURL URLWithString:requestUrl];
    
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
    
    NSUInteger bodyLength = [httpBody lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"text/javascript, text/html, application/xml, text/xml, */*", @"Accept",
                             @"ISO-8859-1,utf-8;q=0.7,*;q=0.7", @"Accept-Charset",
                             [NSString stringWithFormat:@"%d", bodyLength], @"Content-Length",
                             @"application/x-www-form-urlencoded", @"Content-Type",
                             nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:TIMEOUT_SECONDS];
    
    [request setHTTPMethod:method];
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (!data)
    {
        if (error)
        {
            // TODO
            // NSLog(@"ERROR: %@", [error localizedDescription]);
        }
        
        return nil;
    }
    
    return [[[NSString alloc] initWithData:data 
                                  encoding:NSUTF8StringEncoding] autorelease];
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
