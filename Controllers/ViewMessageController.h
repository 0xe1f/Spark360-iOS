//
//  ViewMessageController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"

@interface ViewMessageController : GenericController

@property (nonatomic, retain) NSString *messageUid;

-(id)initWithUid:(NSString*)uid
         account:(XboxLiveAccount*)account;

@end
