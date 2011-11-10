//
//  AccountAddController.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountAddController.h"

#import "BachAppDelegate.h"
#import "XboxAccount.h"

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
    // Save account object
    BachAppDelegate *bachApp = [BachAppDelegate sharedApp];
    
    NSManagedObjectContext *context = bachApp.managedObjectContext;
    
    self.account = [NSEntityDescription insertNewObjectForEntityForName:@"XboxAccount"
                                            inManagedObjectContext:context];
    
    self.account.emailAddress = self.emailAddress;
    self.account.password = self.password;
    
    XboxLiveParser *parser = [[[XboxLiveParser alloc] init] autorelease];
    [parser synchronizeProfileWithAccount:self.account
                      withRetrievedObject:profile];
    
    // TODO: Error?
    [[self.account managedObjectContext] save:nil];
    
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
    
    BachAppDelegate *bachApp = [BachAppDelegate sharedApp];
    
    NSManagedObjectContext *context = bachApp.managedObjectContext;
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:[NSEntityDescription entityForName:@"XboxAccount"
                                   inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(emailAddress = %@)", 
                           self.emailAddress]];
    
    NSArray *array = [context executeFetchRequest:request 
                                            error:nil];
    
    if ([array count] > 0)
    {
        // Account with that email address already exists
        
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