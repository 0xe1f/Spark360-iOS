//
//  XboxLiveParser.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GTMNSString+HTML.h"
#import "XboxLiveParser.h"

@interface XboxLiveParser (PrivateMethods)

+(NSString*)getActionUrl:(NSString*)text;
+(NSDate*)parseDate:(NSString*)dateStr;
+(NSString*)getUniversalIcon:(NSString*)icon;
+(NSMutableDictionary*)getInputs:(NSString*)response
                     namePattern:(NSRegularExpression*)namePattern;

@end

@implementation XboxLiveParser

NSString* const URL_GAMES = @"http://www.akop.org/xtest/games.html";
NSString* const URL_LOGIN = @"http://login.live.com/login.srf?wa=wsignin1.0&wreply=%@";
NSString* const URL_LOGIN_MSN = @"https://msnia.login.live.com/ppsecure/post.srf?wa=wsignin1.0&wreply=%@";

/*
NSString* const URL_JSON_PROFILE = @"http://live.xbox.com/Handlers/ShellData.ashx?culture=%@&XBXMChg=%2$d&XBXNChg=%2$d&XBXSPChg=%2$d&XBXChg=%2$d" + 
@"&leetcallback=jsonp1287728723001";
*/
NSString* const URL_REPLY_TO = @"https://live.xbox.com/xweb/live/passport/setCookies.ashx";

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

-(void)synchronizeAccount:(XboxAccount*)account
              withContext:(NSManagedObjectContext*)context
{
    // TODO: reauth if expired!
    /*
    NSString *url = [NSString stringWithFormat:([account.username hasSuffix:@"@msn.com"]) 
                     ? URL_LOGIN_MSN : URL_LOGIN, URL_REPLY_TO];
    
    // Remove the authentication cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *array = [cookieStorage cookiesForURL:[NSURL URLWithString:url]];
    for (NSHTTPCookie *cookie in array)
        [cookieStorage deleteCookie:cookie];
    
    NSError *error = nil;
    NSTextCheckingResult *match;
    
    NSString *loginPage = [self loadWithGET:url
                                     fields:nil];
    */
}

/*
 private ContentValues parseSummaryData(XboxLiveAccount account)
 throws ParserException, IOException
 {
 long started = System.currentTimeMillis();
 
 String url = String.format(URL_JSON_PROFILE, 
 mContext.getString(R.string.locale),
 System.currentTimeMillis());
 
 HttpUriRequest request = new HttpGet(url);
 request.addHeader("Referer", URL_JSON_PROFILE_REFERER);
 request.addHeader("X-Requested-With", "XMLHttpRequest");
 
 String page = getResponse(request);
 
 if (App.LOGV)
 started = displayTimeTaken("Profile page fetch", started);
 
 ContentValues cv = new ContentValues(15);
 
 String gamertag;
 JSONObject json = getJSONObject(page);
 
 try
 {
 gamertag = json.getString("gamertag");
 }
 catch(JSONException e)
 {
 throw new ParserException(mContext, 
 R.string.error_json_parser_error);
 }
 
 cv.put(Profiles.GAMERTAG, gamertag);
 cv.put(Profiles.ICON_URL, json.optString("gamerpic"));
 cv.put(Profiles.POINTS_BALANCE, json.optInt("pointsbalancetext"));
 cv.put(Profiles.IS_GOLD, json.optInt("tier") >= 6);
 cv.put(Profiles.TIER, json.optString("tiertext"));
 cv.put(Profiles.GAMERSCORE, json.optInt("gamerscore"));
 cv.put(Profiles.UNREAD_MESSAGES, json.optInt("messages"));
 cv.put(Profiles.UNREAD_NOTIFICATIONS, json.optInt("notifications"));
 
 url = getGamercardUrl(gamertag);
 
 try
 {
 page = getResponse(url);
 }
 catch(Exception e)
 {
 // Ignore errors - not vital
 page = null;
 if (App.LOGV)
 e.printStackTrace();
 }
 
 int rep = 0;
 String zone = null;
 
 if (page != null)
 {
 rep = getStarRating(page);
 }
 
 cv.put(Profiles.REP, rep);
 cv.put(Profiles.ZONE, zone);
 
 return cv;
 }
 */
-(BOOL)authenticateAccount:(XboxLiveAccount*)account
               withContext:(NSManagedObjectContext*)context
{
    NSString *url = [NSString stringWithFormat:([account.username hasSuffix:@"@msn.com"]) 
                     ? URL_LOGIN_MSN : URL_LOGIN, URL_REPLY_TO];
    
    // Remove the authentication cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *array = [cookieStorage cookiesForURL:[NSURL URLWithString:url]];
    for (NSHTTPCookie *cookie in array)
        [cookieStorage deleteCookie:cookie];
    
    NSError *error = nil;
    NSTextCheckingResult *match;
    
    NSString *loginPage = [self loadWithGET:url
                                     fields:nil];
    
    NSRegularExpression *getLiveAuthUrl = [NSRegularExpression regularExpressionWithPattern:PATTERN_LOGIN_LIVE_AUTH_URL
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:&error];
    
    match = [getLiveAuthUrl firstMatchInString:loginPage
                                       options:0
                                         range:NSMakeRange(0, [loginPage length])];
    
    if (!match)
        return NO;
    
    NSString *postUrl = [loginPage substringWithRange:[match rangeAtIndex:1]];
    
    if ([account.username hasSuffix:@"@msn.com"])
        postUrl = [postUrl stringByReplacingOccurrencesOfString:@"://login.live.com/" 
                                                     withString:@"://msnia.login.live.com/"];
    
    NSRegularExpression *getPpsxValue = [NSRegularExpression regularExpressionWithPattern:PATTERN_LOGIN_PPSX
                                                                                  options:0
                                                                                    error:&error];
    
    match = [getPpsxValue firstMatchInString:loginPage
                                     options:0
                                       range:NSMakeRange(0, [loginPage length])];
    
    if (!match)
        return NO;
    
    NSString *ppsx = [loginPage substringWithRange:[match rangeAtIndex:1]];
    
    NSMutableDictionary *inputs = [XboxLiveParser getInputs:loginPage
                                                namePattern:nil];
    
    [inputs setValue:account.username
              forKey:@"login"];
    [inputs setValue:account.password
              forKey:@"passwd"];
    [inputs setValue:@"1"
              forKey:@"LoginOptions"];
    [inputs setValue:ppsx
              forKey:@"PPSX"];
    
    NSString *loginResponse = [self loadWithPOST:postUrl
                                          fields:inputs];
    
    NSString *redirUrl = [XboxLiveParser getActionUrl:loginResponse];
    
    inputs = [XboxLiveParser getInputs:loginResponse
                           namePattern:nil];
    
    if (![inputs objectForKey:@"ANON"])
        return NO;
    
    [self loadWithPOST:redirUrl
                fields:inputs];
    
    return YES;
}

-(void)parseGames:(XboxLiveAccount*)account
           context:(NSManagedObjectContext*)context
{
    NSString *aStr = [self loadWithGET:URL_GAMES
                                fields:nil];
    
    if (aStr == nil)
        return; // TODO: raise an error
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression 
                                  regularExpressionWithPattern:PATTERN_GAMES
                                  options:NSRegularExpressionDotMatchesLineSeparators
                                  error:&error];
    
    NSRegularExpression *findGameTitle = [NSRegularExpression
                                          regularExpressionWithPattern:PATTERN_GAME_TITLE
                                          options:0
                                          error:&error];
    NSRegularExpression *findGameAchUrl = [NSRegularExpression
                                           regularExpressionWithPattern:PATTERN_GAME_ACHIEVEMENT_URL
                                           options:0
                                           error:&error];
    NSRegularExpression *findGameBoxArtUrl = [NSRegularExpression
                                              regularExpressionWithPattern:PATTERN_GAME_BOXART_URL
                                              options:0
                                              error:&error];
    
    NSRegularExpression *findGameScore = [NSRegularExpression
                                          regularExpressionWithPattern:PATTERN_GAME_GAMERSCORE
                                          options:0
                                          error:&error];
    NSRegularExpression *findGameAchs = [NSRegularExpression
                                         regularExpressionWithPattern:PATTERN_GAME_ACHIEVEMENTS
                                         options:0
                                         error:&error];
    
    NSRegularExpression *findGameLastPlayed = [NSRegularExpression
                                               regularExpressionWithPattern:PATTERN_GAME_LAST_PLAYED
                                               options:0
                                               error:&error];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxPlayedGame"
                                                         inManagedObjectContext:context];
    
    __block int listOrder = 0;
    NSDate *lastUpdated = [NSDate date];
    
    // TODO: error check
    [regex enumerateMatchesInString:aStr 
                            options:0
                              range:NSMakeRange(0, [aStr length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) 
     {
         
         listOrder++;
         
         // Isolate the game section
         NSString *gameSection = [aStr substringWithRange:[result rangeAtIndex:1]];
         
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
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(Uid = %@) AND (AccountId = %d)", uid, [account accountId]];
         
         NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
         [request setEntity:entityDescription];
         [request setPredicate:predicate];
         
         NSError *innerError = nil;
         NSArray *array = [context executeFetchRequest:request 
                                                 error:&innerError];
         
         // If no such game exists, create a new one
         if (!(game = [array lastObject]))
         {
             game = [NSEntityDescription 
                     insertNewObjectForEntityForName:@"XboxPlayedGame"
                     inManagedObjectContext:context];
             
             // These will not change, so just set them up the first time
             
             [game setValue:uid forKey:@"Uid"];
             [game setValue:[account accountId] forKey:@"AccountId"];
             
             match = [findGameTitle 
                      firstMatchInString:gameSection
                      options:0
                      range:NSMakeRange(0, [gameSection length])];
             
             if (match)
             {
                 NSString *gameUrl = [gameSection substringWithRange:[match rangeAtIndex:1]];
                 NSString *title = [[gameSection substringWithRange:[match rangeAtIndex:2]] gtm_stringByUnescapingFromHTML];
                 
                 [game setValue:gameUrl forKey:@"GameUrl"];
                 [game setValue:title forKey:@"Title"];
             }
             
             match = [findGameBoxArtUrl
                      firstMatchInString:gameSection
                      options:0
                      range:NSMakeRange(0, [gameSection length])];
             
             if (match)
             {
                 NSString *boxArtUrl = [gameSection substringWithRange:[match rangeAtIndex:1]];
                 
                 [game setValue:[XboxLiveParser getUniversalIcon:boxArtUrl] 
                         forKey:@"BoxArtUrl"];
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
         
         [game setValue:[NSNumber numberWithInt:achUnlocked] forKey:@"AchUnlocked"];
         [game setValue:[NSNumber numberWithInt:achTotal] forKey:@"AchTotal"];
         
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
         
         [game setValue:[NSNumber numberWithInt:scoreAcquired] forKey:@"PointsAcquired"];
         [game setValue:[NSNumber numberWithInt:scoreTotal] forKey:@"PointsTotal"];
         
         // Last played
         
         match = [findGameLastPlayed
                  firstMatchInString:gameSection
                  options:0
                  range:NSMakeRange(0, [gameSection length])];
         
         NSDate *lastPlayed = nil;
         
         if (match)
             lastPlayed = [XboxLiveParser parseDate:[gameSection substringWithRange:[match rangeAtIndex:1]]];
         
         [game setValue:lastPlayed forKey:@"LastPlayed"];
         [game setValue:lastUpdated forKey:@"LastUpdated"];
         [game setValue:[NSNumber numberWithInt:listOrder] forKey:@"Index"];
    }];
    
    // Find "stale" games
    
    NSPredicate *stalePredicate = [NSPredicate predicateWithFormat:@"(AccountId==%d) AND (LastUpdated!=%@)", [account accountId], lastUpdated];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    [request setPredicate:stalePredicate];
    
    NSError *innerError = nil;
    NSArray *staleObjs = [context executeFetchRequest:request 
                                                error:&innerError];
    
    // Delete "stale" games
    
    for (NSManagedObject *staleObj in staleObjs)
        [context deleteObject:staleObj];
    
    // Save
    
    if (![context save:&error])
    {
        // TODO
        abort();
    }
    
    // TODO: notify list?
    
    NSLog(@"Done");
}

#pragma mark Helpers

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
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [dateFormatter dateFromString:dateStr];
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

@end
