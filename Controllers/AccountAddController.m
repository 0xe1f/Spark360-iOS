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

#import "AccountAddController.h"

#import "BachAppDelegate.h"
#import "AppPreferences.h"
#import "XboxLiveParser.h"

@interface AccountAddController (PrivateMethods)

@end

@implementation AccountAddController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"AddAccount", nil);
    
    self.emailAddress = @"";
    self.password = @"";
}

#pragma mark etc

-(void)validationSucceeded:(NSDictionary*)profile
{
    BachAppDelegate *bachApp = [BachAppDelegate sharedApp];
    NSManagedObjectContext *context = bachApp.managedObjectContext;
    
    self.account = [AppPreferences createAndAddAccount];
    self.account.emailAddress = self.emailAddress;
    self.account.password = self.password;
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:context];
    [parser writeProfileOfAccount:self.account
              withRetrievedObject:profile
                            error:nil];
    [parser release];
    
    // TODO: Error?
    
    [savingIndicator stopAnimating];
    [savingIndicator setHidden:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    saveButton.enabled = YES;
    [self.navigationItem setHidesBackButton:NO 
                                   animated:NO];
}

-(void)validateFields 
{
    self.emailAddress = usernameTextField.text;
    self.password = passwordTextField.text;
    
    XboxLiveAccount *matchingAccount = [AppPreferences findAccountWithEmailAddress:self.emailAddress];
    
    if (matchingAccount)
    {
        // An account already exists
        
        [self validationFailed:NSLocalizedString(@"AnAccountAlreadyExists", @"")];
        return;
    }
    
    saveButton.enabled = NO;
    [self.navigationItem  setHidesBackButton:YES
                                    animated:NO];
    
    [self performSelectorInBackground:@selector(authenticate) 
                           withObject:nil];
}

@end
