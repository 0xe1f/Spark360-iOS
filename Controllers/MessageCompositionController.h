//
//  MessageComposeController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"
#import "TITokenFieldView.h"

@interface MessageCompositionController : GenericController <UITextViewDelegate, TITokenFieldViewDelegate>
{
    CGFloat keyboardHeight;
    TITokenFieldView *tokenFieldView;
    UITextView *messageView;
}

@property (nonatomic, retain) NSMutableArray *recipients;
@property (nonatomic, retain) NSString *messageBody;

-(id)initWithRecipient:(id)recipients
               account:(XboxLiveAccount*)account;
-(id)initWithRecipient:(id)recipients
                  messageBody:(NSString*)body
               account:(XboxLiveAccount*)account;

@end
