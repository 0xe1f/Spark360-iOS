//
//  ImageViewController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"

#import "AKImageCache.h"

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

#pragma mark - GenericController

- (void)receivedImage:(NSString *)url 
            parameter:(id)parameter
{
    self.imageView.image = [self imageFromUrl:self.url
                                    parameter:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ImageViewer", nil);
    self.imageView.image = [self imageFromUrl:self.url
                                    parameter:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
