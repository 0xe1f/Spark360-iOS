//
//  ProfileController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileController.h"

#import "XboxLive.h"
#import "ImageCache.h"
#import "TaskController.h"

#import "ProfileInfoCell.h"
#import "ProfileGamerscoreCell.h"
#import "ProfileRatingCell.h"
#import "ProfileLargeTextCell.h"
#import "ProfileStatusCell.h"

#define OK_BUTTON_INDEX 1

@interface ProfileController (Private) 

-(void)updateStats:(NSDictionary*)data;

@end

@implementation ProfileController

@synthesize tableView;
@synthesize toolbar;
@synthesize composeButton;

@synthesize screenName = _screenName;
@synthesize profileLoaded;

@synthesize properties = _properties;
@synthesize propertyKeys = _propertyKeys;
@synthesize propertyTitles = _propertyTitles;

-(id)initWithScreenName:(NSString *)screenName
                account:(XboxLiveAccount *)account
{
    if (self = [super initWithAccount:account
                              nibName:@"ProfileController"])
    {
        self.screenName = screenName;
        self.profileLoaded = NO;
        
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
                //               @"InfoStatus", @"statusCode",
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
    self.screenName = nil;
    
    self.properties = nil;
    self.propertyKeys = nil;
    self.propertyTitles = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHProfileLoaded
                                               object:nil];
    
    self.title = self.screenName;
    
    [self refreshProfile];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHProfileLoaded
                                                  object:nil];
}

-(void)alertView:(UIAlertView *)alertView 
clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == OK_BUTTON_INDEX)
    {
        [[TaskController sharedInstance] sendAddFriendRequestToScreenName:self.screenName
                                                                  account:self.account];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return NSLocalizedString(@"CurrentStatus", nil);
    }
    else if (section == 2)
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
        return 0;
    }
    else if (section == 2)
    {
        return [self.propertyKeys count];
    }
    
    return 1;
}

- (CGFloat)tableView:tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 0;
    }
    else if (indexPath.section == 1)
    {
        return 68;
    }
    else if (indexPath.section == 2)
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

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == 0)
    {
    }
    else if (indexPath.section == 1)
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
        
        UIImage *boxArt = [[ImageCache sharedInstance] getCachedFile:[self.properties objectForKey:@"activityTitleIconUrl"]
                                                        notifyObject:self
                                                      notifySelector:@selector(imageLoaded:)];
        
        [statusCell.titleIcon setImage:boxArt];
        
        UIImage *gamerpic = [[ImageCache sharedInstance] getCachedFile:[self.properties objectForKey:@"iconUrl"]
                                                          notifyObject:self
                                                        notifySelector:@selector(imageLoaded:)];
        
        [statusCell.gamerpic setImage:gamerpic];
        
        return statusCell;
    }
    else if (indexPath.section == 2)
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

#pragma mark - Notification delegates

- (void)imageLoaded:(NSString*)url
{
    // TODO: this causes a full data reload; not a good idea
    [self.tableView reloadData];
}

-(void)syncCompleted:(NSNotification *)notification
{
    NSLog(@"Got sync completed notification");
    
    XboxLiveAccount *account = [notification.userInfo objectForKey:BACHNotificationAccount];
    
    if ([account isEqualToAccount:self.account])
    {
        NSDictionary *profile = [notification.userInfo objectForKey:BACHNotificationData];
        
        [self updateStats:profile];
    }
}

-(void)onSyncError:(NSNotification *)notification
{
    [super onSyncError:notification];
    
    if (!self.profileLoaded)
    {
        // Assume the profile couldn't be found. Close the view
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Misc

-(void)updateStats:(NSDictionary*)profile
{
    if (profile)
    {
        self.screenName = [profile valueForKey:@"screenName"];
        self.profileLoaded = YES;
        
        [self.properties removeAllObjects];
        
        NSArray *loadKeys = [NSArray arrayWithObjects:
                             @"screenName",
                             @"avatarUrl",
                             @"activityText",
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
            id value = [profile valueForKey:key];
            if (value)
                [self.properties setObject:value forKey:key];
        }
        
        if (![self.properties objectForKey:@"statusCode"])
            [self.properties setObject:[NSNumber numberWithInt:XBLFriendUnknown]
                                forKey:@"statusCode"];
        
        self.title = self.screenName;
        
        [tableView reloadData];
    }
}

-(void)refreshProfile
{
    [[TaskController sharedInstance] loadProfileForScreenName:self.screenName
                                                      account:self.account];
}

#pragma mark - Actions

-(void)refresh:(id)sender
{
    [self refreshProfile];
}

-(void)compose:(id)sender
{
    // TODO
}

-(void)compareGames:(id)sender
{
    // TODO
}

-(void)addFriend:(id)sender
{
    NSString *title = NSLocalizedString(@"AreYouSure", nil);
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"SendFriendRequestTo_f", nil),
                        self.screenName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title 
                                                        message:message
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel",nil) 
                                              otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    [alertView show];
    [alertView release];
}

@end
