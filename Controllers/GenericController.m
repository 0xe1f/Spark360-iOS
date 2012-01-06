//
//  RootViewController.m
//  ListTest
//
//  Created by Akop Karapetyan on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericController.h"

#import "BachAppDelegate.h"
#import "AKImageCache.h"
#import "ImageCache.h"
#import "TaskController.h"

#pragma mark - GenericControllerRequestor

@interface GenericControllerRequestor : NSObject

@property (nonatomic, retain) NSString *controllerClassName;

- (id)initWithControllerClass:(Class)class;

@end

@implementation GenericControllerRequestor

@synthesize controllerClassName;

- (id)initWithControllerClass:(Class)class
{
    if (self = [super init])
    {
        self.controllerClassName = NSStringFromClass(class);
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[GenericControllerRequestor class]])
        return NO;
    
    GenericControllerRequestor* gcr = (GenericControllerRequestor*)object;
    return [gcr.controllerClassName isEqualToString:self.controllerClassName];
}

@end

#pragma mark - GenericController

@implementation GenericController
{
    GenericControllerRequestor *_requestor;
}

@synthesize numberFormatter = _numberFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize shortDateFormatter = _shortDateFormatter;

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
        
        _requestor = [[GenericControllerRequestor alloc] initWithControllerClass:[self class]];
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        _shortDateFormatter = [[NSDateFormatter alloc] init];
        [self.shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return self;
}

-(void)dealloc
{
    self.numberFormatter = nil;
    self.dateFormatter = nil;
    self.shortDateFormatter = nil;
    self.account = nil;
    
    [_requestor release];
    _requestor = nil;
    
    managedObjectContext = nil;
    
    [super dealloc];
}

#pragma mark - Notifications

-(void)onSyncError:(NSNotification *)notification
{
    NSLog(@"Got sync error notification");
    
    NSError *error = [notification.userInfo objectForKey:BACHNotificationNSError];
    
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

-(void)onImageRetrieved:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([_requestor isEqual:[userInfo objectForKey:AKImageRequestor]])
    {
        [self receivedImage:[userInfo objectForKey:AKImageUrl]
                  parameter:[userInfo objectForKey:AKImageParameter]];
    }
}

#pragma mark - UIViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onImageRetrieved:)
                                                 name:AKImageRetrieved
                                               object:nil];
    
    [[AKImageCache sharedInstance] purgeInMemCache];
    [[ImageCache sharedInstance] purgeInMemCache];
    
    NSLog(@"++ View %@ loaded", [self class]);
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AKImageRetrieved
                                                  object:nil];
    
    NSLog(@"-- View %@ unloaded", [self class]);
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
    
    [[ImageCache sharedInstance] purgeInMemCache];
    [[AKImageCache sharedInstance] purgeInMemCache];
    
    NSLog(@"! %@ got a memory warning", [self class]);
}

#pragma mark - Etc

-(void)receivedImage:(NSString*)url
           parameter:(id)parameter
{
}

-(UIImage*)imageFromUrl:(NSString*)url
               cropRect:(CGRect)cropRect
              parameter:(id)parameter
{
    
    return [[AKImageCache sharedInstance] imageFromUrl:url
                                              cropRect:cropRect
                                             requestor:_requestor
                                             parameter:parameter];
}

-(UIImage*)imageFromUrl:(NSString*)url
              parameter:(id)parameter
{
    return [[AKImageCache sharedInstance] imageFromUrl:url
                                             requestor:_requestor
                                             parameter:parameter];
}

-(UIAlertView*)inputDialogWithTitle:(NSString*)title
                        placeholder:(NSString*)placeholder
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title 
                                                            message:@"\n\n\n"
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
                                                  otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.tag = 0xDEADBEEF;
    textField.font = [UIFont systemFontOfSize:18];
    textField.backgroundColor = [UIColor whiteColor];
    textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.placeholder = placeholder;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"textFieldBackground" 
                                                                                                                                       ofType:@"png"]]];
    backgroundImage.frame = CGRectMake(11,79,262,31);
    [alertView addSubview:backgroundImage];
    [backgroundImage release];
    
    [textField becomeFirstResponder];
    [alertView addSubview:textField];
    [textField release];
    
    return [alertView autorelease];
}

-(NSString*)inputDialogText:(UIAlertView*)alertView
{
    id textView = [alertView viewWithTag:0xDEADBEEF];
    if ([textView isKindOfClass:[UITextField class]])
        return [(UITextField*)textView text];
    
    return nil;
}

@end
