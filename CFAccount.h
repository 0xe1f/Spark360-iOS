//
//  CFAccount.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFAccount : NSObject

- (id)initWithAccountId:(NSString*)accountGuid;

@property (nonatomic, copy) NSString *accountId;

@end
