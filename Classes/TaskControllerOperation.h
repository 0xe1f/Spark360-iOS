//
//  TaskControllerOperation
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface TaskControllerOperation : NSOperation

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, retain) NSDictionary *arguments;
@property (nonatomic, retain) id selectorOwner;
@property (nonatomic, assign) SEL backgroundSelector;
@property (nonatomic, assign) BOOL isNetworked;

- (id)initWithIdentifier:(NSString*)identifier
           selectorOwner:(id)selectorOwner
      backgroundSelector:(SEL)backgroundSelector
               arguments:(NSDictionary*)arguments;

@end
