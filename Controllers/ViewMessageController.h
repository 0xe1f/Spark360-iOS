//
//  ViewMessageController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"
#import "ContactButton.h"

@interface ViewMessageController : GenericController

@property (nonatomic, retain) IBOutlet UILabel *senderLabel;
@property (nonatomic, retain) IBOutlet UILabel *sent;
@property (nonatomic, retain) IBOutlet ContactButton *sender;
@property (nonatomic, retain) IBOutlet UITextView *messageBody;

@property (nonatomic, retain) NSString *messageUid;
@property (nonatomic, retain) NSString *senderScreenName;

-(id)initWithUid:(NSString*)uid
         account:(XboxLiveAccount*)account;

- (IBAction)viewSenderProfile:(id)sender;

-(IBAction)refresh:(id)sender;
-(IBAction)deleteMessage:(id)sender;
-(IBAction)replyToMessage:(id)sender;

@end
