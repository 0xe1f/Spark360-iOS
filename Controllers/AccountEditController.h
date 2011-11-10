//
//  AccountAddController.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UITableViewTextFieldCell.h"
#import "XboxAccount.h"

#define WRONG_FIELD_COLOR [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0]
#define GOOD_FIELD_COLOR [UIColor blackColor]

@interface AccountEditController : UIViewController<UITableViewDelegate, UITextFieldDelegate>
{
    UIBarButtonItem *saveButton;
    
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UIActivityIndicatorView *savingIndicator;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) UITableViewTextFieldCell *usernameCell;
@property (nonatomic, retain) UITableViewTextFieldCell *passwordCell;

@property (nonatomic, retain) NSString *password, *emailAddress;
@property (nonatomic, retain) XboxAccount *account;

-(void)validateFields;
-(void)validationSucceeded:(NSDictionary*)profile;
-(void)validationFailed:(NSString*)message;

-(void)authenticate;

@end
