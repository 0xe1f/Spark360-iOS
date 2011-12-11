//
//  RootViewController.m
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericController.h"

#import "BachAppDelegate.h"
#import "CFImageCache.h"
#import "TaskController.h"

@implementation GenericController

@synthesize numberFormatter = _numberFormatter;
@synthesize account = _account;

-(id)initWithNibName:(NSString *)nibNameOrNil 
              bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithAccount:nil
                         nibName:nibNameOrNil];
}

-(id)initWithAccount:(XboxLiveAccount*)account
             nibName:(NSString*)nibName
{
    if (self = [super initWithNibName:nibName 
                               bundle:nil])
    {
        self.account = account;
        
        BachAppDelegate *bachApp = [BachAppDelegate sharedApp];
        managedObjectContext = bachApp.managedObjectContext;
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    
    return self;
}

-(void)dealloc
{
    self.numberFormatter = nil;
    self.account = nil;
    
    [managedObjectContext release];
    managedObjectContext = nil;
    
    [super dealloc];
}

-(void)onSyncError:(NSNotification *)notification
{
    NSLog(@"Got sync error notification");
    
    NSError *error = [notification.userInfo objectForKey:BACHNotificationNSError];
    
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

#pragma mark -
#pragma mark UIViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[CFImageCache sharedInstance] purgeInMemCache];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSyncError:)
                                                 name:BACHError 
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHError
                                                  object:nil];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[CFImageCache sharedInstance] purgeInMemCache];
}

@end
