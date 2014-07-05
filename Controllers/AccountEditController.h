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

#import <UIKit/UIKit.h>

#import "UITableViewTextFieldCell.h"
#import "XboxLiveAccount.h"

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
@property (nonatomic, retain) XboxLiveAccount *account;

-(void)validateFields;
-(void)validationSucceeded:(NSDictionary*)profile;
-(void)validationFailed:(NSString*)message;

-(void)authenticate;

@end
