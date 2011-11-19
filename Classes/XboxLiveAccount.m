//
//  XboxLiveAccountPreferences.m
//  BachZero
//
//  Created by Akop Karapetyan on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLiveAccount.h"
#import "KeychainItemWrapper.h"

@interface XboxLiveAccount (Private)

-(NSString*)keyForPreference:(NSString*)preference;
-(void)resetDirtyFlags;

@end

@implementation XboxLiveAccount
{
    NSString *_uuid;
    NSDate *_lastGamesUpdate;
    BOOL _lastGamesUpdateDirty;
    NSNumber *_browseRefreshPeriodInSeconds;
    BOOL _browseRefreshPeriodInSecondsDirty;
    NSString *_emailAddress;
    BOOL _emailAddressDirty;
    NSString *_password;
    BOOL _passwordDirty;
}

NSString * const KeychainPassword = @"com.akop.bach";

NSString * const BrowseTimeoutKey = @"BrowseTimeout:%@";
NSString * const GameLastUpdatedKey = @"GameLastUpdated:%@";
NSString * const CookiesKey = @"Cookies:%@";
NSString * const EmailAddressKey = @"EmailAddress:%@";

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
        
        self.lastGamesUpdate = [prefs objectForKey:[self keyForPreference:GameLastUpdatedKey]];
        self.browseRefreshPeriodInSeconds = [prefs objectForKey:[self keyForPreference:BrowseTimeoutKey]];
        
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:self.uuid
                                                                                serviceName:KeychainPassword
                                                                                accessGroup:nil];
        self.emailAddress = [keychainItem objectForKey:kSecAttrAccount];
        self.password = [keychainItem objectForKey:kSecValueData];
        [keychainItem release];
        
        [self resetDirtyFlags];
        
        if (!self.browseRefreshPeriodInSeconds)
            self.browseRefreshPeriodInSeconds = [NSNumber numberWithInt:DEFAULT_BROWSING_REFRESH_TIMEOUT_SECONDS];
        if (!self.lastGamesUpdate)
            self.lastGamesUpdate = [NSDate distantPast];
    }
}

-(void)purge
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:[self keyForPreference:GameLastUpdatedKey]];
    [prefs removeObjectForKey:[self keyForPreference:BrowseTimeoutKey]];
    
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
            [prefs setObject:self.browseRefreshPeriodInSeconds 
                      forKey:[self keyForPreference:BrowseTimeoutKey]];
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

-(NSNumber*)browseRefreshPeriodInSeconds
{
    return _browseRefreshPeriodInSeconds;
}

-(void)setBrowseRefreshPeriodInSeconds:(NSNumber*)browseRefreshPeriodInSeconds
{
    [browseRefreshPeriodInSeconds retain];
    [_browseRefreshPeriodInSeconds release];
    
    _browseRefreshPeriodInSeconds = browseRefreshPeriodInSeconds;
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
    [comps setSecond:-[self.browseRefreshPeriodInSeconds intValue]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *refreshDate = [gregorian dateByAddingComponents:comps 
                                                     toDate:[NSDate date] 
                                                    options:0];
    
    BOOL stale = ([self.lastGamesUpdate compare:refreshDate] == NSOrderedAscending);
    
    [comps release];
    [gregorian release];
    
    return stale;
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
    self.browseRefreshPeriodInSeconds = nil;
    self.emailAddress = nil;
    self.password = nil;
    
    [super dealloc];
}

@end
