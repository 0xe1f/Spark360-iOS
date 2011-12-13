//
//  FriendProfileController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendProfileController.h"

#import "TaskController.h"

@interface FriendProfileController (Private) 

-(void)updateFriendStats;
-(void)syncCompleted:(NSNotification *)notification;

@end

@implementation FriendProfileController

@synthesize tableView;
@synthesize toolbar;

@synthesize friendUid;
@synthesize friendScreenName;
@synthesize isStale;

-(id)initWithFriendUid:(NSString*)uid
               account:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"FriendProfileController"])
    {
        self.friendUid = uid;
        self.friendScreenName = nil;
        self.isStale = false;
    }
    
    return self;
}

-(void)dealloc
{
    self.friendUid = nil;
    self.friendScreenName = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateFriendStats];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHFriendProfileSynced
                                               object:nil];
    
    self.title = self.friendScreenName;
    
    if (self.isStale)
        [self refresh:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHFriendProfileSynced
                                                  object:nil];
}

#pragma mark - Misc

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    [self updateFriendStats];
}

-(void)updateFriendStats
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                                         inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile.uuid == %@", 
                              self.friendUid, self.account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [managedObjectContext executeFetchRequest:request 
                                                         error:nil];
    
    NSManagedObject *friend = [array lastObject];
    
    [request release];
    
    if (friend)
    {
        self.friendScreenName = [friend valueForKey:@"screenName"];
        self.isStale = [self.account isDataStale:[friend valueForKey:@"profileLastUpdated"]];
    }
}

-(void)refresh:(id)sender
{
    [[TaskController sharedInstance] synchronizeFriendProfileForUid:self.friendUid
                                                            account:self.account
                                               managedObjectContext:managedObjectContext];
}

@end
