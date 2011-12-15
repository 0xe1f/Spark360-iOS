//
//  FriendProfileController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendProfileController.h"

#import "TaskController.h"
#import "ProfileInfoCell.h"
#import "ProfileGamerscoreCell.h"
#import "ProfileRatingCell.h"
#import "ProfileLargeTextCell.h"

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

- (NSInteger)tableView:(UITableView *)tv 
 numberOfRowsInSection:(NSInteger)section 
{
    return [self.propertyKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tv 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == 0)
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
            largeTextCell.value.text = value;
            
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
    /*
    if (!cell)
    {
        cell = [[[ProfileInfoCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:@"NoCell"] autorelease];
    }
    */
    /*
     if ([indexPath section] == 0) 
     {
     if(indexPath.row == 0) 
     {
     self.usernameCell = (UITableViewTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:@"UsernameCell"];
     
     if (self.usernameCell == nil) 
     {
     self.usernameCell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault 
     reuseIdentifier:@"UsernameCell"] autorelease];
     self.usernameCell.textLabel.text = NSLocalizedString(@"Username", @"");
     
     usernameTextField = [self.usernameCell.textField retain];
     usernameTextField.placeholder = NSLocalizedString(@"XboxLiveUsername", @"");
     usernameTextField.keyboardType = UIKeyboardTypeDefault;
     usernameTextField.returnKeyType = UIReturnKeyNext;
     usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
     usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
     usernameTextField.delegate = self;
     [usernameTextField becomeFirstResponder];
     
     usernameTextField.text = self.emailAddress;
     }
     
     return self.usernameCell;
     }
     else if(indexPath.row == 1) 
     {
     self.passwordCell = (UITableViewTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:@"PasswordCell"];
     if (self.passwordCell == nil) 
     {
     self.passwordCell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault 
     reuseIdentifier:@"PasswordCell"] autorelease];
     self.passwordCell.textLabel.text = NSLocalizedString(@"Password", @"");
     
     passwordTextField = [self.passwordCell.textField retain];
     passwordTextField.placeholder = NSLocalizedString(@"XboxLivePassword", @"");
     passwordTextField.keyboardType = UIKeyboardTypeDefault;
     passwordTextField.secureTextEntry = YES;
     passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
     passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
     passwordTextField.delegate = self;
     
     passwordTextField.text = self.password;
     }
     return self.passwordCell;
     }
     }
     
     // We shouldn't reach this point, but return an empty cell just in case
     return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoCell"] autorelease];
     */
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        UINib *cellNib = [UINib nibWithNibName:@"FriendProfileInfoCell" bundle:nil];
        [cellNib instantiateWithOwner:self options:nil];
        
        cell = self.tvCell;
        //[[NSBundle mainBundle] loadNibNamed:@"ProfileInfoCell" owner:self options:nil];
    }
    
    ProfileInfoCell *infoCell = (ProfileInfoCell*)cell;
    
    NSString *infoKey = [self.propertyKeys objectAtIndex:indexPath.row];
    id value = [self.properties objectForKey:infoKey];
    
    if (value)
    {
        
        infoCell.name.text = NSLocalizedString([self.propertyTitles objectForKey:infoKey], nil);
        if ([value isKindOfClass:[NSString class]])
        {
            infoCell.value.text = value;
        }
    }
    
    return cell;
     */
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) 
    {
        case 0:
            return NSLocalizedString(@"LoginInfo", nil);
		default:
            return nil;
	}
    return nil;
}
*/

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
        
        for (NSString *key in self.propertyKeys) 
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
