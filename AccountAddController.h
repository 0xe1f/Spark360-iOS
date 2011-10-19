//
//  AccountAddController.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UITableViewTextFieldCell.h"

@interface AccountAddController : UIViewController<UITableViewDelegate, UITextFieldDelegate>
{
    UIBarButtonItem *saveButton;
    
    UITextField *usernameTextField;
    UITextField *passwordTextField;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) UITableViewTextFieldCell *usernameCell;
@property (nonatomic, retain) UITableViewTextFieldCell *passwordCell;

@end
