//
//  MessageComposeController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"

@interface MessageComposeController : GenericController

@property (nonatomic, retain) NSMutableArray *recipients;

-(id)initWithRecipient:(id)recipients
               account:(XboxLiveAccount*)account;

@end
