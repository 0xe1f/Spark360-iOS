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
#import <CoreData/CoreData.h>

#import "EGORefreshTableHeaderView.h"

#import "XboxLiveAccount.h"

#define INPUT_ALERTVIEW_OK_BUTTON (1)
#define ERROR_DIALOG_TAG          (0x1234)

@interface GenericController : UIViewController<UIAlertViewDelegate>
{
    NSManagedObjectContext *managedObjectContext;
};

@property (nonatomic, retain) NSNumberFormatter *numberFormatter;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) XboxLiveAccount *account;

-(id)initWithAccount:(XboxLiveAccount*)account
             nibName:(NSString*)nibName;

-(UIAlertView*)inputDialogWithTitle:(NSString*)title
                            message:(NSString*)message
                               text:(NSString*)text;
-(UIAlertView*)inputDialogWithTitle:(NSString*)title
                            message:(NSString*)message;

-(NSString*)inputDialogText:(UIAlertView*)alertView;

-(BOOL)isNetworkAvailable;

-(void)onSyncError:(NSNotification*)notification;

-(UIImage*)imageFromUrl:(NSString*)url
              parameter:(id)parameter;
-(UIImage*)imageFromUrl:(NSString*)url
               cropRect:(CGRect)cropRect
              parameter:(id)parameter;

-(void)receivedImage:(NSString*)url
           parameter:(id)parameter;

@end
