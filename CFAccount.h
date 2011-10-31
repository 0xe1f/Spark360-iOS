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

@property (nonatomic, retain) NSString *accountId;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@end
