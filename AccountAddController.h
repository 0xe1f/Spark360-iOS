//
//  AccountAddController.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UITableViewTextFieldCell.h"
#import "CFAccount.h"

@interface AccountAddController : UIViewController<UITableViewDelegate, UITextFieldDelegate>
{
    UIBarButtonItem *saveButton;
    
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    
    CFAccount *account;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) UITableViewTextFieldCell *usernameCell;
@property (nonatomic, retain) UITableViewTextFieldCell *passwordCell;

@property (nonatomic, retain) NSString *password, *username;
@property (nonatomic, retain) CFAccount *account;

// Private

-(void)validateFields;

@end
