//
//  FriendProfileController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendProfileController.h"

#import "XboxLive.h"
#import "CFImageCache.h"
#import "TaskController.h"
#import "ProfileInfoCell.h"
#import "ProfileGamerscoreCell.h"
#import "ProfileRatingCell.h"
#import "ProfileLargeTextCell.h"
#import "ProfileStatusCell.h"

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

@synthesize properties = _properties;
@synthesize propertyKeys = _propertyKeys;
@synthesize propertyTitles = _propertyTitles;

-(id)initWithFriendUid:(NSString*)uid
               account:(XboxLiveAccount*)account
{
    if (self = [super initWithAccount:account
                              nibName:@"FriendProfileController"])
    {
        self.friendUid = uid;
        self.friendScreenName = nil;
        self.isStale = false;
        
        _properties = [[NSMutableDictionary alloc] init];
        self.propertyKeys = [NSArray arrayWithObjects:
                             @"gamerscore",
                             @"rep",
                             @"name",
                             @"location",
                             @"motto",
                             @"bio",
                             nil];
        self.propertyTitles = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"InfoStatus", @"statusCode",
                               @"InfoGamerscore", @"gamerscore",
                               @"InfoRep", @"rep",
                               @"InfoMotto", @"motto",
                               @"InfoName", @"name",
                               @"InfoLocation", @"location",
                               @"InfoBio", @"bio",
                               nil];
    }
    
    return self;
}

-(void)dealloc
{
    self.friendUid = nil;
    self.friendScreenName = nil;
    
    self.properties = nil;
    self.propertyKeys = nil;
    self.propertyTitles = nil;
    
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

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView 
 titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"CurrentStatus", nil);
    }
    else if (section == 1)
    {
        return NSLocalizedString(@"Statistics", nil);
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return [self.propertyKeys count];
    }
    
    return 0;
}

- (CGFloat)tableView:tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 68;
    }
    else if (indexPath.section == 1)
    {
        NSString *infoKey = [self.propertyKeys objectAtIndex:indexPath.row];
        if ([infoKey isEqualToString:@"bio"])
        {
            NSString *text = [self.properties objectForKey:infoKey];
            
            CGSize s = [text sizeWithFont:[UIFont systemFontOfSize:12] 
                        constrainedToSize:CGSizeMake(280, 500)];
            
            return s.height + 24;
        }
        
        return 24;
    }
    
    return 0;
}

- (void)imageLoaded:(NSString*)url
{
    // TODO: this causes a full data reload; not a good idea
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == 0)
    {
        ProfileStatusCell *statusCell = (ProfileStatusCell*)[self.tableView dequeueReusableCellWithIdentifier:@"statusCell"];
        
        if (!statusCell)
        {
            UINib *cellNib = [UINib nibWithNibName:@"ProfileStatusCell" 
                                            bundle:nil];
            
            NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil options:nil];
            
            for (id object in topLevelObjects)
            {
                if ([object isKindOfClass:[UITableViewCell class]])
                {
                    statusCell = (ProfileStatusCell *)object;
                    break;
                }
            }
        }
        
        int statusCode = [[self.properties objectForKey:@"statusCode"] intValue];
        
        statusCell.status.text = [XboxLive descriptionFromFriendStatus:statusCode];
        statusCell.activity.text = [self.properties objectForKey:@"activityText"];
        
        UIImage *boxArt = [[CFImageCache sharedInstance]
                           getCachedFile:[self.properties objectForKey:@"activityTitleIconUrl"]
                           notifyObject:self
                           notifySelector:@selector(imageLoaded:)];
        
        [statusCell.titleIcon setImage:boxArt];
        
        UIImage *gamerpic = [[CFImageCache sharedInstance]
                  getCachedFile:[self.properties objectForKey:@"iconUrl"]
                             notifyObject:self
                             notifySelector:@selector(imageLoaded:)];
        
        [statusCell.gamerpic setImage:gamerpic];
        
        return statusCell;
    }
    else if (indexPath.section == 1)
    {
        NSString *infoKey = [self.propertyKeys objectAtIndex:indexPath.row];
        
        NSString *name = NSLocalizedString([self.propertyTitles objectForKey:infoKey], nil);
        id value = [self.properties objectForKey:infoKey];
        
        // Bio
        if ([infoKey isEqualToString:@"bio"])
        {
            ProfileLargeTextCell *largeTextCell = (ProfileLargeTextCell*)[self.tableView dequeueReusableCellWithIdentifier:@"largeTextCell"];
            
            if (!largeTextCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileLargeTextCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        largeTextCell = (ProfileLargeTextCell *)object;
                        break;
                    }
                }
            }
            
            largeTextCell.name.text = name;
            [largeTextCell setText:value];
            
            return largeTextCell;
        }
        // Gamerscore
        else if ([infoKey isEqualToString:@"gamerscore"])
        {
            ProfileGamerscoreCell *gamerscoreCell = (ProfileGamerscoreCell*)[self.tableView dequeueReusableCellWithIdentifier:@"gamerscoreCell"];
            
            if (!gamerscoreCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileGamerscoreCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        gamerscoreCell = (ProfileGamerscoreCell *)object;
                        break;
                    }
                }
            }
            
            gamerscoreCell.name.text = name;
            [gamerscoreCell setGamerscore:value];
            
            return gamerscoreCell;
        }
        // Rep
        else if ([infoKey isEqualToString:@"rep"])
        {
            ProfileRatingCell *ratingCell = (ProfileRatingCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
            
            if (!ratingCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileRatingCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        ratingCell = (ProfileRatingCell *)object;
                        break;
                    }
                }
            }
            
            ratingCell.name.text = name;
            [ratingCell setRating:value];
            
            return ratingCell;
        }
        // Basic NSString entries
        else
        {
            ProfileInfoCell *infoCell = (ProfileInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:@"infoCell"];
            
            if (!infoCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileInfoCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        infoCell = (ProfileInfoCell *)object;
                        break;
                    }
                }
            }
            
            infoCell.name.text = name;
            infoCell.value.text = value;
            
            return infoCell;
        }
    }
    
    return nil;
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
        
        [self.properties removeAllObjects];
        
        NSArray *loadKeys = [NSArray arrayWithObjects:
                             @"screenName",
                             @"activityText",
                             @"activityTitleIconUrl",
                             @"iconUrl",
                             @"statusCode",
                             @"gamerscore",
                             @"rep",
                             @"name",
                             @"location",
                             @"motto",
                             @"bio",
                             nil];
        
        for (NSString *key in loadKeys) 
        {
            id value = [friend valueForKey:key];
            if (value)
                [self.properties setObject:value forKey:key];
        }
        
        [tableView reloadData];
    }
}

-(void)refresh:(id)sender
{
    [[TaskController sharedInstance] synchronizeFriendProfileForUid:self.friendUid
                                                            account:self.account
                                               managedObjectContext:managedObjectContext];
}

@end
