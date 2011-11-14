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

NSString* const BachErrorDomain = @"com.akop.bach";

@interface XboxLiveParser (PrivateMethods)

- (NSString*)loadWithMethod:(NSString*)method
                        url:(NSString*)url 
                     fields:(NSDictionary*)fields
                 addHeaders:(NSDictionary*)headers
                      error:(NSError**)error;
- (NSString*)loadWithGET:(NSString*)url 
                  fields:(NSDictionary*)fields
                   error:(NSError**)error;
- (NSString*)loadWithPOST:(NSString*)url 
                   fields:(NSDictionary*)fields
                    error:(NSError**)error;

+(NSString*)getActionUrl:(NSString*)text;
+(NSDate*)parseDate:(NSString*)dateStr;
+(NSString*)getUniversalIcon:(NSString*)icon;
+(NSMutableDictionary*)getInputs:(NSString*)response
                     namePattern:(NSRegularExpression*)namePattern;
+(NSDictionary*)jsonObjectFromLive:(NSString*)script
                             error:(NSError**)error;
+(NSNumber*)getStarRatingFromPage:(NSString*)html;

-(void)saveSessionForEmailAddress:(NSString*)emailAddress;
-(BOOL)restoreSessionForEmailAddress:(NSString*)emailAddress;
-(void)clearAllSessions;

//-(BOOL)parseSynchronizeAccount:(XboxAccount*)account;
-(BOOL)parseSynchronizeGames:(XboxAccount*)account;

-(BOOL)parseSynchronizeProfile:(NSMutableDictionary*)profile
                  emailAddress:(NSString*)emailAddress
                      password:(NSString*)password
                         error:(NSError**)error;

+(NSError*)errorWithCode:(NSInteger)code
                 message:(NSString*)message;
+(NSError*)errorWithCode:(NSInteger)code
         localizationKey:(NSString*)key;

@end

@implementation XboxLiveParser

#define LOCALE (NSLocalizedString(@"Locale", nil))

NSString* const ErrorDomainAuthentication = @"Authentication";

NSString* const URL_GAMES = @"http://live.xbox.com/%@/GameCenter";
NSString* const URL_LOGIN = @"http://login.live.com/login.srf?wa=wsignin1.0&wreply=%@";
NSString* const URL_LOGIN_MSN = @"https://msnia.login.live.com/ppsecure/post.srf?wa=wsignin1.0&wreply=%@";

NSString* const URL_GAMERCARD = @"http://gamercard.xbox.com/%@/%@.card";

NSString* const URL_JSON_PROFILE = @"http://live.xbox.com/Handlers/ShellData.ashx?culture=%@&XBXMChg=%i&XBXNChg=%i&XBXSPChg=%i&XBXChg=%i&leetcallback=jsonp1287728723001";
NSString* const REFERER_JSON_PROFILE = @"http://live.xbox.com/%@/MyXbox";

NSString* const URL_REPLY_TO = @"https://live.xbox.com/xweb/live/passport/setCookies.ashx";

NSString* const PATTERN_EXTRACT_JSON = @"^[^\\{]+(\\{.*\\})\\);?\\s*$";

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

/*
-(void)synchronizeGames:(XboxAccount*)account
{
    // Try restoring the session
    
    if (![self restoreSessionForEmailAddress:account.emailAddress])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticate:account.emailAddress
                   withPassword:account.password])
        {
            // Authentication failed. Critical
            // TODO: FAIL
        }
    }
    
    if (![self parseSynchronizeGames:account])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticate:account.emailAddress
                   withPassword:account.password])
        {
            // Re-authentication failed. Critical
            // TODO: FAIL
        }
        
        if (![self parseSynchronizeGames:account])
        {
            // Account parsing failed. Critical
            // TODO: FAIL
        }
    }
    
    [self saveSessionForEmailAddress:account.emailAddress];
}
*/

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

-(void)synchronizeProfileWithAccount:(XboxAccount*)account
      withRetrievedObject:(NSDictionary*)dict
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
    
    NSLog(@"synchronizeProfileWithAccount: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
}

-(BOOL)parseSynchronizeProfile:(NSMutableDictionary*)profile
                  emailAddress:(NSString*)emailAddress
                      password:(NSString*)password
                         error:(NSError**)error
{
    int ticks = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *url = [NSString stringWithFormat:URL_JSON_PROFILE, 
                     LOCALE, ticks, ticks, ticks, ticks];
    NSString *referer = [NSString stringWithFormat:REFERER_JSON_PROFILE, LOCALE];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             referer, @"Referer",
                             @"XMLHttpRequest", @"X-Requested-With", 
                             nil];
    
    NSString *jsonPage = [self loadWithMethod:@"GET"
                                          url:url
                                       fields:nil
                                   addHeaders:headers
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
                                     error:nil];
    
    // An error for rep not fatal, so we ignore them
    if (cardPage)
    {
        [profile setObject:[XboxLiveParser getStarRatingFromPage:cardPage] forKey:@"rep"];
    }
    
    return YES;
}

-(BOOL)parseSynchronizeGames:(XboxAccount*)account
{
    /*
    NSString *url = [NSString stringWithFormat:URL_GAMES, LOCALE];
    NSString *page = [self loadWithGET:url
                                fields:nil
                                 error:error];
    
    if (!page)
        return NO;
    
    NSRegularExpression *regex = [NSRegularExpression 
                                  regularExpressionWithPattern:PATTERN_GAMES
                                  options:NSRegularExpressionDotMatchesLineSeparators
                                  error:nil];
    
    NSRegularExpression *findGameTitle = [NSRegularExpression
                                          regularExpressionWithPattern:PATTERN_GAME_TITLE
                                          options:0
                                          error:nil];
    NSRegularExpression *findGameAchUrl = [NSRegularExpression
                                           regularExpressionWithPattern:PATTERN_GAME_ACHIEVEMENT_URL
                                           options:0
                                           error:nil];
    NSRegularExpression *findGameBoxArtUrl = [NSRegularExpression
                                              regularExpressionWithPattern:PATTERN_GAME_BOXART_URL
                                              options:0
                                              error:nil];
    
    NSRegularExpression *findGameScore = [NSRegularExpression
                                          regularExpressionWithPattern:PATTERN_GAME_GAMERSCORE
                                          options:0
                                          error:nil];
    NSRegularExpression *findGameAchs = [NSRegularExpression
                                         regularExpressionWithPattern:PATTERN_GAME_ACHIEVEMENTS
                                         options:0
                                         error:nil];
    
    NSRegularExpression *findGameLastPlayed = [NSRegularExpression
                                               regularExpressionWithPattern:PATTERN_GAME_LAST_PLAYED
                                               options:0
                                               error:nil];
    
    NSManagedObjectContext *context = [account managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxGame"
                                                         inManagedObjectContext:context];
    
    __block int listOrder = 0;
    NSDate *lastUpdated = [NSDate date];
    
    // TODO: error check
    [regex enumerateMatchesInString:page 
                            options:0
                              range:NSMakeRange(0, [page length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) 
     {
         
         listOrder++;
         
         // Isolate the game section
         NSString *gameSection = [page substringWithRange:[result rangeAtIndex:1]];
         
         // Find the ach. URL (and therefore game UID)
         NSTextCheckingResult *match;
         match = [findGameAchUrl 
                  firstMatchInString:gameSection
                  options:0
                  range:NSMakeRange(0, [gameSection length])];
         
         if (!match)
             return;
         
         NSString *uid = [gameSection substringWithRange:[match rangeAtIndex:2]];
         
         // Fetch game, or create a new one
         NSManagedObject *game;
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND account == %@", 
                                   uid, account];
         
         NSFetchRequest *request = [[NSFetchRequest alloc] init];
         [request setEntity:entityDescription];
         [request setPredicate:predicate];
         
         NSError *innerError = nil;
         NSArray *array = [context executeFetchRequest:request 
                                                 error:&innerError];
         [request release];
         
         // If no such game exists, create a new one
         if (!(game = [array lastObject]))
         {
             game = [NSEntityDescription 
                     insertNewObjectForEntityForName:@"XboxGame"
                     inManagedObjectContext:context];
             
             // These will not change, so just set them up the first time
             
             [game setValue:uid forKey:@"uid"];
             [game setValue:account forKey:@"account"];
             
             match = [findGameTitle 
                      firstMatchInString:gameSection
                      options:0
                      range:NSMakeRange(0, [gameSection length])];
             
             if (match)
             {
                 NSString *gameUrl = [gameSection substringWithRange:[match rangeAtIndex:1]];
                 NSString *title = [[gameSection substringWithRange:[match rangeAtIndex:2]] gtm_stringByUnescapingFromHTML];
                 
                 [game setValue:gameUrl forKey:@"gameUrl"];
                 [game setValue:title forKey:@"title"];
             }
             
             match = [findGameBoxArtUrl
                      firstMatchInString:gameSection
                      options:0
                      range:NSMakeRange(0, [gameSection length])];
             
             if (match)
             {
                 NSString *boxArtUrl = [gameSection substringWithRange:[match rangeAtIndex:1]];
                 
                 [game setValue:[XboxLiveParser getUniversalIcon:boxArtUrl] 
                         forKey:@"boxArtUrl"];
             }
         }
         
         // We now have a game object (new or existing)
         // Handle the rest of the data
         
         // Game achievements
         
         match = [findGameAchs
                  firstMatchInString:gameSection
                  options:0
                  range:NSMakeRange(0, [gameSection length])];
         
         int achUnlocked = 0;
         int achTotal = 0;
         
         if (match)
         {
             achUnlocked = [[gameSection substringWithRange:[match rangeAtIndex:1]] intValue];
             achTotal = [[gameSection substringWithRange:[match rangeAtIndex:2]] intValue];
         }
         
         [game setValue:[NSNumber numberWithInt:achUnlocked] forKey:@"achievesUnlocked"];
         [game setValue:[NSNumber numberWithInt:achTotal] forKey:@"achievesTotal"];
         
         // Game score
         
         match = [findGameScore
                  firstMatchInString:gameSection
                  options:0
                  range:NSMakeRange(0, [gameSection length])];
         
         int scoreAcquired = 0;
         int scoreTotal = 0;
         
         if (match)
         {
             scoreAcquired = [[gameSection substringWithRange:[match rangeAtIndex:1]] intValue];
             scoreTotal = [[gameSection substringWithRange:[match rangeAtIndex:2]] intValue];
         }
         
         [game setValue:[NSNumber numberWithInt:scoreAcquired] forKey:@"gamerScoreEarned"];
         [game setValue:[NSNumber numberWithInt:scoreTotal] forKey:@"gamerScoreTotal"];
         
         // Last played
         
         match = [findGameLastPlayed
                  firstMatchInString:gameSection
                  options:0
                  range:NSMakeRange(0, [gameSection length])];
         
         NSDate *lastPlayed = nil;
         
         if (match)
             lastPlayed = [XboxLiveParser parseDate:[gameSection substringWithRange:[match rangeAtIndex:1]]];
         
         [game setValue:lastPlayed forKey:@"lastPlayed"];
         [game setValue:lastUpdated forKey:@"lastUpdated"];
         [game setValue:[NSNumber numberWithInt:listOrder] forKey:@"listOrder"];
    }];
    
    // Find "stale" games
    
    NSPredicate *stalePredicate = [NSPredicate predicateWithFormat:@"lastUpdated != %@ AND account == %@", 
                                   lastUpdated, account];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:stalePredicate];
    
    NSError *innerError = nil;
    NSArray *staleObjs = [context executeFetchRequest:request 
                                                error:&innerError];
    [request release];
    
    // Delete "stale" games
    
    for (NSManagedObject *staleObj in staleObjs)
        [context deleteObject:staleObj];
    
    // Save
    
    if (![context save:&innerError])
    {
        NSLog(@"parseSynchronizeGames: save failed");
        return NO; // TODO: 
    }
    */
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
    NSString *cookieKey = [NSString stringWithFormat:@"CookiesFor", emailAddress];
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

+(NSDate*)parseDate:(NSString*)dateStr
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    [dateFormatter release];
    
    return date;
}

+(NSString*)getUniversalIcon:(NSString*)icon
{
    if (!icon)
        return nil;
    
    return icon; // TODO!
    /*
     private static final Pattern PATTERN_LOADBAL_ICON = Pattern
     .compile("^http://([0-9\\.]+/)");
     
     Matcher m;
     if (!(m = PATTERN_LOADBAL_ICON.matcher(loadBalIcon)).find())
     return loadBalIcon;
     
     String replacement = loadBalIcon.substring(0, m.start(1))
     + loadBalIcon.substring(m.end(1));
     
     return replacement;
     */
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

#pragma mark Core stuff

- (NSString*)loadWithMethod:(NSString*)method
                        url:(NSString*)requestUrl
                     fields:(NSDictionary*)fields
                 addHeaders:(NSDictionary*)headers
                      error:(NSError**)error
{
    NSString *httpBody = nil;
    NSURL *url = [NSURL URLWithString:requestUrl];
    
    if (fields)
    {
        NSMutableArray *urlBuilder = [[NSMutableArray alloc] init];
        
        for (NSString *key in fields)
        {
            NSString *ueKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *ueValue = [[fields objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
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
                   error:(NSError**)error
{
    return [self loadWithMethod:@"GET"
                            url:url
                         fields:fields
                     addHeaders:nil
                          error:error];
}

- (NSString*)loadWithPOST:(NSString*)url 
                   fields:(NSDictionary*)fields
                    error:(NSError**)error
{
    return [self loadWithMethod:@"POST"
                            url:url
                         fields:fields
                     addHeaders:nil
                          error:error];
}

@end
