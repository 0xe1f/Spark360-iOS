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

@interface XboxLiveAccount (Private)

-(NSString*)keyForPreference:(NSString*)preference;
-(void)resetDirtyFlags;

@end

@implementation XboxLiveAccount
{
    NSString *_uuid;
    BOOL _canSendMessages;
    BOOL _canSendMessagesDirty;
    NSDate *_lastGamesUpdate;
    BOOL _lastGamesUpdateDirty;
    NSDate *_lastMessagesUpdate;
    BOOL _lastMessagesUpdateDirty;
    NSDate *_lastFriendsUpdate;
    BOOL _lastFriendsUpdateDirty;
    NSNumber *_stalePeriodInSeconds;
    BOOL _browseRefreshPeriodInSecondsDirty;
    NSString *_emailAddress;
    BOOL _emailAddressDirty;
    NSString *_password;
    BOOL _passwordDirty;
    NSString *_screenName;
    BOOL _screenNameDirty;
}

NSString * const KeychainPassword = @"com.akop.bach";

NSString * const StalePeriodKey = @"StalePeriod";
NSString * const ScreenNameKey = @"ScreenName";
NSString * const CanSendMessagesKey = @"CanSendMessages";
NSString * const GameLastUpdatedKey = @"GamesLastUpdated";
NSString * const MessagesLastUpdatedKey = @"MessagesLastUpdated";
NSString * const FriendsLastUpdatedKey = @"FriendsLastUpdated";
NSString * const CookiesKey = @"Cookies";

#define DEFAULT_BROWSING_REFRESH_TIMEOUT_SECONDS (60*30)

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
        self.lastMessagesUpdate = [prefs objectForKey:[self keyForPreference:MessagesLastUpdatedKey]];
        self.lastFriendsUpdate = [prefs objectForKey:[self keyForPreference:FriendsLastUpdatedKey]];
        self.stalePeriodInSeconds = [prefs objectForKey:[self keyForPreference:StalePeriodKey]];
        self.screenName = [prefs objectForKey:[self keyForPreference:ScreenNameKey]];
        self.canSendMessages = [[prefs objectForKey:[self keyForPreference:CanSendMessagesKey]] boolValue];
        
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
        if (!self.lastMessagesUpdate)
            self.lastMessagesUpdate = [NSDate distantPast];
        if (!self.lastFriendsUpdate)
            self.lastFriendsUpdate = [NSDate distantPast];
    }
}

-(void)purge
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:[self keyForPreference:GameLastUpdatedKey]];
    [prefs removeObjectForKey:[self keyForPreference:MessagesLastUpdatedKey]];
    [prefs removeObjectForKey:[self keyForPreference:FriendsLastUpdatedKey]];
    [prefs removeObjectForKey:[self keyForPreference:StalePeriodKey]];
    [prefs removeObjectForKey:[self keyForPreference:ScreenNameKey]];
    [prefs removeObjectForKey:[self keyForPreference:CanSendMessagesKey]];
    
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
        
        if (_lastMessagesUpdateDirty)
        {
            [prefs setObject:self.lastMessagesUpdate 
                      forKey:[self keyForPreference:MessagesLastUpdatedKey]];
        }
        
        if (_lastFriendsUpdateDirty)
        {
            [prefs setObject:self.lastFriendsUpdate 
                      forKey:[self keyForPreference:FriendsLastUpdatedKey]];
        }
        
        if (_canSendMessagesDirty)
        {
            [prefs setObject:[NSNumber numberWithBool:self.canSendMessages]
                      forKey:[self keyForPreference:CanSendMessagesKey]];
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
    _lastMessagesUpdateDirty = NO;
    _lastFriendsUpdateDirty = NO;
    _browseRefreshPeriodInSecondsDirty = NO;
    _emailAddressDirty = NO;
    _passwordDirty = NO;
    _screenNameDirty = NO;
    _canSendMessagesDirty = NO;
}

-(BOOL)canSendMessages
{
    return _canSendMessages;
}

-(void)setCanSendMessages:(BOOL)canSendMessages
{
    _canSendMessages = canSendMessages;
    _canSendMessagesDirty = YES;
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

-(NSDate*)lastMessagesUpdate
{
    return _lastMessagesUpdate;
}

-(void)setLastMessagesUpdate:(NSDate *)lastUpdate
{
    [lastUpdate retain];
    [_lastMessagesUpdate release];
    
    _lastMessagesUpdate = lastUpdate;
    _lastMessagesUpdateDirty = YES;
}

-(NSDate*)lastFriendsUpdate
{
    return _lastFriendsUpdate;
}

-(void)setLastFriendsUpdate:(NSDate *)lastUpdate
{
    [lastUpdate retain];
    [_lastFriendsUpdate release];
    
    _lastFriendsUpdate = lastUpdate;
    _lastFriendsUpdateDirty = YES;
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

-(BOOL)isDataStale:(NSDate*)lastRefreshed
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setSecond:-[self.stalePeriodInSeconds intValue]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *refreshDate = [gregorian dateByAddingComponents:comps 
                                                     toDate:[NSDate date] 
                                                    options:0];
    
    BOOL stale = ([lastRefreshed compare:refreshDate] == NSOrderedAscending);
    
    [comps release];
    [gregorian release];
    
    return stale;
}

-(BOOL)areGamesStale
{
    return [self isDataStale:self.lastGamesUpdate];
}

-(BOOL)areMessagesStale
{
    return [self isDataStale:self.lastMessagesUpdate];
}

-(BOOL)areFriendsStale
{
    return [self isDataStale:self.lastFriendsUpdate];
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
    self.lastMessagesUpdate = nil;
    self.lastFriendsUpdate = nil;
    self.stalePeriodInSeconds = nil;
    self.emailAddress = nil;
    self.password = nil;
    self.screenName = nil;
    
    [super dealloc];
}

@end
