//
//  WebController.m
//  BachZero
//
//  Created by Akop Karapetyan on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebController.h"

@implementation WebController

@synthesize url = _url;
@synthesize pageTitle = _pageTitle;

@synthesize webView;

-(id)initWithUrl:(NSURL*)url
       pageTitle:(NSString*)pageTitle
         account:(XboxLiveAccount*)account;
{
    if ((self = [super initWithAccount:account
                               nibName:@"WebController"]))
    {
        self.url = url;
        self.pageTitle = pageTitle;
    }
    
    return self;
}

-(void)dealloc
{
    self.url = nil;
    self.pageTitle = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.pageTitle;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

@end
