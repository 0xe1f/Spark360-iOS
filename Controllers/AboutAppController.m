//
//  AboutAppController.m
//  BachZero
//
//  Created by Akop Karapetyan on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AboutAppController.h"

@implementation AboutAppController

@synthesize versionLabel;
@synthesize disclaimerView;

-(id)initAbout
{
    if (self = [super initWithNibName:@"AboutAppController"
                               bundle:nil])
    {
        
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"About", nil);
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    self.versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VersionNo_f", nil), 
                              [infoDict objectForKey:@"CFBundleVersion"]];
    self.disclaimerView.text = NSLocalizedString(@"Disclaimer", nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
