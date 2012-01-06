//
//  RootViewController.h
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "EGORefreshTableHeaderView.h"

#import "XboxLiveAccount.h"

@interface GenericController : UIViewController
{
    NSManagedObjectContext *managedObjectContext;
};

@property (nonatomic, retain) NSNumberFormatter *numberFormatter;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSDateFormatter *shortDateFormatter;
@property (nonatomic, retain) XboxLiveAccount *account;

-(id)initWithAccount:(XboxLiveAccount*)account
             nibName:(NSString*)nibName;

-(UIAlertView*)inputDialogWithTitle:(NSString*)title
                        placeholder:(NSString*)placeholder;

-(NSString*)inputDialogText:(UIAlertView*)alertView;

-(void)onSyncError:(NSNotification*)notification;

-(UIImage*)imageFromUrl:(NSString*)url
              parameter:(id)parameter;
-(UIImage*)imageFromUrl:(NSString*)url
               cropRect:(CGRect)cropRect
              parameter:(id)parameter;

-(void)receivedImage:(NSString*)url
           parameter:(id)parameter;

@end
