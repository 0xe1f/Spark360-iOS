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
