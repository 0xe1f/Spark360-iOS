//
//  XboxLiveParser.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLiveParser.h"

#import "GTMNSString+HTML.h"
#import "GTMNSString+URLArguments.h"

#import "SBJson.h"

#define TIMEOUT_SECONDS 30

#define XBLPGet  (@"GET")
#define XBLPPost (@"POST")

NSString* const BachErrorDomain = @"com.akop.bach";

@interface XboxLiveParser (PrivateMethods)

- (NSString*)loadWithMethod:(NSString*)method
                        url:(NSString*)url 
                     fields:(NSDictionary*)fields
                 addHeaders:(NSDictionary*)headers
                     useXhr:(BOOL)useXhr
                      error:(NSError**)error;
- (NSString*)loadWithGET:(NSString*)url 
                  fields:(NSDictionary*)fields
                  useXhr:(BOOL)useXhr
                   error:(NSError**)error;
- (NSString*)loadWithPOST:(NSString*)url 
                   fields:(NSDictionary*)fields
                   useXhr:(BOOL)useXhr
                    error:(NSError**)error;

+(NSString*)getActionUrl:(NSString*)text;
+(NSMutableDictionary*)getInputs:(NSString*)response
                     namePattern:(NSRegularExpression*)namePattern;
+(NSDictionary*)jsonObjectFromLive:(NSString*)script
                             error:(NSError**)error;
+(NSDictionary*)jsonObjectFromPage:(NSString*)json
                                error:(NSError**)error;
+(NSNumber*)getStarRatingFromPage:(NSString*)html;

-(void)saveSessionForEmailAddress:(NSString*)emailAddress;
-(BOOL)restoreSessionForEmailAddress:(NSString*)emailAddress;
-(void)clearAllSessions;

-(BOOL)parseSynchronizeProfile:(NSMutableDictionary*)profile
                  emailAddress:(NSString*)emailAddress
                      password:(NSString*)password
                         error:(NSError**)error;
-(BOOL)parseSynchronizeGames:(NSMutableDictionary*)games
                emailAddress:(NSString*)emailAddress
                    password:(NSString*)password
                       error:(NSError**)error;

+(NSError*)errorWithCode:(NSInteger)code
                 message:(NSString*)message;
+(NSError*)errorWithCode:(NSInteger)code
         localizationKey:(NSString*)key;

-(NSString*)parseObtainNewToken;
+(NSDate*)getTicksFromJSONString:(NSString*)jsonTicks;

@end

@implementation XboxLiveParser

#define LOCALE (NSLocalizedString(@"Locale", nil))

NSString* const ErrorDomainAuthentication = @"Authentication";

NSString* const URL_LOGIN = @"http://login.live.com/login.srf?wa=wsignin1.0&wreply=%@";
NSString* const URL_LOGIN_MSN = @"https://msnia.login.live.com/ppsecure/post.srf?wa=wsignin1.0&wreply=%@";
NSString* const URL_VTOKEN = @"http://live.xbox.com/%@/Home";

NSString* const URL_GAMERCARD = @"http://gamercard.xbox.com/%@/%@.card";

NSString* const URL_JSON_PROFILE = @"http://live.xbox.com/Handlers/ShellData.ashx?culture=%@&XBXMChg=%i&XBXNChg=%i&XBXSPChg=%i&XBXChg=%i&leetcallback=jsonp1287728723001";
NSString* const URL_JSON_GAME_LIST = @"http://live.xbox.com/%@/Activity/Summary";
NSString* const REFERER_JSON_PROFILE = @"http://live.xbox.com/%@/MyXbox";

NSString* const URL_REPLY_TO = @"https://live.xbox.com/xweb/live/passport/setCookies.ashx";

NSString* const PATTERN_EXTRACT_JSON = @"^[^\\{]+(\\{.*\\})\\);?\\s*$";
NSString* const PATTERN_EXTRACT_TICKS = @"[^\\(]+\\((\\d+)\\)";

NSString* const PATTERN_GAMERCARD_REP = @"class=\"Star ([^\"]*)\"";

NSString* const PATTERN_LOGIN_LIVE_AUTH_URL = @"var\\s*srf_uPost\\s*=\\s*'([^']*)'";
NSString* const PATTERN_LOGIN_PPSX = @"var\\s*srf_sRBlob\\s*=\\s*'([^']*)'";
NSString* const PATTERN_LOGIN_ATTR_LIST = @"<input((\\s+\\w+=\"[^\"]*\")+)[^>]*>";
NSString* const PATTERN_LOGIN_GET_ATTRS = @"(\\w+)=\"([^\"]*)\"";
NSString* const PATTERN_LOGIN_ACTION_URL = @"action=\"(https?://[^\"]+)\"";

NSString* const PATTERN_GAMES = @"<div *class=\"LineItem\">(.*?)<br clear=\"all\" />";
NSString* const PATTERN_GAME_TITLE = @"<h3><a href=\"([^\"]*)\"[^>]*?>([^<]*)<";
NSString* const PATTERN_GAME_GAMERSCORE = @"GamerScore Stat\">\\s*(\\d+)\\s*\\/\\s*(\\d+)\\s*<";
NSString* const PATTERN_GAME_ACHIEVEMENTS = @"Achievement Stat\">\\s*(\\d+)\\s*\\/\\s*(\\d+)\\s*<";
NSString* const PATTERN_GAME_ACHIEVEMENT_URL = @"href=\"([^\"]*Achievements\\?titleId=(\\d+)[^\"]*)\"";
NSString* const PATTERN_GAME_BOXART_URL = @"src=\"([^\"]*)\" class=\"BoxShot\"";
NSString* const PATTERN_GAME_LAST_PLAYED = @"class=\"lastPlayed\">\\s*(\\S+)\\s*<";

-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(NSDictionary*)retrieveGamesWithEmailAddress:(NSString*)emailAddress
                                     password:(NSString*)password
                                        error:(NSError**)error
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Try restoring the session
    
    if (![self restoreSessionForEmailAddress:emailAddress])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticate:emailAddress
                   withPassword:password
                          error:error])
        {
            return nil;
        }
    }
    
    if (![self parseSynchronizeGames:dict
                        emailAddress:emailAddress
                            password:password
                               error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticate:emailAddress
                   withPassword:password
                          error:error])
        {
            return nil;
        }
        
        if (![self parseSynchronizeGames:dict
                            emailAddress:emailAddress
                                password:password
                                   error:error])
        {
            return nil;
        }
    }
    
    [self saveSessionForEmailAddress:emailAddress];
    
    return dict;
}

-(NSDictionary*)retrieveProfileWithEmailAddress:(NSString*)emailAddress
                                       password:(NSString*)password
                                          error:(NSError**)error;
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Try restoring the session
    
    if (![self restoreSessionForEmailAddress:emailAddress])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticate:emailAddress
                   withPassword:password
                          error:error])
        {
            return nil;
        }
    }
    
    if (![self parseSynchronizeProfile:dict
                          emailAddress:emailAddress
                              password:password
                                 error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticate:emailAddress
                   withPassword:password
                          error:error])
        {
            return nil;
        }
        
        if (![self parseSynchronizeProfile:dict
                              emailAddress:emailAddress
                                  password:password
                                     error:error])
        {
            return nil;
        }
    }
    
    [self saveSessionForEmailAddress:emailAddress];
    
    return dict;
}

-(BOOL)synchronizeProfileWithAccount:(XboxAccount*)account
                 withRetrievedObject:(NSDictionary*)dict
                               error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    id value;
    if ((value = [dict objectForKey:@"screenName"]))
        account.screenName = value;
    if ((value = [dict objectForKey:@"iconUrl"]))
        account.iconUrl = value;
    if ((value = [dict objectForKey:@"tier"]))
        account.tier = value;
    if ((value = [dict objectForKey:@"pointsBalance"]))
        account.pointsBalance = value;
    if ((value = [dict objectForKey:@"gamerscore"]))
        account.gamerscore = value;
    if ((value = [dict objectForKey:@"isGold"]))
        account.isGold = value;
    if ((value = [dict objectForKey:@"unreadMessages"]))
        account.unreadMessages = value;
    if ((value = [dict objectForKey:@"unreadNotifications"]))
        account.unreadNotifications = value;
    if ((value = [dict objectForKey:@"rep"]))
        account.rep = value;
    
    if (![[account managedObjectContext] save:nil])
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                   localizationKey:@"ErrorCouldNotSaveProfile"];
        }
        
        return NO;
    }
    
    NSLog(@"synchronizeProfileWithAccount: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(BOOL)synchronizeGamesWithAccount:(XboxAccount*)account
               withRetrievedObject:(NSDictionary*)dict
                             error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSDate *lastUpdated = [NSDate date];
    NSManagedObjectContext *context = [account managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxGame"
                                                         inManagedObjectContext:context];
    
    int newItems = 0;
    int existingItems = 0;
    int listOrder = 0;
    
    NSArray *gameDicts = [dict objectForKey:@"games"];
    
    for (NSDictionary *gameDict in gameDicts)
    {
        listOrder++;
        
        // Fetch game, or create a new one
        NSManagedObject *game;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND account == %@", 
                                  [gameDict objectForKey:@"uid"], account];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSArray *array = [context executeFetchRequest:request 
                                                error:nil];
        
        [request release];
        
        if (!(game = [array lastObject]))
        {
            newItems++;
            game = [NSEntityDescription 
                    insertNewObjectForEntityForName:@"XboxGame"
                    inManagedObjectContext:context];
            
            // These will not change, so just set them up the first time
            
            [game setValue:[gameDict objectForKey:@"uid"] forKey:@"uid"];
            [game setValue:account forKey:@"account"];
            [game setValue:[gameDict objectForKey:@"gameUrl"] forKey:@"gameUrl"];
            [game setValue:[gameDict objectForKey:@"title"] forKey:@"title"];
            [game setValue:[gameDict objectForKey:@"boxArtUrl"] forKey:@"boxArtUrl"];
            [game setValue:[NSNumber numberWithBool:YES] forKey:@"achievesDirty"];
        }
        else
        {
            existingItems++;
            if (![[game valueForKey:@"achievesUnlocked"] isEqualToNumber:[gameDict objectForKey:@"achievesUnlocked"]] ||
                ![[game valueForKey:@"achievesTotal"] isEqualToNumber:[gameDict objectForKey:@"achievesTotal"]] ||
                ![[game valueForKey:@"gamerScoreEarned"] isEqualToNumber:[gameDict objectForKey:@"gamerScoreEarned"]] ||
                ![[game valueForKey:@"gamerScoreTotal"] isEqualToNumber:[gameDict objectForKey:@"gamerScoreTotal"]])
            {
                [game setValue:[NSNumber numberWithBool:YES] forKey:@"achievesDirty"];
            }
        }
        
        // We now have a game object (new or existing)
        // Handle the rest of the data
        
        // Game achievements
        
        [game setValue:[gameDict objectForKey:@"achievesUnlocked"] forKey:@"achievesUnlocked"];
        [game setValue:[gameDict objectForKey:@"achievesTotal"] forKey:@"achievesTotal"];
        
        // Game score
        
        [game setValue:[gameDict objectForKey:@"gamerScoreEarned"] forKey:@"gamerScoreEarned"];
        [game setValue:[gameDict objectForKey:@"gamerScoreTotal"] forKey:@"gamerScoreTotal"];
        
        // Last played
        
        NSDate *lastPlayed = nil;
        if ([gameDict objectForKey:@"lastPlayed"] != [NSDate distantPast])
            lastPlayed = [gameDict objectForKey:@"lastPlayed"];
        
        [game setValue:lastPlayed forKey:@"lastPlayed"];
        [game setValue:lastUpdated forKey:@"lastUpdated"];
        [game setValue:[NSNumber numberWithInt:listOrder] forKey:@"listOrder"];
    }
    
    // Find "stale" games
    
    NSPredicate *stalePredicate = [NSPredicate predicateWithFormat:@"lastUpdated != %@ AND account == %@", 
    lastUpdated, account];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:stalePredicate];
    
    NSArray *staleObjs = [context executeFetchRequest:request 
                                                error:NULL];
    [request release];
    
    // Delete "stale" games
    
    for (NSManagedObject *staleObj in staleObjs)
        [context deleteObject:staleObj];
    
    // Save
    
    if (![context save:NULL])
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                   localizationKey:@"ErrorCouldNotSaveGameList"];
        }
        
        return NO;
    }
    
    NSLog(@"synchronizeGamesWithAccount: (%i new, %i existing) %.04fs", 
          newItems, existingItems, CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(BOOL)parseSynchronizeProfile:(NSMutableDictionary*)profile
                  emailAddress:(NSString*)emailAddress
                      password:(NSString*)password
                         error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    int ticks = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *url = [NSString stringWithFormat:URL_JSON_PROFILE, 
                     LOCALE, ticks, ticks, ticks, ticks];
    NSString *referer = [NSString stringWithFormat:REFERER_JSON_PROFILE, LOCALE];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             referer, @"Referer",
                             nil];
    
    NSString *jsonPage = [self loadWithMethod:XBLPGet
                                          url:url
                                       fields:nil
                                   addHeaders:headers
                                       useXhr:YES
                                        error:error];
    
    if (!jsonPage)
        return NO;
    
    NSDictionary *object = [XboxLiveParser jsonObjectFromLive:jsonPage
                                                        error:error];
    
    if (!object)
        return NO;
    
    NSString *gamertag = [object objectForKey:@"gamertag"];
    
    [profile setObject:gamertag forKey:@"screenName"];
    [profile setObject:[object objectForKey:@"gamerpic"] forKey:@"iconUrl"];
    [profile setObject:[object objectForKey:@"tiertext"] forKey:@"tier"];
    
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"pointsbalancetext"] intValue]] forKey:@"pointsBalance"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"gamerscore"] intValue]] forKey:@"gamerscore"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"tier"] intValue] >= 6] forKey:@"isGold"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"messages"] intValue]] forKey:@"unreadMessages"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"notifications"] intValue]] forKey:@"unreadNotifications"];
    
    url = [NSString stringWithFormat:URL_GAMERCARD, LOCALE,
           [gamertag gtm_stringByEscapingForURLArgument]];
    
    NSString *cardPage = [self loadWithGET:url
                                    fields:nil
                                    useXhr:NO
                                     error:nil];
    
    // An error for rep not fatal, so we ignore them
    if (cardPage)
    {
        [profile setObject:[XboxLiveParser getStarRatingFromPage:cardPage] forKey:@"rep"];
    }
    
    NSLog(@"parseSynchronizeProfile: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(BOOL)parseSynchronizeGames:(NSMutableDictionary*)games
                emailAddress:(NSString*)emailAddress
                    password:(NSString*)password
                       error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self parseObtainNewToken];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_GAME_LIST, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObject:vtoken 
                                                       forKey:@"__RequestVerificationToken"];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSDictionary *data = [XboxLiveParser jsonObjectFromPage:page
                                                      error:error];
    
    if (!data)
        return NO;
    
    NSMutableArray *gameList = [[[NSMutableArray alloc] init] autorelease];
    [games setObject:gameList 
              forKey:@"games"];
    
    NSString *gamertag = [data objectForKey:@"CurrentGamertag"];
    NSArray *jsonGames = [data objectForKey:@"Games"];
    
    if (jsonGames)
    {
        for (NSDictionary *jsonGame in jsonGames)
        {
            NSDictionary *progRoot = [jsonGame objectForKey:@"Progress"];
            NSDictionary *progress = [progRoot objectForKey:gamertag];
            
            if (!progress)
                continue;
            
            NSDate *lastPlayed = [XboxLiveParser getTicksFromJSONString:[progress objectForKey:@"LastPlayed"]];
            
            NSMutableArray *objects = [[[NSMutableArray alloc] init] autorelease];
            
            [objects addObject:[[jsonGame objectForKey:@"Id"] stringValue]];
            [objects addObject:[progress objectForKey:@"Achievements"]];
            [objects addObject:[jsonGame objectForKey:@"PossibleAchievements"]];
            [objects addObject:[progress objectForKey:@"Score"]];
            [objects addObject:[jsonGame objectForKey:@"PossibleScore"]];
            [objects addObject:lastPlayed];
            [objects addObject:[jsonGame objectForKey:@"Url"]];
            [objects addObject:[jsonGame objectForKey:@"Name"]];
            [objects addObject:[jsonGame objectForKey:@"BoxArt"]];
            
            NSArray *keys = [NSArray arrayWithObjects:
                             @"uid",
                             @"achievesUnlocked",
                             @"achievesTotal",
                             @"gamerScoreEarned",
                             @"gamerScoreTotal",
                             @"lastPlayed",
                             @"gameUrl",
                             @"title",
                             @"boxArtUrl",
                             nil];
            
            [gameList addObject:[NSDictionary dictionaryWithObjects:objects
                                                            forKeys:keys]];
        }
    }
    
    // TODO: beacons
    
    NSLog(@"parseSynchronizeGames: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *lastUpdatedKey = [NSString stringWithFormat:@"LastUpdated:%@", emailAddress];
    [prefs setObject:[NSDate date] forKey:lastUpdatedKey];
    
    return YES;
}

#pragma mark Authentication, sessions

-(void)clearAllSessions
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    
    for (NSHTTPCookie *cookie in cookies)
        [cookieStorage deleteCookie:cookie];
}

-(BOOL)restoreSessionForEmailAddress:(NSString*)emailAddress
{
    NSLog(@"Restoring session for %@...", emailAddress);
    
    [self clearAllSessions];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSString *cookieKey = [NSString stringWithFormat:@"Cookies:%@", emailAddress];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:cookieKey];
    
    if (!data || [data length] <= 0)
        return NO;
    
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!cookies)
        return NO;
    
    for (NSHTTPCookie *cookie in cookies)
        [cookieStorage setCookie:cookie];
    
    return YES;
}

-(void)saveSessionForEmailAddress:(NSString*)emailAddress
{
    NSLog(@"Saving session for %@...", emailAddress);
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSString *cookieKey = [NSString stringWithFormat:@"CookiesFor", emailAddress];
    NSArray *cookies = [cookieStorage cookies];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([cookies count] > 0)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
        [prefs setObject:data 
                  forKey:cookieKey];
    }
    
    [prefs synchronize];
}

+(NSError*)errorWithCode:(NSInteger)code
                 message:(NSString*)message
{
    NSDictionary *info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:message]
                                                     forKeys:[NSArray arrayWithObject:NSLocalizedDescriptionKey]];
    
    return [NSError errorWithDomain:BachErrorDomain
                               code:code
                           userInfo:info];
}

+(NSError*)errorWithCode:(NSInteger)code
         localizationKey:(NSString*)key
{
    return [self errorWithCode:code
                       message:NSLocalizedString(key, nil)];
}

-(BOOL)authenticate:(NSString*)emailAddress
       withPassword:(NSString*)password
              error:(NSError**)error
{
    [self clearAllSessions];
    
    NSLog(@"Authenticating...");
    
    BOOL isMsn = [emailAddress hasSuffix:@"@msn.com"];
    NSString *url = [NSString stringWithFormat:isMsn ? URL_LOGIN_MSN : URL_LOGIN, 
                     URL_REPLY_TO];
    
    NSTextCheckingResult *match;
    
    NSString *loginPage = [self loadWithGET:url
                                     fields:nil
                                     useXhr:NO
                                      error:error];
    
    if (!loginPage)
        return NO;
    
    NSRegularExpression *getLiveAuthUrl = [NSRegularExpression regularExpressionWithPattern:PATTERN_LOGIN_LIVE_AUTH_URL
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:NULL];
    
    match = [getLiveAuthUrl firstMatchInString:loginPage
                                       options:0
                                         range:NSMakeRange(0, [loginPage length])];
    
    if (!match)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorLoginStageOne"];
        }
        
        NSLog(@"Authentication failed in stage 1: URL");
        return NO;
    }
    
    NSString *postUrl = [loginPage substringWithRange:[match rangeAtIndex:1]];
    
    if (isMsn)
        postUrl = [postUrl stringByReplacingOccurrencesOfString:@"://login.live.com/" 
                                                     withString:@"://msnia.login.live.com/"];
    
    NSRegularExpression *getPpsxValue = [NSRegularExpression regularExpressionWithPattern:PATTERN_LOGIN_PPSX
                                                                                  options:0
                                                                                    error:NULL];
    
    match = [getPpsxValue firstMatchInString:loginPage
                                     options:0
                                       range:NSMakeRange(0, [loginPage length])];
    
    if (!match)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorLoginStageOne"];
        }
        
        NSLog(@"Authentication failed in stage 1: PPSX");
        return NO;
    }
    
    NSString *ppsx = [loginPage substringWithRange:[match rangeAtIndex:1]];
    
    NSMutableDictionary *inputs = [XboxLiveParser getInputs:loginPage
                                                namePattern:nil];
    
    [inputs setValue:emailAddress forKey:@"login"];
    [inputs setValue:password forKey:@"passwd"];
    [inputs setValue:@"1" forKey:@"LoginOptions"];
    [inputs setValue:ppsx forKey:@"PPSX"];
    
    NSString *loginResponse = [self loadWithPOST:postUrl
                                          fields:inputs
                                          useXhr:NO
                                           error:error];
    
    if (!loginResponse)
        return NO;
    
    NSString *redirUrl = [XboxLiveParser getActionUrl:loginResponse];
    
    inputs = [XboxLiveParser getInputs:loginResponse
                           namePattern:nil];
    
    if (![inputs objectForKey:@"ANON"])
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPAuthenticationError
                                   localizationKey:@"ErrorLoginInvalidCredentials"];
        }
        
        NSLog(@"Authentication failed in stage 2");
        return NO;
    }
    
    if (![self loadWithPOST:redirUrl
                     fields:inputs
                     useXhr:NO
                      error:error])
    {
        return NO;
    }
    
    [self saveSessionForEmailAddress:emailAddress];
    
    return YES;
}

#pragma mark Helpers

+(NSNumber*)getStarRatingFromPage:(NSString*)html
{
    NSArray *starClasses = [NSArray arrayWithObjects:@"empty", @"quarter", 
                            @"half", @"threequarter", @"full", nil];
    NSRegularExpression *starMatcher = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAMERCARD_REP
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    
    __block NSUInteger rating = 0;
    [starMatcher enumerateMatchesInString:html 
                                  options:0
                                    range:NSMakeRange(0, [html length])
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) 
     {
         NSString *starClass = [html substringWithRange:[result rangeAtIndex:1]];
         NSUInteger starValue = [starClasses indexOfObject:[starClass lowercaseString]];
         
         if (starValue != NSNotFound)
             rating += starValue;
     }];
    
    return [NSNumber numberWithUnsignedInteger:rating];
}

+(NSDictionary*)jsonObjectFromPage:(NSString*)json
                             error:(NSError**)error
{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:json 
                                            error:nil];
    [parser release];
    
    if (!dict)
    {
        if (error)
        {
            *error = [self errorWithCode:XBLPParsingError
                         localizationKey:@"ErrorParsingJSONFormat"];
        }
        
        return nil;
    }
    
    if (![[dict objectForKey:@"Success"] boolValue])
    {
        if (error)
        {
            *error = [self errorWithCode:XBLPGeneralError
                         localizationKey:@"ErrorJSONDidNotSucceed"];
        }
        
        return nil;
    }
    
    return [dict objectForKey:@"Data"];
}

+(NSDate*)getTicksFromJSONString:(NSString*)jsonTicks
{
    if (!jsonTicks)
        return [NSDate distantPast];
    
    NSRegularExpression *extractJson = [NSRegularExpression
                                        regularExpressionWithPattern:PATTERN_EXTRACT_TICKS
                                        options:0
                                        error:nil];
    
    NSTextCheckingResult *match = [extractJson
                                   firstMatchInString:jsonTicks
                                   options:0
                                   range:NSMakeRange(0, [jsonTicks length])];
    
    if (!match)
        return [NSDate distantPast];
    
    NSString *ticks = [jsonTicks substringWithRange:[match rangeAtIndex:1]];
    return [NSDate dateWithTimeIntervalSince1970:([ticks doubleValue]/1000.0)];
}

+(NSDictionary*)jsonObjectFromLive:(NSString*)script
                             error:(NSError**)error
{
    NSRegularExpression *extractJson = [NSRegularExpression
                                        regularExpressionWithPattern:PATTERN_EXTRACT_JSON
                                        options:0
                                        error:nil];
    
    NSTextCheckingResult *match = [extractJson
                                   firstMatchInString:script
                                   options:0
                                   range:NSMakeRange(0, [script length])];
    
    if (!match)
    {
        if (error)
        {
            *error = [self errorWithCode:XBLPParsingError
                         localizationKey:@"ErrorParsingJSONFormat"];
        }
        
        return nil;
    }
    
    NSString *json = [script substringWithRange:[match rangeAtIndex:1]];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:json 
                                            error:nil];
    [parser release];
    
    return dict;
}

+(NSString*)getActionUrl:(NSString*)text
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_LOGIN_ACTION_URL
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:text
                                                    options:0
                                                      range:NSMakeRange(0, [text length])];
    
    if (match)
        return [text substringWithRange:[match rangeAtIndex:1]];
    
    return nil;
}

+(NSMutableDictionary*)getInputs:(NSString*)response
                     namePattern:(NSRegularExpression*)namePattern
{
    NSMutableDictionary *inputs = [[NSMutableDictionary alloc] init];
    
    NSError *error = nil;
    NSRegularExpression *allAttrs = [NSRegularExpression regularExpressionWithPattern:PATTERN_LOGIN_ATTR_LIST
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:&error];
    
    NSRegularExpression *attrs = [NSRegularExpression regularExpressionWithPattern:PATTERN_LOGIN_GET_ATTRS
                                                                           options:0
                                                                             error:&error];
    
    [allAttrs enumerateMatchesInString:response 
                               options:0
                                 range:NSMakeRange(0, [response length])
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) 
     {
         __block NSString *name = nil;
         __block NSString *value = nil;
         
         NSString *chunk = [response substringWithRange:[result rangeAtIndex:1]];
         
         [attrs enumerateMatchesInString:chunk 
                                 options:0
                                   range:NSMakeRange(0, [chunk length])
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) 
          {
              NSString *attrName = [chunk substringWithRange:[result rangeAtIndex:1]];
              NSString *attrValue = [chunk substringWithRange:[result rangeAtIndex:2]];
              
              if ([attrName caseInsensitiveCompare:@"name"] == NSOrderedSame)
                  name = attrValue;
              else if ([attrName caseInsensitiveCompare:@"value"] == NSOrderedSame)
                  value = attrValue;
          }];
         
         if (name != nil && value != nil)
         {
             BOOL add = true;
             
             if (namePattern != nil)
             {
                 NSTextCheckingResult *match = [namePattern firstMatchInString:name
                                                                       options:0
                                                                         range:NSMakeRange(0, [name length])];
                 
                 if (!match)
                     add = false;
             }
             
             if (add)
             {
                 for (NSString *key in inputs)
                 {
                     if ([key isEqualToString:name])
                     {
                         add = false;
                         break;
                     }
                 }
             }
             
             if (add)
                 [inputs setValue:value 
                           forKey:name];
         }
     }];
    
    return [inputs autorelease];
}

-(NSString*)parseObtainNewToken
{
    NSString *page = [self loadWithGET:[NSString stringWithFormat:URL_VTOKEN, LOCALE]
                                fields:nil
                                useXhr:NO
                                 error:NULL];
    
    if (!page)
        return nil;
    
    NSMutableDictionary *inputs = [XboxLiveParser getInputs:page
                                                namePattern:nil];
    
    if (!inputs)
        return nil;
    
    return [inputs objectForKey:@"__RequestVerificationToken"];
}

#pragma mark Core stuff

- (NSString*)loadWithMethod:(NSString*)method
                        url:(NSString*)requestUrl
                     fields:(NSDictionary*)fields
                 addHeaders:(NSDictionary*)headers
                     useXhr:(BOOL)useXhr
                      error:(NSError**)error
{
    NSString *httpBody = nil;
    NSURL *url = [NSURL URLWithString:requestUrl];
    
    if (fields)
    {
        NSMutableArray *urlBuilder = [[NSMutableArray alloc] init];
        
        for (NSString *key in fields)
        {
            NSString *ueKey = [key gtm_stringByEscapingForURLArgument];
            NSString *ueValue = [[fields objectForKey:key] gtm_stringByEscapingForURLArgument];
            
            [urlBuilder addObject:[NSString stringWithFormat:@"%@=%@", ueKey, ueValue]];
        }
        
        httpBody = [urlBuilder componentsJoinedByString:@"&"];
        [urlBuilder release];
    }
    
    NSUInteger bodyLength = [httpBody lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *allHeaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"text/javascript, text/html, application/xml, text/xml, */*", @"Accept",
                                       @"ISO-8859-1,utf-8;q=0.7,*;q=0.7", @"Accept-Charset",
                                       [NSString stringWithFormat:@"%d", bodyLength], @"Content-Length",
                                       @"application/x-www-form-urlencoded", @"Content-Type",
                                       nil];
    
    if (useXhr)
    {
        [allHeaders setObject:@"XMLHttpRequest" 
                       forKey:@"X-Requested-With"];
    }
    
    if (headers)
    {
        for (NSString *header in headers)
            [allHeaders setObject:[headers objectForKey:header] 
                           forKey:header];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:TIMEOUT_SECONDS];
    
    [request setHTTPMethod:method];
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setAllHTTPHeaderFields:allHeaders];
    
    NSURLResponse *response = nil;
    NSError *netError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&netError];
    
    if (!data)
    {
        if (error && netError)
        {
            *error = [XboxLiveParser errorWithCode:XBLPNetworkError
                                           message:[netError localizedDescription]];
        }
        
        return nil;
    }
    
    return [[[NSString alloc] initWithData:data 
                                  encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString*)loadWithGET:(NSString*)url 
                  fields:(NSDictionary*)fields
                  useXhr:(BOOL)useXhr
                   error:(NSError**)error
{
    return [self loadWithMethod:@"GET"
                            url:url
                         fields:fields
                     addHeaders:nil
                         useXhr:useXhr
                          error:error];
}

- (NSString*)loadWithPOST:(NSString*)url 
                   fields:(NSDictionary*)fields
                   useXhr:(BOOL)useXhr
                    error:(NSError**)error
{
    return [self loadWithMethod:@"POST"
                            url:url
                         fields:fields
                     addHeaders:nil
                           useXhr:useXhr
                          error:error];
}

@end
