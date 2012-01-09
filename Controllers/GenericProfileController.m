//
//  GenericProfileController.m
//  BachZero
//
//  Created by Akop Karapetyan on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericProfileController.h"

#import "XboxLive.h"
#import "AKImageCache.h"
#import "TaskController.h"

#import "MessageCompositionController.h"
#import "CompareGamesController.h"

#import "ActivityInfoCell.h"
#import "BeaconInfoCell.h"
#import "ProfileInfoCell.h"
#import "ProfileGamerscoreCell.h"
#import "ProfileRatingCell.h"
#import "ProfileLargeTextCell.h"
#import "ProfileStatusCell.h"
#import "ProfileGamertagCell.h"

#import "FriendProfileController.h"
#import "ProfileController.h"

@implementation GenericProfileController
{
    NSArray *statSectionColumns;
    NSArray *statSectionLabels;
    NSInteger profileStatus;
}

@synthesize tableView;

@synthesize composeButton;

@synthesize profile = _profile;
@synthesize beacons = _beacons;
@synthesize screenName = _profileScreenName;

-(id)initWithScreenName:(NSString*)screenName
                account:(XboxLiveAccount*)account
                nibName:(NSString*)nibName
{
    if (self = [super initWithAccount:account
                              nibName:nibName])
    {
        self.beacons = [[NSMutableArray alloc] init];
        self.screenName = screenName;
        self.profile = nil;
        
        statSectionColumns = [[NSArray arrayWithObjects:
                               @"gamerScore",
                               @"rep",
                               @"name",
                               @"location",
                               @"bio",
                               nil] retain];
        
        statSectionLabels = [[NSArray arrayWithObjects:
                              NSLocalizedString(@"InfoGamerscore", nil),
                              NSLocalizedString(@"InfoRep", nil),
                              NSLocalizedString(@"InfoName", nil),
                              NSLocalizedString(@"InfoLocation", nil), 
                              NSLocalizedString(@"InfoBio", nil), 
                              nil] retain];
    }
    
    return self;
}

-(void)dealloc
{
    self.profile = nil;
    self.beacons = nil;
    
    [statSectionColumns release];
    statSectionColumns = nil;
    [statSectionLabels release];
    statSectionLabels = nil;
    
    [super dealloc];
}

+(void)showProfileWithScreenName:(NSString*)screenName
                         account:(XboxLiveAccount*)account
            managedObjectContext:(NSManagedObjectContext*)moc
            navigationController:(UINavigationController*)nc
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                                         inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == [c] %@ AND profile.uuid == %@", 
                              screenName, account.uuid];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSManagedObject *friend = [[moc executeFetchRequest:request 
                                                  error:nil] lastObject];
    
    [request release];
    
    UIViewController *ctlr;
    
    if (friend)
    {
        ctlr = [[FriendProfileController alloc] initWithScreenName:[friend valueForKey:@"uid"]
                                                           account:account];
    }
    else
    {
        ctlr = [[ProfileController alloc] initWithScreenName:screenName
                                                     account:account];
    }
    
    [nc pushViewController:ctlr animated:YES];
    [ctlr release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.screenName;
    self.composeButton.enabled = [self.account canSendMessages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    if (section == 0)
        return 1;
    else if (section == 1)
        return [self.beacons count] + 1; // extra for latest activity
    else if (section == 2)
        return [statSectionColumns count];
    
    return 0;
}

- (CGFloat)tableView:tableView 
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 52;
    }
    else if (indexPath.section == 1)
    {
        return 44;
    }
    else if (indexPath.section == 2)
    {
        NSString *column = [statSectionColumns objectAtIndex:indexPath.row];
        
        if ([column isEqualToString:@"bio"])
        {
            NSString *text = [self.profile objectForKey:column];
            
            CGSize s = [text sizeWithFont:[UIFont systemFontOfSize:12] 
                        constrainedToSize:CGSizeMake(280, 500)];
            
            return s.height + 24;
        }
        
        return 24;
    }
    
    return 42;
}

- (void)tableView:(UITableView *)tableView 
  willDisplayCell:(UITableViewCell *)cell 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // Make the background of the cell transparent
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        
        backView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
        
        [backView release];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            ProfileGamertagCell *gtCell = (ProfileGamertagCell*)[self.tableView dequeueReusableCellWithIdentifier:@"gamertagCell"];
            
            if (!gtCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileGamertagCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        gtCell = (ProfileGamertagCell*)object;
                        break;
                    }
                }
            }
            
            gtCell.screenName.text = self.screenName;
            gtCell.gamerpic.image = [self imageFromUrl:[self.profile objectForKey:@"iconUrl"]
                                             parameter:nil];
            
            NSString *motto = nil;
            if ([self.profile objectForKey:@"motto"])
            {
                motto = [NSString stringWithFormat:NSLocalizedString(@"MottoTemplate_f", nil),
                         [self.profile objectForKey:@"motto"]];
            }
            
            gtCell.motto.text = motto;
            
            cell = gtCell;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            // Latest activity
            
            ActivityInfoCell *aiCell = (ActivityInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:@"activityInfoCell"];
            
            if (!aiCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ActivityInfoCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        aiCell = (ActivityInfoCell*)object;
                        break;
                    }
                }
            }
            
            aiCell.titleName.text = [self.profile objectForKey:@"activityTitleName"];
            aiCell.activityInfo.text = [self.profile objectForKey:@"activityText"];
            aiCell.titleIcon.image = [self imageFromUrl:[self.profile objectForKey:@"activityTitleIconUrl"]
                                               cropRect:CGRectMake(0, 16, 85, 85)
                                              parameter:nil];
            
            cell = aiCell;
        }
        else
        {
            // Beacon
            
            BeaconInfoCell *biCell = (BeaconInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:@"beaconInfoCell"];
            
            if (!biCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"BeaconInfoCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        biCell = (BeaconInfoCell*)object;
                        break;
                    }
                }
            }
            
            NSDictionary *beacon = [self.beacons objectAtIndex:indexPath.row - 1];
            
            biCell.titleName.text = [beacon objectForKey:@"gameName"];
            biCell.message.text = [beacon objectForKey:@"message"];
            biCell.titleIcon.image = [self imageFromUrl:[beacon objectForKey:@"gameBoxArtUrl"]
                                               cropRect:CGRectMake(0, 16, 85, 85)
                                              parameter:nil];
            
            cell = biCell;
        }
    }
    else if (indexPath.section == 2)
    {
        NSString *column = [statSectionColumns objectAtIndex:indexPath.row];
        ProfileCell *pCell = nil;
        
        if ([column isEqualToString:@"gamerScore"])
        {
            ProfileGamerscoreCell *gsCell = (ProfileGamerscoreCell*)[self.tableView dequeueReusableCellWithIdentifier:@"gamerscoreCell"];
            
            if (!gsCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileGamerscoreCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        gsCell = (ProfileGamerscoreCell*)object;
                        break;
                    }
                }
            }
            
            [gsCell setGamerscore:[self.profile objectForKey:column]];
            
            pCell = gsCell;
        }
        else if ([column isEqualToString:@"rep"])
        {
            ProfileRatingCell *starCell = (ProfileRatingCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ratingCell"];
            
            if (!starCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileRatingCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        starCell = (ProfileRatingCell*)object;
                        break;
                    }
                }
            }
            
            [starCell setRating:[self.profile objectForKey:column]];
            
            pCell = starCell;
        }
        else if ([column isEqualToString:@"bio"])
        {
            ProfileLargeTextCell *bioCell = (ProfileLargeTextCell*)[self.tableView dequeueReusableCellWithIdentifier:@"largeTextCell"];
            
            if (!bioCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileLargeTextCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        bioCell = (ProfileLargeTextCell*)object;
                        break;
                    }
                }
            }
            
            [bioCell setText:[self.profile objectForKey:column]];
            
            pCell = bioCell;
        }
        else
        {
            ProfileInfoCell *infoCell = (ProfileInfoCell*)[self.tableView dequeueReusableCellWithIdentifier:@"infoCell"];
            
            if (!infoCell)
            {
                UINib *cellNib = [UINib nibWithNibName:@"ProfileInfoCell" 
                                                bundle:nil];
                
                NSArray *topLevelObjects = [cellNib instantiateWithOwner:nil 
                                                                 options:nil];
                
                for (id object in topLevelObjects)
                {
                    if ([object isKindOfClass:[UITableViewCell class]])
                    {
                        infoCell = (ProfileInfoCell*)object;
                        break;
                    }
                }
            }
            
            infoCell.value.text = [self.profile objectForKey:column];
            
            pCell = infoCell;
        }
        
        pCell.name.text = [statSectionLabels objectAtIndex:indexPath.row];
        cell = pCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && [self.account canSendMessages])
    {
        NSString *titleName = nil;
        NSString *titleId = nil;
        
        if (indexPath.row == 0)
        {
            // Activity cell
            
            titleName = [self.profile objectForKey:@"activityTitleName"];
            titleId = [self.profile objectForKey:@"activityTitleId"];
        }
        else
        {
            // Beacon selected
            
            NSDictionary *beacon = [self.beacons objectAtIndex:indexPath.row - 1];
            
            titleName = [beacon objectForKey:@"gameName"];
            titleId = [beacon objectForKey:@"gameUid"];
        }
        
        if (titleName && [XboxLive isPlayable:titleId])
        {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"LetsPlay_f", nil),
                                 titleName];
            
            MessageCompositionController *ctlr = [[MessageCompositionController alloc] initWithRecipient:self.screenName
                                                                                             messageBody:message
                                                                                                 account:self.account];
            
            [self.navigationController pushViewController:ctlr
                                                 animated:YES];
            
            [ctlr release];
        }
    }
}

#pragma mark - Notifications

-(void)receivedImage:(NSString *)url 
           parameter:(id)parameter
{
    [self.tableView reloadData];
}

#pragma mark - Actions

-(void)compareGames:(id)sender
{
    CompareGamesController *ctlr = [[CompareGamesController alloc] initWithScreenName:self.screenName
                                                                              account:self.account];
    
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

-(void)compose:(id)sender
{
    if ([self.account canSendMessages])
    {
        MessageCompositionController *ctlr = [[MessageCompositionController alloc] initWithRecipient:self.screenName
                                                                                             account:self.account];
        
        [self.navigationController pushViewController:ctlr animated:YES];
        [ctlr release];
    }
}

@end
