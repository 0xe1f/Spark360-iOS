//
//  XboxLiveAccountPreferences.m
//  BachZero
//
//  Created by Akop Karapetyan on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLiveAccount.h"
#import "KeychainItemWrapper.h"
#import "XboxLiveParser.h"
#import "TaskController.h"

NSString* const BACHGamesSynced = @"GamesSynced";

@interface XboxLiveAccount (Private)

-(NSString*)keyForPreference:(NSString*)preference;
-(void)resetDirtyFlags;

-(void)syncCompleted;
-(void)retrieveGamesInBackground:(NSManagedObjectContext*)managedObjectContext;
-(void)retrieveAchievementsInBackground:(NSDictionary*)arguments;
-(void)retrievedGamesWithObjects:(NSDictionary*)objects;
-(void)retrieveFailedWithError:(NSError*)error;

@end

@implementation XboxLiveAccount
{
    NSString *_uuid;
    NSDate *_lastGamesUpdate;
    BOOL _lastGamesUpdateDirty;
    NSNumber *_stalePeriodInSeconds;
    BOOL _browseRefreshPeriodInSecondsDirty;
    NSString *_emailAddress;
    BOOL _emailAddressDirty;
    NSString *_password;
    BOOL _passwordDirty;
    NSString *_screenName;
    BOOL _screenNameDirty;
}

@synthesize isSyncingGames;

NSString * const KeychainPassword = @"com.akop.bach";

NSString * const StalePeriodKey = @"StalePeriod";
NSString * const ScreenNameKey = @"ScreenName";
NSString * const GameLastUpdatedKey = @"GamesLastUpdated";
NSString * const CookiesKey = @"Cookies";

#define DEFAULT_BROWSING_REFRESH_TIMEOUT_SECONDS (60*5)

-(NSString*)uuid
{
    return _uuid;
}

-(void)reload
{
    if (self.uuid)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        // Load pref-based properties
        self.lastGamesUpdate = [prefs objectForKey:[self keyForPreference:GameLastUpdatedKey]];
        self.stalePeriodInSeconds = [prefs objectForKey:[self keyForPreference:StalePeriodKey]];
        self.screenName = [prefs objectForKey:[self keyForPreference:ScreenNameKey]];
        
        // Load Secure properties
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:self.uuid
                                                                                serviceName:KeychainPassword
                                                                                accessGroup:nil];
        self.emailAddress = [keychainItem objectForKey:kSecAttrAccount];
        self.password = [keychainItem objectForKey:kSecValueData];
        [keychainItem release];
        
        // Mark the properties 'clean'
        [self resetDirtyFlags];
        
        // Set defaults
        if (!self.stalePeriodInSeconds)
            self.stalePeriodInSeconds = [NSNumber numberWithInt:DEFAULT_BROWSING_REFRESH_TIMEOUT_SECONDS];
        if (!self.lastGamesUpdate)
            self.lastGamesUpdate = [NSDate distantPast];
    }
}

-(void)purge
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:[self keyForPreference:GameLastUpdatedKey]];
    [prefs removeObjectForKey:[self keyForPreference:StalePeriodKey]];
    [prefs removeObjectForKey:[self keyForPreference:ScreenNameKey]];
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:self.uuid
                                                                            serviceName:KeychainPassword
                                                                            accessGroup:nil];
    [keychainItem resetKeychainItem];
    [keychainItem release];
}

-(void)save
{
    if (self.uuid)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if (_lastGamesUpdateDirty)
        {
            [prefs setObject:self.lastGamesUpdate 
                      forKey:[self keyForPreference:GameLastUpdatedKey]];
        }
        
        if (_browseRefreshPeriodInSecondsDirty)
        {
            [prefs setObject:self.stalePeriodInSeconds 
                      forKey:[self keyForPreference:StalePeriodKey]];
        }
        
        if (_screenNameDirty)
        {
            [prefs setObject:self.screenName 
                      forKey:[self keyForPreference:ScreenNameKey]];
        }
        
        if (_emailAddressDirty || _passwordDirty)
        {
            KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:self.uuid
                                                                                    serviceName:KeychainPassword
                                                                                    accessGroup:nil];
            [keychainItem setObject:self.password forKey:kSecValueData];
            [keychainItem setObject:self.emailAddress forKey:kSecAttrAccount];
            [keychainItem release];
        }
        
        [self resetDirtyFlags];
    }
}

-(void)resetDirtyFlags
{
    _lastGamesUpdateDirty = NO;
    _browseRefreshPeriodInSecondsDirty = NO;
    _emailAddressDirty = NO;
    _passwordDirty = NO;
    _screenNameDirty = NO;
}

-(NSDate*)lastGamesUpdate
{
    return _lastGamesUpdate;
}

-(void)setLastGamesUpdate:(NSDate*)lastGamesUpdate
{
    [lastGamesUpdate retain];
    [_lastGamesUpdate release];
    
    _lastGamesUpdate = lastGamesUpdate;
    _lastGamesUpdateDirty = YES;
}

-(NSString*)screenName
{
    return _screenName;
}

-(void)setScreenName:(NSString *)screenName
{
    [screenName retain];
    [_screenName release];
    
    _screenName = screenName;
    _screenNameDirty = YES;
}

-(NSNumber*)stalePeriodInSeconds
{
    return _stalePeriodInSeconds;
}

-(void)setStalePeriodInSeconds:(NSNumber*)browseRefreshPeriodInSeconds
{
    [browseRefreshPeriodInSeconds retain];
    [_stalePeriodInSeconds release];
    
    _stalePeriodInSeconds = browseRefreshPeriodInSeconds;
    _browseRefreshPeriodInSecondsDirty = YES;
}

-(NSString*)emailAddress
{
    return _emailAddress;
}

-(void)setEmailAddress:(NSString*)emailAddress
{
    [emailAddress retain];
    [_emailAddress release];
    
    _emailAddress = emailAddress;
    _emailAddressDirty = YES;
}

-(NSString*)password
{
    return _password;
}

-(void)setPassword:(NSString*)password
{
    [password retain];
    [_password release];
    
    _password = password;
    _passwordDirty = YES;
}

-(BOOL)areGamesStale
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setSecond:-[self.stalePeriodInSeconds intValue]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *refreshDate = [gregorian dateByAddingComponents:comps 
                                                     toDate:[NSDate date] 
                                                    options:0];
    
    BOOL stale = ([self.lastGamesUpdate compare:refreshDate] == NSOrderedAscending);
    
    [comps release];
    [gregorian release];
    
    return stale;
}

-(void)syncGamesInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    if (self.isSyncingGames)
    {
        NSLog(@"Ignoring game sync request; already syncing");
        return;
    }
    
    self.isSyncingGames = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self performSelectorInBackground:@selector(retrieveGamesInBackground:) 
                           withObject:managedObjectContext];
}

-(void)syncCompleted
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)retrieveGamesInBackground:(NSManagedObjectContext*)managedObjectContext
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    XboxLiveParser *parser = [[[XboxLiveParser alloc] init] autorelease];
    
    NSError *error = nil;
    NSDictionary *data = [parser retrieveGamesWithAccount:self
                                                    error:&error];
    
    if (data)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              managedObjectContext, @"context", 
                              data, @"data", nil];
        
        [self performSelectorOnMainThread:@selector(retrievedGamesWithObjects:) 
                               withObject:dict
                            waitUntilDone:YES];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(retrieveFailedWithError:) 
                               withObject:error
                            waitUntilDone:YES];
    }
    
    [self performSelectorOnMainThread:@selector(syncCompleted) 
                           withObject:nil
                        waitUntilDone:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BACHGamesSynced 
                                                        object:self
                                                      userInfo:nil];
    
    [pool release];
    
    self.isSyncingGames = NO;
}

-(void)retrievedGamesWithObjects:(NSDictionary*)objects
{
    NSManagedObjectContext *context = [objects objectForKey:@"context"];
    NSDictionary *data = [objects objectForKey:@"data"];
    
    XboxLiveParser *parser = [[XboxLiveParser alloc] initWithManagedObjectContext:context];
    [parser synchronizeGamesWithAccount:self
                    withRetrievedObject:data
                                  error:nil]; // TODO: error?
    [parser release];
}

-(void)retrieveFailedWithError:(NSError*)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DataError", @"") 
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
}

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[XboxLiveAccount class]])
        return NO;
    
    return [self isEqualToAccount:object];
}

-(BOOL)isEqualToAccount:(XboxLiveAccount*)account
{
    return [self.uuid isEqualToString:account.uuid];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@ (UUID %@)", 
            self.emailAddress, self.uuid];
}

#pragma mark Helpers

-(NSString*)keyForPreference:(NSString*)preference
{
    return [NSString stringWithFormat:@"%@.%@", self.uuid, preference];
}

#pragma mark Constructor, destructor

+(id)preferencesForUuid:(NSString*)uuid 
{
    return [[[XboxLiveAccount alloc] initWithUuid:uuid] autorelease];
}

-(id)initWithUuid:(NSString*)uuid 
{
    if (self = [super init]) 
    {
        _uuid = [uuid copy];
        [self reload];
        
        self.isSyncingGames = NO;
    }
    
    return self;
}

-(id)init 
{
    if (self = [self initWithUuid:nil]) 
    {
    }
    
    return self;
}

-(void)dealloc 
{
    [self resetDirtyFlags];
    
    [_uuid release];
    _uuid = nil;
    
    self.lastGamesUpdate = nil;
    self.stalePeriodInSeconds = nil;
    self.emailAddress = nil;
    self.password = nil;
    self.screenName = nil;
    
    [super dealloc];
}

@end
