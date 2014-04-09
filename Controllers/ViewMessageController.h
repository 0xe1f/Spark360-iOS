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

@property (nonatomic, retain) IBOutlet UIBarButtonItem *replyButton;

-(id)initWithUid:(NSString*)uid
         account:(XboxLiveAccount*)account;

-(IBAction)viewSenderProfile:(id)sender;

-(IBAction)refresh:(id)sender;
-(IBAction)deleteMessage:(id)sender;
-(IBAction)replyToMessage:(id)sender;

@end
