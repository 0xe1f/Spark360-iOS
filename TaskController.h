//
//  TaskController.h
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskControllerOperation.h"
#import "XboxLiveAccount.h"

@interface TaskController : NSObject
{
    NSOperationQueue *opQueue;
}

+(id)sharedInstance;
-(void)addOperation:(TaskControllerOperation*)op;
-(void)synchronizeAchievementsForGame:(NSString*)gameUid
                              account:(XboxLiveAccount*)account
                 managedObjectContext:(NSManagedObjectContext*)moc;

@end
