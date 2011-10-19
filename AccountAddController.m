//
//  AccountAddController.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountAddController.h"

@implementation AccountAddController

@synthesize usernameCell = _usernameCell;
@synthesize passwordCell = _passwordCell;
@synthesize tableView = _tableView;

#define WRONG_FIELD_COLOR [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0]
#define GOOD_FIELD_COLOR [UIColor blackColor]

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
    {
        // Custom initialization
    }
    return self;
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
    saveButton = nil;
    [usernameTextField release];
    usernameTextField = nil;
    [passwordTextField release]; 
    passwordTextField = nil;
    
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
                self.usernameCell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UsernameCell"] autorelease];
                
				self.usernameCell.textLabel.text = NSLocalizedString(@"Username", @"");
				usernameTextField = [self.usernameCell.textField retain];
				usernameTextField.placeholder = NSLocalizedString(@"XboxLiveUsername", @"");
				usernameTextField.keyboardType = UIKeyboardTypeDefault;
				usernameTextField.returnKeyType = UIReturnKeyNext;
                usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                usernameTextField.delegate = self;
                
                usernameTextField.text = @"";
				//if(blog.username != nil)
				//	usernameTextField.text = blog.username;
			}
            
            return self.usernameCell;
        }
        else if(indexPath.row == 1) 
        {
            self.passwordCell = (UITableViewTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:@"PasswordCell"];
            if (self.passwordCell == nil) 
            {
                self.passwordCell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasswordCell"] autorelease];
                
				self.passwordCell.textLabel.text = NSLocalizedString(@"Password", @"");
				passwordTextField = [self.passwordCell.textField retain];
				passwordTextField.placeholder = NSLocalizedString(@"XboxLivePassword", @"");
				passwordTextField.keyboardType = UIKeyboardTypeDefault;
				passwordTextField.secureTextEntry = YES;
                passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                passwordTextField.delegate = self;
                
                passwordTextField.text = @"";
				//if(password != nil)
				//	passwordTextField.text = password;
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
    [result replaceCharactersInRange:range withString:string];
    
    cell.textLabel.textColor = ([result length] == 0) ? WRONG_FIELD_COLOR : GOOD_FIELD_COLOR;        
    
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                               target:self 
                                                               action:@selector(save:)];
    
    self.navigationItem.title = NSLocalizedString(@"AddAccount", nil);
    self.navigationItem.rightBarButtonItem = saveButton;	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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
	
    //if ([self.username isEqualToString:usernameTextField.text]
    //    && [self.password isEqualToString:passwordTextField.text]) 
    //{
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    //} else {
    //    [self validateFields];
    //}
}

@end
