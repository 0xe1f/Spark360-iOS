//
//  ImageViewController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"

#import "ImageCache.h"

@implementation ImageViewController

@synthesize url = _url;
@synthesize imageView = _imageView;

-(id)initWithUrl:(NSString*)url
{
    if ((self = [super initWithAccount:nil
                               nibName:@"ImageViewController"]))
    {
        self.url = url;
    }
    
    return self;
}

-(void)dealloc
{
    self.url = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ImageViewer", nil);
    self.imageView.image = [[ImageCache sharedInstance] getCachedFile:self.url
                                                         notifyObject:self
                                                       notifySelector:@selector(imageLoaded:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Notifications

- (void)imageLoaded:(NSString*)imageUrl
{
    self.imageView.image = [[ImageCache sharedInstance] getCachedFile:self.url
                                                         notifyObject:nil
                                                       notifySelector:nil];
}

@end
