//
//  AccountAddController.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountEditController.h"

#import "BachAppDelegate.h"
#import "AppPreferences.h"
#import "XboxLiveParser.h"

@implementation AccountEditController

@synthesize usernameCell = _usernameCell;
@synthesize passwordCell = _passwordCell;
@synthesize tableView = _tableView;
@synthesize password, emailAddress;
@synthesize account;

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                               target:self 
                                                               action:@selector(save:)];
    
    if (account)
    {
        self.emailAddress = account.emailAddress;
        self.password = account.password;
    }
    
    self.navigationItem.title = NSLocalizedString(@"EditAccount", nil);
    self.navigationItem.rightBarButtonItem = saveButton;	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.usernameCell = nil;
    self.passwordCell = nil;
    self.tableView = nil;
    
    [saveButton release]; 
    [usernameTextField release];
    [passwordTextField release]; 
    [savingIndicator release];
    [account release];
    
    [super dealloc];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
    switch (section) 
    {
		case 0:
            return 2;
		default:
            return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([indexPath section] == 0) 
    {
        if(indexPath.row == 0) 
        {
            self.usernameCell = (UITableViewTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:@"UsernameCell"];
            
            if (self.usernameCell == nil) 
            {
                self.usernameCell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                     reuseIdentifier:@"UsernameCell"] autorelease];
				self.usernameCell.textLabel.text = NSLocalizedString(@"Username", @"");
                
				usernameTextField = [self.usernameCell.textField retain];
				usernameTextField.placeholder = NSLocalizedString(@"XboxLiveUsername", @"");
				usernameTextField.keyboardType = UIKeyboardTypeDefault;
				usernameTextField.returnKeyType = UIReturnKeyNext;
                usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                usernameTextField.delegate = self;
                [usernameTextField becomeFirstResponder];
                
                usernameTextField.text = self.emailAddress;
			}
            
            return self.usernameCell;
        }
        else if(indexPath.row == 1) 
        {
            self.passwordCell = (UITableViewTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:@"PasswordCell"];
            if (self.passwordCell == nil) 
            {
                self.passwordCell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                     reuseIdentifier:@"PasswordCell"] autorelease];
				self.passwordCell.textLabel.text = NSLocalizedString(@"Password", @"");
                
				passwordTextField = [self.passwordCell.textField retain];
				passwordTextField.placeholder = NSLocalizedString(@"XboxLivePassword", @"");
				passwordTextField.keyboardType = UIKeyboardTypeDefault;
				passwordTextField.secureTextEntry = YES;
                passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                passwordTextField.delegate = self;
                
                passwordTextField.text = self.password;
			}
            return self.passwordCell;
        }
    }
    
    // We shouldn't reach this point, but return an empty cell just in case
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoCell"] autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) 
    {
        case 0:
            return NSLocalizedString(@"LoginInfo", nil);
		default:
            return nil;
	}
}

#pragma mark UITextField methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    if (textField.returnKeyType == UIReturnKeyNext) 
    {
        UITableViewCell *cell = (UITableViewCell *)[textField superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) 
                                                        inSection:indexPath.section];
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
        
        if (nextCell) 
        {
            for (UIView *subview in [nextCell subviews]) 
            {
                if ([subview isKindOfClass:[UITextField class]]) 
                {
                    [subview becomeFirstResponder];
                    break;
                }
            }
        }
    }
    
	[textField resignFirstResponder];
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string 
{
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    NSMutableString *result = [NSMutableString stringWithString:textField.text];
    
    [result replaceCharactersInRange:range 
                          withString:string];
    
    cell.textLabel.textColor = ([result length] == 0) ? WRONG_FIELD_COLOR : GOOD_FIELD_COLOR;        
    
    return YES;
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark etc

- (void)save:(id)sender 
{
    [usernameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
	
	if (savingIndicator == nil) 
    {
		savingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
		[savingIndicator setFrame:CGRectMake(0,0,20,20)];
		[savingIndicator setCenter:CGPointMake(self.tableView.center.x, savingIndicator.center.y)];
		
        UIView *aView = [[UIView alloc] init];
		[aView addSubview:savingIndicator];
		
		[self.tableView setTableFooterView:aView];
        [aView release];
	}
    
	[savingIndicator setHidden:NO];
	[savingIndicator startAnimating];
    
    BOOL validFields = YES;
    
    if ([usernameTextField.text isEqualToString:@""]) 
    {
        validFields = NO;
        self.usernameCell.textLabel.textColor = WRONG_FIELD_COLOR;
    }
    if ([passwordTextField.text isEqualToString:@""]) 
    {
        validFields = NO;
        self.passwordCell.textLabel.textColor = WRONG_FIELD_COLOR;
    }
    
    if (!validFields)
    {
        [self validationFailed:NSLocalizedString(@"ProvideValidUsernameAndPassword", @"")];
        return;
    }
    
    [self validateFields];
}

-(void)validateFields 
{
    if ([account.emailAddress isEqualToString:usernameTextField.text]
        && [account.password isEqualToString:passwordTextField.text]) 
    {
        // Nothing's changed
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    self.emailAddress = usernameTextField.text;
    self.password = passwordTextField.text;
    
    XboxLiveAccount *matchingAccount = [AppPreferences findAccountWithEmailAddress:self.emailAddress];
    
    if (matchingAccount && ![matchingAccount isEqualToAccount:account])
    {
        [self validationFailed:NSLocalizedString(@"AnAccountAlreadyExists", @"")];
        return;
    }
    
    saveButton.enabled = NO;
    [self.navigationItem  setHidesBackButton:YES
                                    animated:NO];
    
    [self performSelectorInBackground:@selector(authenticate) 
                           withObject:nil];
}

-(void)authenticate
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSError *error = nil;
    XboxLiveParser *parser = [[[XboxLiveParser alloc] init] autorelease];
    BOOL success = [parser authenticate:self.emailAddress
                           withPassword:self.password
                                  error:&error];
    
    NSString *errorMessage = nil;
    NSDictionary *profile = nil;
    
    if (!success)
    {
        if (error && [error code] != XBLPAuthenticationError)
            errorMessage = [error localizedDescription]; // Non-authentication error
        else
            errorMessage = NSLocalizedString(@"VerifyUsernameAndPassword", nil);
    }
    else
    {
        profile = [parser retrieveProfileWithEmailAddress:self.emailAddress
                                                 password:self.password
                                                    error:&error];
        
        if (!profile)
        {
            success = false;
            errorMessage = NSLocalizedString(@"UnableToRetrieveProfile", @"");
        }
    }
    
    if (success)
    {
        [self performSelectorOnMainThread:@selector(validationSucceeded:) 
                               withObject:profile
                            waitUntilDone:NO];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(validationFailed:) 
                               withObject:errorMessage
                            waitUntilDone:NO];
    }
    
    [pool release];
}

-(void)validationSucceeded:(NSDictionary*)profile
{
    BachAppDelegate *bachApp = [BachAppDelegate sharedApp];
    NSManagedObjectContext *context = bachApp.managedObjectContext;
    
    account.emailAddress = self.emailAddress;
    account.password = self.password;
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:context];
    [parser synchronizeProfileWithAccount:account
                      withRetrievedObject:profile
                                    error:nil];
    [parser release];
    
    [savingIndicator stopAnimating];
    [savingIndicator setHidden:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    saveButton.enabled = YES;
    [self.navigationItem setHidesBackButton:NO 
                                   animated:NO];
}

-(void)validationFailed:(NSString*)message
{
    [savingIndicator stopAnimating];
    [savingIndicator setHidden:YES];
    
    self.emailAddress = nil;
    self.password = nil;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFailed", @"") 
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
    
    saveButton.enabled = YES;
    [self.navigationItem setHidesBackButton:NO 
                                   animated:NO];
}

@end
