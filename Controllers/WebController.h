//
//  WebController.h
//  BachZero
//
//  Created by Akop Karapetyan on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericController.h"

@interface WebController : GenericController

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, copy) NSString *pageTitle;

-(id)initWithUrl:(NSURL*)url
       pageTitle:(NSString*)pageTitle
         account:(XboxLiveAccount*)account;

@end
