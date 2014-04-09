/*
 * Spark 360 for iOS
 * https://github.com/Melllvar/Spark360-iOS
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

#import "MessageCompositionController.h"

#import "TaskController.h"

@interface MessageCompositionController (Private)

- (NSArray*)friendScreenNames;
- (void)textViewDidChange:(UITextView *)textView;
- (void)resizeViews;
- (void)toggleSend;

@end

@implementation MessageCompositionController

@synthesize recipients = _recipients;
@synthesize messageBody = _messageBody;

-(id)initWithRecipient:(id)recipients
           messageBody:(NSString*)body
               account:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"MessageCompositionController"])
    {
        _recipients = [[NSMutableArray alloc] init];
        self.messageBody = body;
        
        if (recipients)
        {
            if ([recipients isKindOfClass:[NSArray class]])
                [self.recipients addObjectsFromArray:recipients];
            else
                [self.recipients addObject:(NSString*)recipients];
        }
    }
    
    return self;
}

-(id)initWithRecipient:(id)recipients
               account:(XboxLiveAccount*)account
{
    if (self = [self initWithRecipient:recipients
                           messageBody:nil
                               account:account])
    {
    }
    
    return self;
}

-(void)dealloc
{
    self.recipients = nil;
    self.messageBody = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"NewMessage", nil);
    
	tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
	[tokenFieldView setDelegate:self];
	[tokenFieldView setSourceArray:[self friendScreenNames]];
    
    /*
	[tokenFieldView.tokenField setAddButtonAction:@selector(showContactsPicker) 
                                           target:self];
	*/
	messageView = [[UITextView alloc] initWithFrame:tokenFieldView.contentView.bounds];
	[messageView setScrollEnabled:NO];
	[messageView setAutoresizingMask:UIViewAutoresizingNone];
	[messageView setFont:[UIFont systemFontOfSize:15]];
	[messageView setText:self.messageBody];
    [messageView setDelegate:self];
    
	[tokenFieldView.contentView addSubview:messageView];
	[self.view addSubview:tokenFieldView];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:self
                                                                  action:@selector(sendMessage)];
    
    self.navigationItem.rightBarButtonItem = sendButton;
    [sendButton release];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    if ([self.recipients count] > 0)
    {
        for (NSString *recipient in self.recipients)
            [[tokenFieldView tokenField] addToken:recipient];
        
        [messageView becomeFirstResponder];
    }
    else
    {
        [tokenFieldView becomeFirstResponder];
	}
    
    [self toggleSend];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
	[tokenFieldView release];
    tokenFieldView = nil;
    
    [messageView release];
    messageView = nil;
}

#pragma mark - TITokenFieldViewDelegate

- (void)tokenFieldTextDidChange:(TITokenField *)tokenField
{
    [self.recipients removeAllObjects];
    
    for (TIToken *token in [tokenField tokensArray])
        [self.recipients addObject:[token title]];
    
    [self toggleSend];
}

- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame 
{
	[self textViewDidChange:messageView];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView 
shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)string
{
    NSUInteger newLength = [textView.text length] + [string length] - range.length;
    
    return (newLength > 250) ? NO : YES;
}

- (void)textViewDidChange:(UITextView *)textView 
{
	CGFloat fontHeight = (textView.font.ascender - textView.font.descender) + 1;
	CGFloat originHeight = tokenFieldView.frame.size.height - tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + fontHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < originHeight)
    {
		newTextFrame.size.height = originHeight;
		newFrame.size.height = originHeight;
	}
    
	[tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[tokenFieldView updateContentSize];
    
    self.messageBody = textView.text;
    
    [self toggleSend];
}

#pragma mark - Misc

- (void)toggleSend
{
    BOOL hasRecipients = [self.recipients count] > 0;
    BOOL hasMessageBody = [self.messageBody length] > 0;
    
    [self.navigationItem.rightBarButtonItem setEnabled:(hasRecipients && hasMessageBody && self.account.canSendMessages)]; 
}

- (NSArray*)friendScreenNames
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                                         inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"profile.uuid == %@", 
                              self.account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:request 
                                                         error:nil];
    
    NSMutableArray *screenNames = [[[NSMutableArray alloc] init] autorelease];
    for (NSManagedObject *obj in array) 
        [screenNames addObject:[obj valueForKey:@"screenName"]];
    
    [request release];
    
    return screenNames;
}

- (void)resizeViews 
{
	CGRect newFrame = tokenFieldView.frame;
	newFrame.size.width = self.view.bounds.size.width;
	newFrame.size.height = self.view.bounds.size.height - keyboardHeight;
	[tokenFieldView setFrame:newFrame];
	[messageView setFrame:tokenFieldView.contentView.bounds];
}

#pragma mark - Notification callbacks

- (void)keyboardWillShow:(NSNotification *)notification 
{
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// Wouldn't it be fantastic if, when in landscape mode, width was actually width and not height?
	keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
	keyboardHeight = 0;
	[self resizeViews];
}

#pragma mark - Actions

- (void)sendMessage
{
    if ([self.recipients count] < 1 || 
        [self.messageBody length] < 1 ||
        ![self.account canSendMessages])
    {
        BACHLog(@"Will not send - conditions not met");
        return;
    }
    
    [[TaskController sharedInstance] sendMessageToRecipients:self.recipients
                                                        body:self.messageBody
                                                     account:self.account];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
