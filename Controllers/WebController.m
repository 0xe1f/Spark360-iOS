/*
 * Spark 360 for iOS
 * https://github.com/Melllvar/Spark360-iOS
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

    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.pageTitle;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

@end
