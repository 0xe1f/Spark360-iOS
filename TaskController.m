//
//  TaskController.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskController.h"

#import "XboxLiveAccount.h"
#import "XboxLiveParser.h"

@implementation TaskController

static TaskController *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (TaskController*)sharedInstance 
{
    if (sharedInstance == nil) 
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    if (self = [super init]) 
    {
        opQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

#pragma mark Controller

-(void)addOperation:(TaskControllerOperation*)op
{
    if ([[opQueue operations] containsObject:op])
    {
        NSLog(@"Will not add task %@ to queue - already in queue", op.identifier);
        return;
    }
    
    [opQueue addOperation:op];
    
    NSLog(@"Operation %@ added to queue", op.identifier);
}

-(void)synchronizeAchievementsForGame:(NSString*)gameUid
                              account:(XboxLiveAccount*)account
                 managedObjectContext:(NSManagedObjectContext*)moc
{
    NSString *identifier = [NSString stringWithFormat:@"%@.Achievements:%@",
                            account.uuid, gameUid];
    
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               account, @"account",
                               gameUid, @"id", nil];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:moc];
    TaskControllerOperation *op = [[TaskControllerOperation alloc] initWithIdentifier:identifier
                                                                        selectorOwner:parser
                                                                   backgroundSelector:@selector(synchronizeAchievements:)
                                                                            arguments:arguments];
    
    [parser release];
    
    [self addOperation:op];
}

#pragma mark Singleton stuff

// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    [opQueue release];
    
    // I'm never called!
    [super dealloc];
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone 
{
    return [[self sharedInstance] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone 
{
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain 
{
    return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount 
{
    return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
- (oneway void)release 
{
    
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease 
{
    return self;
}

@end