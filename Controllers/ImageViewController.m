/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
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
