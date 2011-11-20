//
//  AccountAddController.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
    self.account.screenName = [profile objectForKey:@"screenName"];
    [self.account save];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:context];
    [parser synchronizeProfileWithAccount:self.account
                      withRetrievedObject:profile
                                    error:nil];
    [parser autorelease];
    
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
