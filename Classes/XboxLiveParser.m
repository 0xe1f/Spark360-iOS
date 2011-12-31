//
//  XboxLiveParser.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XboxLiveParser.h"

#include "XboxLive.h"
#import "GTMNSString+HTML.h"
#import "GTMNSString+URLArguments.h"
#import "SBJson.h"

#import "TaskController.h"

#define TIMEOUT_SECONDS 30

#define XBLPGet  (@"GET")
#define XBLPPost (@"POST")

NSString* const BachErrorDomain = @"com.akop.bach";

@interface XboxLiveParser (Private)

-(void)parseFriendSection:(NSMutableArray*)friendsList
          incomingFriends:(NSArray*)inFriends
               isIncoming:(BOOL)isIncoming
               isOutgoing:(BOOL)isOutgoing;

- (NSString*)getRedirectionUrl:(NSString*)url
                         error:(NSError**)error;
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
+(id)jsonDataObjectFromPage:(NSString*)json
                      error:(NSError**)error;
+(NSDictionary*)jsonObjectFromPage:(NSString*)json
                             error:(NSError**)error;
+(NSNumber*)getStarRatingFromPage:(NSString*)html;
-(NSString*)getBoxArtForTitleId:(NSNumber*)titleId
                    largeBoxArt:(BOOL)largeBoxArt;
-(NSString*)getDetailUrlForTitleId:(NSNumber*)titleId;

-(void)saveSessionForAccount:(XboxLiveAccount*)account;
-(void)saveSessionForEmailAddress:(NSString*)emailAddress;
-(BOOL)restoreSessionForAccount:(XboxLiveAccount*)account;
-(BOOL)restoreSessionForEmailAddress:(NSString*)emailAddress;
-(void)clearAllSessions;

-(BOOL)parseSynchronizeProfile:(NSMutableDictionary*)profile
                  emailAddress:(NSString*)emailAddress
                      password:(NSString*)password
                         error:(NSError**)error;
-(BOOL)parseGames:(NSMutableDictionary*)games
                  forAccount:(XboxLiveAccount*)account
                       error:(NSError**)error;
-(BOOL)parseAchievements:(NSMutableDictionary*)achievements
                         forAccount:(XboxLiveAccount*)account
                            titleId:(NSString*)titleId
                              error:(NSError**)error;
-(BOOL)parseMessages:(NSMutableDictionary*)messages
          forAccount:(XboxLiveAccount*)account
               error:(NSError**)error;
-(BOOL)parseFriends:(NSMutableDictionary*)friends
         forAccount:(XboxLiveAccount*)account
              error:(NSError**)error;
-(NSDictionary*)parseFriendProfileWithUid:(NSString*)uid 
                               forAccount:(XboxLiveAccount *)account 
                                    error:(NSError **)error;
-(NSDictionary*)parseProfileWithScreenName:(NSString*)screenName
                               withAccount:(XboxLiveAccount*)account
                                     error:(NSError**)error;
-(BOOL)parseFriendRequestToScreenName:(NSString*)screenName
                          withAccount:(XboxLiveAccount*)account
                         actionToTake:(NSString*)action
                                error:(NSError**)error;
-(NSDictionary*)parseCompareGamesWithScreenName:(NSString*)screenName
                                    withAccount:(XboxLiveAccount*)account
                                          error:(NSError**)error;
-(NSDictionary*)parseCompareAchievementsWithUid:(NSString*)uid
                                     screenName:(NSString*)screenName
                                    withAccount:(XboxLiveAccount*)account
                                          error:(NSError**)error;
-(NSDictionary*)parseGameOverview:(NSString*)detailUrl
                            error:(NSError**)error;
-(NSDictionary*)parseXboxLiveStatus:(NSError**)error;

-(NSArray*)parseRecentPlayersForAccount:(XboxLiveAccount*)account
                                  error:(NSError**)error;
-(NSArray*)parseFriendsOfFriendForScreenName:(NSString*)screenName
                                      account:(XboxLiveAccount*)account
                                        error:(NSError**)error;

-(BOOL)parseDeleteMessageWithUid:(NSString*)uid
                      forAccount:(XboxLiveAccount*)account
                           error:(NSError**)error;
-(BOOL)parseSendMessageToRecipients:(NSArray*)recipients
                               body:(NSString*)body
                         forAccount:(XboxLiveAccount*)account
                              error:(NSError**)error;
-(NSDictionary*)parseSyncMessageWithUid:(NSString*)uid
                             forAccount:(XboxLiveAccount*)account
                                  error:(NSError**)error;

+(NSError*)errorWithCode:(NSInteger)code
                 message:(NSString*)message;
+(NSError*)errorWithCode:(NSInteger)code
         localizationKey:(NSString*)key;

-(NSString*)obtainTokenFrom:(NSString*)url;
-(NSString*)obtainTokenFrom:(NSString*)url
                  parameter:(NSString*)param;
-(NSString*)parseObtainNewToken;
+(NSDate*)ticksFromJSONString:(NSString*)jsonTicks;
-(NSString*)largeGamerpicFromIconUrl:(NSString*)url;
-(NSString*)gamerpicUrlForGamertag:(NSString*)gamertag;
-(NSString*)avatarUrlForGamertag:(NSString*)gamertag;

-(NSManagedObject*)profileForAccount:(XboxLiveAccount*)account;
-(NSManagedObject*)getGameWithTitleId:(NSString*)titleId
                              account:(XboxLiveAccount*)account;
-(NSManagedObject*)friendWithUid:(NSString*)uid
                         account:(XboxLiveAccount*)account;

-(NSDictionary*)retrieveGamesWithAccount:(XboxLiveAccount*)account
                                   error:(NSError**)error;
-(NSDictionary*)retrieveAchievementsWithAccount:(XboxLiveAccount*)account
                                        titleId:(NSString*)titleId
                                          error:(NSError**)error;
-(NSDictionary*)retrieveMessagesWithAccount:(XboxLiveAccount*)account
                                      error:(NSError**)error;

-(NSDictionary*)retrieveFriendsWithAccount:(XboxLiveAccount*)account
                                     error:(NSError**)error;
-(NSDictionary*)retrieveFriendProfileWithUid:(NSString*)uid
                                     account:(XboxLiveAccount*)account
                                       error:(NSError**)error;

-(NSDictionary*)retrieveProfileWithScreenName:(NSString*)screenName
                                      account:(XboxLiveAccount*)account
                                        error:(NSError**)error;
-(NSArray*)retrieveRecentPlayersForAccount:(XboxLiveAccount*)account
                                     error:(NSError**)error;
-(NSArray*)retrieveFriendsOfFriendForScreenName:(NSString*)screenName
                                         account:(XboxLiveAccount*)account
                                           error:(NSError**)error;

-(BOOL)retrieveFriendRequestToScreenName:(NSString*)screenName
                                 account:(XboxLiveAccount*)account
                            actionToTake:(NSString*)action
                                   error:(NSError**)error;

-(NSDictionary*)retrieveCompareGamesWithScreenName:(NSString*)screenName
                                           account:(XboxLiveAccount*)account
                                             error:(NSError**)error;
-(NSDictionary*)retrieveCompareAchievementsForUid:(NSString*)uid
                                       screenName:(NSString*)screenName
                                          account:(XboxLiveAccount*)account
                                            error:(NSError**)error;
-(NSDictionary*)retrieveGameOverview:(NSString*)detailUrl
                             account:(XboxLiveAccount*)account
                               error:(NSError**)error;
-(NSDictionary*)retrieveXboxLiveStatus:(XboxLiveAccount*)account
                                 error:(NSError**)error;

-(BOOL)retrieveDeleteMessageWithUid:(NSString*)uid
                            account:(XboxLiveAccount*)account
                              error:(NSError**)error;
-(BOOL)retrieveSendMessageToRecipients:(NSArray*)recipients
                                  body:(NSString*)body
                               account:(XboxLiveAccount*)account
                              error:(NSError**)error;
-(NSDictionary*)retrieveSyncMessageWithUid:(NSString*)uid
                                   account:(XboxLiveAccount*)account
                                     error:(NSError**)error;

-(void)writeProfile:(NSDictionary*)args;
-(void)writeGames:(NSDictionary*)args;
-(void)writeAchievements:(NSDictionary*)data;
-(void)writeMessages:(NSDictionary*)args;
-(void)writeFriends:(NSDictionary*)args;
-(void)writeFriendProfile:(NSDictionary*)args;
-(void)writeDeleteMessage:(NSDictionary*)args;
-(void)writeSyncMessage:(NSDictionary*)args;
-(void)writeRemoveFromFriends:(NSDictionary*)args;

-(void)postNotificationOnMainThread:(NSString*)postNotificationName
                           userInfo:(NSDictionary*)userInfo;
-(void)postNotificationSelector:(NSDictionary*)args;

@end

@implementation XboxLiveParser

@synthesize context = _context;
@synthesize lastError;

#define LOCALE (NSLocalizedString(@"Locale", nil))

NSString* const ErrorDomainAuthentication = @"Authentication";

#pragma mark - URL constants

NSString* const URL_LOGIN = @"http://login.live.com/login.srf?wa=wsignin1.0&wreply=%@";
NSString* const URL_LOGIN_MSN = @"https://msnia.login.live.com/ppsecure/post.srf?wa=wsignin1.0&wreply=%@";
NSString* const URL_VTOKEN = @"http://live.xbox.com/%@/Home";
NSString* const URL_VTOKEN_MESSAGES = @"http://live.xbox.com/%@/Messages?xr=socialtwistnav";
NSString* const URL_VTOKEN_FRIENDS = @"http://live.xbox.com/%@/Friends?xr=shellnav";
NSString* const URL_VTOKEN_COMPARE_GAMES = @"http://live.xbox.com/%@/Activity?compareTo=%@";

NSString* const URL_GAMERCARD = @"http://gamercard.xbox.com/%@/%@.card";

NSString* const URL_JSON_PROFILE = @"http://live.xbox.com/Handlers/ShellData.ashx?culture=%@&XBXMChg=%i&XBXNChg=%i&XBXSPChg=%i&XBXChg=%i&leetcallback=jsonp1287728723001";
NSString* const URL_JSON_GAME_LIST = @"http://live.xbox.com/%@/Activity/Summary";
NSString* const URL_JSON_MESSAGE_LIST = @"http://live.xbox.com/%@/Messages/GetMessages";
NSString* const URL_JSON_FRIEND_LIST = @"http://live.xbox.com/%@/Friends/List";
NSString* const URL_JSON_SEND_MESSAGE = @"https://live.xbox.com/%@/Messages/SendMessage";
NSString* const URL_JSON_READ_MESSAGE = @"http://live.xbox.com/%@/Messages/Message";
NSString* const URL_JSON_FRIEND_REQUEST = @"http://live.xbox.com/%@/Friends/%@";
NSString* const URL_JSON_COMPARE_GAMES = @"http://live.xbox.com/%@/Activity/Summary?CompareTo=%@";
NSString* const URL_JSON_RECENT_LIST = @"http://live.xbox.com/%@/Friends/Recent";
NSString* const URL_JSON_FOF_LIST = @"http://live.xbox.com/%@/Friends/List";

NSString* const URL_JSON_DELETE_MESSAGE = @"http://live.xbox.com/%@/Messages/Delete";

NSString* const REFERER_JSON_PROFILE = @"http://live.xbox.com/%@/MyXbox";

NSString* const URL_PROFILE = @"http://live.xbox.com/%@/Profile";
NSString* const URL_ACHIEVEMENTS = @"http://live.xbox.com/%@/Activity/Details?titleId=%@";
NSString* const URL_FRIEND_PROFILE = @"http://live.xbox.com/%@/Profile?gamertag=%@";
NSString* const URL_COMPARE_ACHIEVEMENTS = @"http://live.xbox.com/%@/Activity/Details?compareTo=%@&titleId=%@";
NSString* const URL_STATUS = @"http://support.xbox.com/%@/xbox-live-status";

NSString* const URL_REPLY_TO = @"https://live.xbox.com/xweb/live/passport/setCookies.ashx";

#pragma mark - Regex Patterns

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

NSString* const PATTERN_SUMMARY_NAME = @"<div class=\"name\" title=\"[^\"]*\">.*?<div class=\"value\">([^<]*)</div>"; // DOTALL
NSString* const PATTERN_SUMMARY_LOCATION = @"<div class=\"location\">.*?<div class=\"value\">([^<]*)</div>"; // DOTALL
NSString* const PATTERN_SUMMARY_BIO = @"<div class=\"bio\">.*?<div class=\"value\" title=\"[^\"]*\">([^<]*)</div>"; // DOTALL
NSString* const PATTERN_SUMMARY_POINTS = @"<div class=\"gamerscore\">(\\d+)</div>";
NSString* const PATTERN_SUMMARY_GAMERPIC = @"<img class=\"gamerpic\" src=\"([^\"]+)\"";
NSString* const PATTERN_SUMMARY_MOTTO = @"<div class=\"motto\">([^<]*)<";
NSString* const PATTERN_SUMMARY_ACTIVITY = @"<div class=\"presence\">([^>]*)</div>";
NSString* const PATTERN_SUMMARY_REP = @"<div class=\"reputation\">(.*?)<div class=\"clearfix\""; // DOTALL
NSString* const PATTERN_SUMMARY_GAMERTAG = @"<article class=\"profile you\" data-gamertag=\"([^\"]*)\">";

NSString* const PATTERN_GAMERPIC_CLASSIC = @"/(1)([0-9a-fA-F]+)$";
NSString* const PATTERN_GAMERPIC_AVATAR = @"/avatarpic-(s)(.png)$"; //CASE_INSENSITIVE

NSString* const PATTERN_ACH_JSON = @"loadActivityDetailsView\\((.*)\\);\\s*\\}\\);";
NSString* const PATTERN_COMPARE_ACH_JSON = @"loadCompareView\\((.*)\\);\\s*\\}\\);";

NSString* const PATTERN_GAME_OVERVIEW_TITLE = @"<h1>([^<]*)</h1>";
NSString* const PATTERN_GAME_OVERVIEW_DESCRIPTION = @"<div class=\"Text\">\\s*<p\\s*[^>]*>([^<]+)</p>\\s*</div>";
NSString* const PATTERN_GAME_OVERVIEW_MANUAL = @"<a class=\"Manual\" href=\"([^\"]+)\"";
NSString* const PATTERN_GAME_OVERVIEW_ESRB = @"<img alt=\"([^\"]*)\" class=\"ratingLogo\" src=\"([^\"]*)\"";
NSString* const PATTERN_GAME_OVERVIEW_IMAGE = @"<div id=\"image\\d+\" class=\"TabPage\">\\s*<img (?:width=\"[^\"]*\" )?src=\"([^\"]*)\"";
NSString* const PATTERN_GAME_OVERVIEW_BANNER = @"<img src=\"([^\"]*)\" alt=\"[^\"]*\" class=\"Banner\" />";

NSString* const PATTERN_STATUS_LINE = @"<div class=\"Status..\">\\s*(.*?\\s*</div>)\\s*</div>"; // DOTALL
NSString* const PATTERN_STATUS_NAME = @"<strong>([^<]*)</strong>";
NSString* const PATTERN_STATUS_IS_OK = @"class=\"StatusOKText\"";
NSString* const PATTERN_STATUS_DESCRIPTION = @"<div class=\"StatusKOText\">(.*)?</div>"; // DOTALL

NSString* const URL_SECRET_ACHIEVE_TILE = @"http://live.xbox.com/Content/Images/HiddenAchievement.png";
NSString* const URL_GAMERPIC = @"http://avatar.xboxlive.com/avatar/%@/avatarpic-l.png";
NSString* const URL_AVATAR_BODY = @"http://avatar.xboxlive.com/avatar/%@/avatar-body.png";

NSString* const BOXART_TEMPLATE = @"http://tiles.xbox.com/consoleAssets/%X/%@/%@boxart.jpg";
NSString* const GAME_DETAIL_URL_TEMPLATE = @"http://marketplace.xbox.com/%@/Title/%i";

NSString* const FRIEND_ACTION_ADD = @"Add";
NSString* const FRIEND_ACTION_REMOVE = @"Remove";
NSString* const FRIEND_ACTION_ACCEPT = @"Accept";
NSString* const FRIEND_ACTION_REJECT = @"Decline";
NSString* const FRIEND_ACTION_CANCEL = @"Cancel";

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (!(self = [super init]))
        return nil;
    
    self.context = context;
    
    return self;
}

-(void)dealloc
{
    self.context = nil;
    self.lastError = nil;
    
    [super dealloc];
}

#pragma mark - Externals

-(void)synchronizeProfile:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveProfileWithEmailAddress:account.emailAddress
                                                      password:account.password
                                                         error:&error];
    
    self.lastError = error;
    
    if (data)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              data, @"data",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeProfile:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHProfileSynced
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)synchronizeGames:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveGamesWithAccount:account
                                                  error:&error];
    
    self.lastError = error;
    
    if (data)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              data, @"data",
                               nil];
        
        [self performSelectorOnMainThread:@selector(writeGames:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHGamesSynced
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)synchronizeAchievements:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *gameTitleId = [arguments objectForKey:@"id"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveAchievementsWithAccount:account
                                                       titleId:gameTitleId
                                                         error:&error];
    
    self.lastError = error;
    
    if (data)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              data, @"data", nil];
        
        [self performSelectorOnMainThread:@selector(writeAchievements:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHAchievementsSynced
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            gameTitleId, BACHNotificationUid, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)synchronizeMessages:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveMessagesWithAccount:account
                                                     error:&error];
    
    self.lastError = error;
    
    if (data)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              data, @"data",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeMessages:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHMessagesSynced
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)synchronizeFriends:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveFriendsWithAccount:account
                                                    error:&error];
    
    self.lastError = error;
    
    if (data)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              data, @"data",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeFriends:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHFriendsSynced
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
        
        [self postNotificationOnMainThread:BACHFriendsChanged
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)synchronizeFriendProfile:(NSDictionary *)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *uid = [arguments objectForKey:@"uid"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveFriendProfileWithUid:uid
                                                    account:account
                                                      error:&error];
    
    self.lastError = error;
    
    if (data)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              uid, @"uid",
                              data, @"data",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeFriendProfile:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHFriendProfileSynced
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            uid, BACHNotificationUid,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)loadProfile:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveProfileWithScreenName:screenName
                                                     account:account
                                                       error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHProfileLoaded
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            data, BACHNotificationData,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)loadRecentPlayers:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    
    NSError *error = nil;
    NSArray *data = [self retrieveRecentPlayersForAccount:account
                                                    error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHRecentPlayersLoaded
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            data, BACHNotificationData,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)loadFriendsOfFriend:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    NSArray *data = [self retrieveFriendsOfFriendForScreenName:screenName
                                                        account:account
                                                          error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHFriendsOfFriendLoaded
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount,
                                            screenName, BACHNotificationScreenName,
                                            data, BACHNotificationData,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)sendAddFriendRequest:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    
    [self retrieveFriendRequestToScreenName:screenName
                                    account:account
                               actionToTake:FRIEND_ACTION_ADD
                                      error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        account.lastFriendsUpdate = [NSDate distantPast];
        [account save];
        
        [self postNotificationOnMainThread:BACHFriendsChanged
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)removeFromFriends:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    
    [self retrieveFriendRequestToScreenName:screenName
                                    account:account
                               actionToTake:FRIEND_ACTION_REMOVE
                                      error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              screenName, @"screenName",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeRemoveFromFriends:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHFriendsChanged
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)approveFriendRequest:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    
    [self retrieveFriendRequestToScreenName:screenName
                                    account:account
                               actionToTake:FRIEND_ACTION_ACCEPT
                                      error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHFriendsChanged
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    account.lastFriendsUpdate = [NSDate distantPast];
    [account save];
    
    [pool release];
}

-(void)rejectFriendRequest:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    
    [self retrieveFriendRequestToScreenName:screenName
                                    account:account
                               actionToTake:FRIEND_ACTION_REJECT
                                      error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              screenName, @"screenName",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeRemoveFromFriends:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHFriendsChanged
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)cancelFriendRequest:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    
    [self retrieveFriendRequestToScreenName:screenName
                                    account:account
                               actionToTake:FRIEND_ACTION_CANCEL
                                      error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              screenName, @"screenName",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeRemoveFromFriends:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHFriendsChanged
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)compareGames:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    
    NSError *error = nil;
    
    NSDictionary *data = [self retrieveCompareGamesWithScreenName:screenName
                                                          account:account
                                                            error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHGamesCompared
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            screenName, BACHNotificationScreenName,
                                            data, BACHNotificationData,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)compareAchievements:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *screenName = [arguments objectForKey:@"screenName"];
    NSString *uid = [arguments objectForKey:@"uid"];
    
    NSError *error = nil;
    
    NSDictionary *data = [self retrieveCompareAchievementsForUid:uid
                                                      screenName:screenName
                                                         account:account
                                                           error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHAchievementsCompared
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            screenName, BACHNotificationScreenName,
                                            uid, BACHNotificationUid,
                                            data, BACHNotificationData,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)loadGameOverview:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *detailUrl = [arguments objectForKey:@"url"];
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveGameOverview:detailUrl
                                            account:account
                                              error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHGameOverviewLoaded
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            detailUrl, BACHNotificationUid,
                                            data, BACHNotificationData,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)loadXboxLiveStatus:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveXboxLiveStatus:account
                                                error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHXboxLiveStatusLoaded
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            data, BACHNotificationData,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)deleteMessage:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *uid = [arguments objectForKey:@"uid"];
    
    NSError *error = nil;
    BOOL deleted = [self retrieveDeleteMessageWithUid:uid
                                              account:account
                                                error:&error];
    
    self.lastError = error;
    
    if (deleted)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              uid, @"uid",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeDeleteMessage:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHMessagesChanged
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)sendMessage:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSArray *recipients = [arguments objectForKey:@"recipients"];
    NSString *body = [arguments objectForKey:@"body"];
    
    NSError *error = nil;
    [self retrieveSendMessageToRecipients:recipients
                                     body:body
                                  account:account
                                    error:&error];
    
    self.lastError = error;
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHMessageSent
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)syncMessage:(NSDictionary*)arguments
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    XboxLiveAccount *account = [arguments objectForKey:@"account"];
    NSString *uid = [arguments objectForKey:@"uid"];
    
    NSError *error = nil;
    NSDictionary *data = [self retrieveSyncMessageWithUid:uid
                                                  account:account
                                                    error:&error];
    
    self.lastError = error;
    
    if (data)
    {
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                              account, @"account",
                              uid, @"uid",
                              data, @"data",
                              nil];
        
        [self performSelectorOnMainThread:@selector(writeSyncMessage:) 
                               withObject:args
                            waitUntilDone:YES];
    }
    
    if (!self.lastError)
    {
        [self postNotificationOnMainThread:BACHMessageSynced
                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            account, BACHNotificationAccount, 
                                            uid, BACHNotificationUid,
                                            nil]];
    }
    else
    {
        [self postNotificationOnMainThread:BACHError
                                  userInfo:[NSDictionary dictionaryWithObject:self.lastError
                                                                       forKey:BACHNotificationNSError]];
    }
    
    [pool release];
}

-(void)postNotificationOnMainThread:(NSString*)postNotificationName
                           userInfo:(NSDictionary*)userInfo
{
    NSLog(@"Sending notification '%@' on main thread", postNotificationName);
    
    [self performSelectorOnMainThread:@selector(postNotificationSelector:) 
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       postNotificationName, @"postNotificationName", 
                                       userInfo, @"userInfo", nil]
                        waitUntilDone:YES];
}

-(void)postNotificationSelector:(NSDictionary*)args
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[args objectForKey:@"postNotificationName"]
                                                        object:self
                                                      userInfo:[args objectForKey:@"userInfo"]];
}

#pragma mark - Retrieve*

-(NSDictionary*)retrieveGamesWithAccount:(XboxLiveAccount*)account
                                   error:(NSError**)error
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    if (![self parseGames:dict
               forAccount:account
                    error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (![self parseGames:dict
                   forAccount:account
                        error:error])
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return dict;
}

-(NSDictionary*)retrieveAchievementsWithAccount:(XboxLiveAccount*)account
                                        titleId:(NSString*)titleId
                                          error:(NSError**)error
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    if (![self parseAchievements:dict
                      forAccount:account
                         titleId:titleId
                           error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (![self parseAchievements:dict
                          forAccount:account
                             titleId:titleId
                               error:error])
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return dict;
}

-(NSDictionary*)retrieveMessagesWithAccount:(XboxLiveAccount*)account
                                      error:(NSError**)error
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    if (![self parseMessages:dict
                  forAccount:account
                       error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (![self parseMessages:dict
                      forAccount:account
                           error:error])
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return dict;
}

-(NSDictionary*)retrieveFriendsWithAccount:(XboxLiveAccount*)account
                                     error:(NSError**)error
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    if (![self parseFriends:dict
                 forAccount:account
                      error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (![self parseFriends:dict
                     forAccount:account
                          error:error])
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return dict;
}

-(NSDictionary*)retrieveFriendProfileWithUid:(NSString*)uid 
                                     account:(XboxLiveAccount*)account 
                                       error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    NSDictionary *friendData;
    if (!(friendData = [self parseFriendProfileWithUid:uid
                                            forAccount:account
                                                 error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (!(friendData = [self parseFriendProfileWithUid:uid
                                                forAccount:account
                                                     error:error]))
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return friendData;
}

-(NSDictionary*)retrieveProfileWithScreenName:(NSString*)screenName
                                      account:(XboxLiveAccount*)account
                                        error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    NSDictionary *profileData;
    if (!(profileData = [self parseProfileWithScreenName:screenName
                                             withAccount:account
                                                   error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (!(profileData = [self parseProfileWithScreenName:screenName
                                                 withAccount:account
                                                       error:error]))
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return profileData;
}

-(NSArray*)retrieveRecentPlayersForAccount:(XboxLiveAccount*)account
                                          error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    NSArray *players;
    if (!(players = [self parseRecentPlayersForAccount:account
                                                 error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (!(players = [self parseRecentPlayersForAccount:account
                                                     error:error]))
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return players;
}

-(NSArray*)retrieveFriendsOfFriendForScreenName:(NSString*)screenName
                                         account:(XboxLiveAccount*)account
                                           error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    NSArray *friends;
    if (!(friends = [self parseFriendsOfFriendForScreenName:screenName
                                                     account:account
                                                       error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (!(friends = [self parseFriendsOfFriendForScreenName:screenName
                                                         account:account
                                                           error:error]))
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return friends;
}

-(BOOL)retrieveFriendRequestToScreenName:(NSString*)screenName
                                 account:(XboxLiveAccount*)account
                            actionToTake:(NSString *)action
                                   error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return NO;
        }
    }
    
    BOOL requestSent;
    if (!(requestSent = [self parseFriendRequestToScreenName:screenName
                                                 withAccount:account
                                                actionToTake:action
                                                       error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return NO;
        }
        
        if (!(requestSent = [self parseFriendRequestToScreenName:screenName
                                                     withAccount:account
                                                    actionToTake:action
                                                           error:error]))
        {
            return NO;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return requestSent;
}

-(NSDictionary*)retrieveCompareGamesWithScreenName:(NSString*)screenName
                                           account:(XboxLiveAccount*)account
                                             error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    NSDictionary *games;
    if (!(games = [self parseCompareGamesWithScreenName:screenName
                                            withAccount:account
                                                  error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (!(games = [self parseCompareGamesWithScreenName:screenName
                                                withAccount:account
                                                      error:error]))
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return games;
}

-(NSDictionary*)retrieveCompareAchievementsForUid:(NSString*)uid
                                       screenName:(NSString*)screenName
                                          account:(XboxLiveAccount*)account
                                            error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    NSDictionary *achievements;
    if (!(achievements = [self parseCompareAchievementsWithUid:uid
                                                    screenName:screenName
                                                   withAccount:account
                                                         error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (!(achievements = [self parseCompareAchievementsWithUid:uid
                                                        screenName:screenName
                                                       withAccount:account
                                                             error:error]))
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return achievements;
}

-(NSDictionary*)retrieveGameOverview:(NSString*)detailUrl
                             account:(XboxLiveAccount*)account
                               error:(NSError**)error
{
    [self restoreSessionForAccount:account];
    
    return [self parseGameOverview:detailUrl
                             error:error];
}

-(NSDictionary*)retrieveXboxLiveStatus:(XboxLiveAccount*)account
                                 error:(NSError**)error
{
    [self restoreSessionForAccount:account];
    
    return [self parseXboxLiveStatus:error];
}

-(BOOL)retrieveDeleteMessageWithUid:(NSString*)uid
                            account:(XboxLiveAccount*)account
                              error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return NO;
        }
    }
    
    if (![self parseDeleteMessageWithUid:uid
                              forAccount:account
                                   error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return NO;
        }
        
        if (![self parseDeleteMessageWithUid:uid
                                  forAccount:account
                                       error:error])
        {
            return NO;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return YES;
}

-(BOOL)retrieveSendMessageToRecipients:(NSArray*)recipients
                                  body:(NSString*)body
                               account:(XboxLiveAccount*)account
                              error:(NSError**)error
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return NO;
        }
    }
    
    if (![self parseSendMessageToRecipients:recipients
                                       body:body
                                 forAccount:account
                                      error:NULL])
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return NO;
        }
        
        if (![self parseSendMessageToRecipients:recipients
                                           body:body
                                     forAccount:account
                                          error:error])
        {
            return NO;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return YES;
}

-(NSDictionary*)retrieveSyncMessageWithUid:(NSString*)uid
                                   account:(XboxLiveAccount*)account
                                     error:(NSError**)error;
{
    // Try restoring the session
    
    if (![self restoreSessionForAccount:account])
    {
        // Session couldn't be restored. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
    }
    
    NSDictionary *data;
    if (!(data = [self parseSyncMessageWithUid:uid
                                    forAccount:account
                                         error:NULL]))
    {
        // Account parsing failed. Try re-authenticating
        
        if (![self authenticateAccount:account
                                 error:error])
        {
            return nil;
        }
        
        if (!(data = [self parseSyncMessageWithUid:uid
                                        forAccount:account
                                             error:error]))
        {
            return nil;
        }
    }
    
    [self saveSessionForAccount:account];
    
    return data;
}

-(NSDictionary*)retrieveProfileWithAccount:(XboxLiveAccount*)account
                                     error:(NSError**)error
{
    return [self retrieveProfileWithEmailAddress:account.emailAddress
                                        password:account.password
                                           error:error];
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

#pragma mark - parse*

-(BOOL)parseGames:(NSMutableDictionary*)games
       forAccount:(XboxLiveAccount*)account
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
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
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
            
            NSDate *lastPlayed = [XboxLiveParser ticksFromJSONString:[progress objectForKey:@"LastPlayed"]];
            
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
    
    return YES;
}

-(BOOL)parseAchievements:(NSMutableDictionary*)achievements
              forAccount:(XboxLiveAccount*)account
                 titleId:(NSString*)titleId
                   error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *url = [NSString stringWithFormat:URL_ACHIEVEMENTS, LOCALE, titleId];
    NSString *achievementPage = [self loadWithGET:url
                                           fields:nil
                                           useXhr:NO
                                            error:error];
    
    if (!achievementPage)
        return NO;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_ACH_JSON
                                                                           options:0
                                                                             error:NULL];
    
    NSTextCheckingResult *match = [regex firstMatchInString:achievementPage
                                                    options:0
                                                      range:NSMakeRange(0, [achievementPage length])];
    
    if (!match)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorAchievementsNotFound"];
        }
        
        return NO;
    }
    
    NSString *jsonScript = [achievementPage substringWithRange:[match rangeAtIndex:1]];
    NSDictionary *data = [XboxLiveParser jsonObjectFromPage:jsonScript
                                                      error:error];
    
    if (!data)
        return NO;
    
    NSArray *jsonAchieves = [data objectForKey:@"Achievements"];
    NSArray *jsonPlayers = [data objectForKey:@"Players"];
    
    if ([jsonPlayers count] < 1)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError 
                                           message:@"ErrorMissingGamertagInAchieves"];
        }
        
        return NO;
    }
    
    NSString *gamertag = [[jsonPlayers objectAtIndex:0] objectForKey:@"Gamertag"];
    
    NSMutableArray *achieveList = [[[NSMutableArray alloc] init] autorelease];
    
    [achievements setObject:achieveList forKey:@"achievements"];
    [achievements setObject:titleId forKey:@"titleId"];
    
    int index = 0;
    for (NSDictionary *jsonAchieve in jsonAchieves)
    {
        if (![jsonAchieve objectForKey:@"Id"])
            continue;
        
        NSDictionary *earnDates = [jsonAchieve objectForKey:@"EarnDates"];
        if (!earnDates)
            continue;
        
        NSMutableArray *objects = [[[NSMutableArray alloc] init] autorelease];
        
        if ([[jsonAchieve objectForKey:@"IsHidden"] boolValue])
        {
            [objects addObject:NSLocalizedString(@"SecretAchieveTitle", nil)]; // title
            [objects addObject:NSLocalizedString(@"SecretAchieveDesc", nil)]; // achDescription
            [objects addObject:URL_SECRET_ACHIEVE_TILE]; // iconUrl
            [objects addObject:[NSNumber numberWithBool:YES]]; // isSecret
        }
        else
        {
            [objects addObject:[jsonAchieve objectForKey:@"Name"]]; // title
            [objects addObject:[jsonAchieve objectForKey:@"Description"]]; // achDescription
            [objects addObject:[jsonAchieve objectForKey:@"TileUrl"]]; // iconUrl
            [objects addObject:[NSNumber numberWithBool:NO]]; // isSecret
        }
        
        NSDictionary *earnDate = [earnDates objectForKey:gamertag];
        if (earnDate)
        {
            [objects addObject:[NSNumber numberWithBool:NO]]; // isLocked
            [objects addObject:[XboxLiveParser ticksFromJSONString:[earnDate objectForKey:@"EarnedOn"]]]; // acquired
        }
        else
        {
            [objects addObject:[NSNumber numberWithBool:YES]]; // isLocked
            [objects addObject:[NSDate distantPast]]; // acquired
        }
        
        [objects addObject:[[jsonAchieve objectForKey:@"Id"] stringValue]]; // uid
        [objects addObject:[NSNumber numberWithInt:[[jsonAchieve objectForKey:@"Score"] intValue]]]; // points
        [objects addObject:[NSNumber numberWithInt:index++]]; // sortIndex
        
        NSArray *keys = [NSArray arrayWithObjects:
                         @"title",
                         @"achDescription",
                         @"iconUrl",
                         @"isSecret",
                         @"isLocked",
                         @"acquired",
                         @"uid",
                         @"gamerScore",
                         @"sortIndex", 
                         nil];
        
        [achieveList addObject:[NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys]];
    }
    
    NSDictionary *jsonGame = [data objectForKey:@"Game"];
    if (jsonGame)
    {
        NSMutableArray *keys = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *objects = [[[NSMutableArray alloc] init] autorelease];
        
        [objects addObject:[jsonGame objectForKey:@"PossibleAchievements"]];
        [objects addObject:[jsonGame objectForKey:@"PossibleScore"]];
        
        [keys addObject:@"achievesTotal"];
        [keys addObject:@"gamerScoreTotal"];
        
        NSDictionary *progRoot = [jsonGame objectForKey:@"Progress"];
        if (progRoot)
        {
            NSDictionary *progress = [progRoot objectForKey:gamertag];
            if (progress)
            {
                [objects addObject:[progress objectForKey:@"Achievements"]];
                [objects addObject:[progress objectForKey:@"Score"]];
                [objects addObject:[XboxLiveParser ticksFromJSONString:[progress objectForKey:@"LastPlayed"]]];
                
                [keys addObject:@"achievesUnlocked"];
                [keys addObject:@"gamerScoreEarned"];
                [keys addObject:@"lastPlayed"];
            }
        }
        
        [achievements setObject:[NSDictionary dictionaryWithObjects:objects
                                                            forKeys:keys] 
                         forKey:@"game"];
    }
    
    NSLog(@"parseSynchronizeAchievements: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(BOOL)parseMessages:(NSMutableDictionary *)messages 
          forAccount:(XboxLiveAccount *)account 
               error:(NSError **)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_MESSAGES];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_MESSAGE_LIST, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObject:vtoken 
                                                       forKey:@"__RequestVerificationToken"];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                          error:error];
    
    if (!data)
        return NO;
    
    NSMutableArray *newMessages = [[[NSMutableArray alloc] init] autorelease];
    [messages setObject:newMessages 
                 forKey:@"messages"];
    
    NSArray *jsonMessages = [data objectForKey:@"Messages"];
    
    if (jsonMessages)
    {
        for (NSDictionary *jsonMessage in jsonMessages)
        {
            NSString *uid = [[jsonMessage objectForKey:@"Id"] stringValue];
            if (!uid)
                continue;
            
            NSMutableArray *objects = [[[NSMutableArray alloc] init] autorelease];
            
            [objects addObject:uid]; // remote id
            [objects addObject:[NSNumber numberWithBool:[[jsonMessage objectForKey:@"HasBeenRead"] boolValue]]]; // isRead
            [objects addObject:[XboxLiveParser ticksFromJSONString:[jsonMessage objectForKey:@"SentTime"]]]; // sent
            [objects addObject:[[jsonMessage objectForKey:@"Excerpt"] gtm_stringByUnescapingFromHTML]]; // messageText
            [objects addObject:[jsonMessage objectForKey:@"From"]]; // sender
            [objects addObject:[jsonMessage objectForKey:@"GamerPic"]]; // senderIconUrl
            [objects addObject:[NSNumber numberWithBool:[[jsonMessage objectForKey:@"IsDeletable"] boolValue]]]; // isDeletable
            [objects addObject:[NSNumber numberWithBool:[[jsonMessage objectForKey:@"HasText"] boolValue]]]; // hasText
            [objects addObject:[NSNumber numberWithBool:[[jsonMessage objectForKey:@"HasImage"] boolValue]]]; // hasPicture
            [objects addObject:[NSNumber numberWithBool:[[jsonMessage objectForKey:@"HasVoice"] boolValue]]]; // hasVoice
            
            NSArray *keys = [NSArray arrayWithObjects:
                             @"uid",
                             @"isRead",
                             @"sent",
                             @"messageText",
                             @"sender",
                             @"senderIconUrl",
                             @"isDeletable",
                             @"hasText",
                             @"hasPicture",
                             @"hasVoice",
                             nil];
            [newMessages addObject:[NSDictionary dictionaryWithObjects:objects
                                                               forKeys:keys]];
        }
    }
    
    NSLog(@"parseMessages: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(void)parseFriendSection:(NSMutableArray*)friendsList
          incomingFriends:(NSArray*)inFriends
               isIncoming:(BOOL)isIncoming
               isOutgoing:(BOOL)isOutgoing
{
    for (NSDictionary *inFriend in inFriends)
    {
        NSMutableDictionary *friend = [[[NSMutableDictionary alloc] init] autorelease];
        [friendsList addObject:friend];
        
        [friend setValue:[inFriend objectForKey:@"GamerTag"] // uid
                  forKey:@"uid"];
        [friend setValue:[inFriend objectForKey:@"GamerTag"] // screenName
                  forKey:@"screenName"];
        [friend setValue:[inFriend objectForKey:@"IsOnline"] // isOnline
                  forKey:@"isOnline"];
        [friend setValue:[inFriend objectForKey:@"LargeGamerTileUrl"] // iconUrl
                  forKey:@"iconUrl"];
        [friend setValue:[inFriend objectForKey:@"GamerScore"] // gamerscore
                  forKey:@"gamerScore"];
        [friend setValue:[XboxLiveParser ticksFromJSONString:[inFriend objectForKey:@"LastSeen"]] // lastSeen
                  forKey:@"lastSeen"];
        [friend setValue:[inFriend objectForKey:@"Presence"] // activityText
                  forKey:@"activityText"];
        
        NSDictionary *titleInfo = [inFriend objectForKey:@"TitleInfo"];
        if (titleInfo)
        {
            [friend setValue:[[titleInfo objectForKey:@"Id"] stringValue] // activityTitleId
                      forKey:@"activityTitleId"];
            [friend setValue:[titleInfo objectForKey:@"Name"] // activityTitleName
                      forKey:@"activityTitleName"];
            [friend setValue:[self getBoxArtForTitleId:[titleInfo objectForKey:@"Id"]  // activityTitleIconUrl
                                           largeBoxArt:false]
                      forKey:@"activityTitleIconUrl"];
        }
        
        [friend setValue:[NSNumber numberWithBool:isIncoming] // isIncoming
                  forKey:@"isIncoming"];
        [friend setValue:[NSNumber numberWithBool:isOutgoing] // isOutgoing
                  forKey:@"isOutgoing"];
    }
}

-(BOOL)parseFriends:(NSMutableDictionary *)friends 
         forAccount:(XboxLiveAccount *)account 
              error:(NSError **)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_FRIENDS];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_FRIEND_LIST, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObject:vtoken 
                                                       forKey:@"__RequestVerificationToken"];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                          error:error];
    
    if (!data)
        return NO;
    
    NSMutableArray *newFriends = [[[NSMutableArray alloc] init] autorelease];
    [friends setObject:newFriends 
                forKey:@"friends"];
    
    [self parseFriendSection:newFriends
             incomingFriends:[data objectForKey:@"Friends"]
                  isIncoming:NO
                  isOutgoing:NO];
    [self parseFriendSection:newFriends
             incomingFriends:[data objectForKey:@"Incoming"]
                  isIncoming:YES
                  isOutgoing:NO];
    [self parseFriendSection:newFriends
             incomingFriends:[data objectForKey:@"Outgoing"]
                  isIncoming:NO
                  isOutgoing:YES];
    
    NSLog(@"parseFriends: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(NSDictionary*)parseFriendProfileWithUid:(NSString*)uid 
                               forAccount:(XboxLiveAccount *)account 
                                    error:(NSError **)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *url = [NSString stringWithFormat:URL_FRIEND_PROFILE, 
                     LOCALE, [uid gtm_stringByEscapingForURLArgument]];
    
    NSString *friendProfilePage = [self loadWithGET:url
                                             fields:nil
                                             useXhr:NO
                                              error:error];
    
    if (!friendProfilePage)
        return nil;
    
    NSString *screenName = nil;
    
    NSMutableDictionary *friend = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSRegularExpression *regex = nil;
    NSTextCheckingResult *match = nil;
    NSString *text = nil;
    
    // Gamertag
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_GAMERTAG
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [friendProfilePage substringWithRange:[match rangeAtIndex:1]];
        
        screenName = [[text gtm_stringByUnescapingFromHTML] 
                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [friend setObject:screenName
                   forKey:@"screenName"];
    }
    else
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPGeneralError
                                   localizationKey:@"XboxLiveProfileNotFound"];
        }
        
        return nil;
    }
    
    // Activity (just text)
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_ACTIVITY
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [[friendProfilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
        [friend setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                   forKey:@"activityText"];
    }
    
    // Gamerscore
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_POINTS
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [friendProfilePage substringWithRange:[match rangeAtIndex:1]];
        [friend setObject:[NSNumber numberWithInt:[text intValue]] forKey:@"gamerScore"];
    }
    
    // Bio
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_BIO
                                                      options:NSRegularExpressionDotMatchesLineSeparators
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [[friendProfilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
        [friend setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                   forKey:@"bio"];
    }
    
    // Name
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_NAME
                                                      options:NSRegularExpressionDotMatchesLineSeparators
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [[friendProfilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
        [friend setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                   forKey:@"name"];
    }
    
    // Location
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_LOCATION
                                                      options:NSRegularExpressionDotMatchesLineSeparators
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [[friendProfilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
        [friend setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
                   forKey:@"location"];
    }
    
    // Motto
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_MOTTO
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [[friendProfilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
        [friend setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                   forKey:@"motto"];
    }
    
    // Icon URL
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_GAMERPIC
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [friendProfilePage substringWithRange:[match rangeAtIndex:1]];
        [friend setObject:[self largeGamerpicFromIconUrl:text] forKey:@"iconUrl"];
    }
    else
    {
        [friend setObject:[self gamerpicUrlForGamertag:screenName] forKey:@"iconUrl"];
    }
    
    // Rep
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_REP
                                                      options:NSRegularExpressionDotMatchesLineSeparators
                                                        error:NULL];
    
    match = [regex firstMatchInString:friendProfilePage
                              options:0
                                range:NSMakeRange(0, [friendProfilePage length])];
    
    if (match)
    {
        text = [friendProfilePage substringWithRange:[match rangeAtIndex:1]];
        [friend setObject:[XboxLiveParser getStarRatingFromPage:text] forKey:@"rep"];
    }
    
    NSLog(@"parseFriendProfile: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return friend;
}

-(NSDictionary*)parseProfileWithScreenName:(NSString*)screenName
                               withAccount:(XboxLiveAccount*)account
                                     error:(NSError**)error
{
    return [self parseFriendProfileWithUid:screenName
                                forAccount:account
                                     error:error];
}

-(NSArray*)parseRecentPlayersForAccount:(XboxLiveAccount*)account
                                  error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_FRIENDS];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_RECENT_LIST, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObject:vtoken 
                                                       forKey:@"__RequestVerificationToken"];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSArray *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                     error:error];
    
    if (!data)
        return NO;
    
    NSMutableArray *players = [[[NSMutableArray alloc] init] autorelease];
    [self parseFriendSection:players
             incomingFriends:data
                  isIncoming:NO
                  isOutgoing:NO];
    
    NSLog(@"parseRecentPlayersForAccount: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return players;
}

-(NSArray*)parseFriendsOfFriendForScreenName:(NSString*)screenName
                                      account:(XboxLiveAccount*)account
                                        error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_FRIENDS];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_FOF_LIST, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObjectsAndKeys:
                            vtoken, @"__RequestVerificationToken", 
                            screenName, @"gamertag", 
                            nil];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                     error:error];
    
    if (!data)
        return NO;
    
    NSMutableArray *friendsOfFriend = [[[NSMutableArray alloc] init] autorelease];
    [self parseFriendSection:friendsOfFriend
             incomingFriends:[data objectForKey:@"Friends"]
                  isIncoming:NO
                  isOutgoing:NO];
    
    NSLog(@"parseFriendsOfFriendForScreenName: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return friendsOfFriend;
}

-(BOOL)parseFriendRequestToScreenName:(NSString*)screenName
                          withAccount:(XboxLiveAccount*)account
                         actionToTake:(NSString*)action
                                error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_FRIENDS];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_FRIEND_REQUEST, 
                     LOCALE, action];
    NSDictionary *inputs = [NSDictionary dictionaryWithObjectsAndKeys:
                            vtoken, @"__RequestVerificationToken",
                            screenName, @"gamertag",
                            nil];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                          error:error];
    
    if (!data)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"FriendRequestUnsuccessful"];
        }
        
        return NO;
    }
    
    NSLog(@"parseFriendRequestToScreenName: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(NSDictionary*)parseCompareGamesWithScreenName:(NSString*)screenName
                                    withAccount:(XboxLiveAccount*)account
                                          error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_COMPARE_GAMES
                                   parameter:screenName];
    
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_COMPARE_GAMES, 
                     LOCALE, [screenName gtm_stringByEscapingForURLArgument]];
    NSDictionary *inputs = [NSDictionary dictionaryWithObject:vtoken 
                                                       forKey:@"__RequestVerificationToken"];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return nil;
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                      error:error];
    
    if (!data)
        return nil;
    
    NSMutableDictionary *payload = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray *players = [data objectForKey:@"Players"];
    if ([players count] < 2)
        return payload;
    
    NSDictionary *you = [players objectAtIndex:0];
    NSDictionary *me = [players objectAtIndex:1];
    
    NSString *yourScreenName = [you objectForKey:@"Gamertag"];
    NSString *myScreenName = [me objectForKey:@"Gamertag"];
    
    NSDictionary *overview = [NSDictionary dictionaryWithObjectsAndKeys:
                              [you objectForKey:@"Gamerpic"], @"youIconUrl",
                              [me objectForKey:@"Gamerpic"], @"meIconUrl",
                              [you objectForKey:@"Gamerscore"], @"youGamerscore",
                              [me objectForKey:@"Gamerscore"], @"meGamerscore",
                              nil];
    
    [payload setObject:overview forKey:@"overview"];
    
    NSMutableArray *games = [[[NSMutableArray alloc] init] autorelease];
    [payload setObject:games forKey:@"games"];
    
    NSArray *inGames = [data objectForKey:@"Games"];
    for (NSDictionary *inGame in inGames)
    {
        NSString *uid = [[inGame objectForKey:@"Id"] stringValue];
        NSDictionary *progRoot = [inGame objectForKey:@"Progress"];
        
        if (!progRoot)
            continue;
        
        NSDictionary *myProgress = [progRoot objectForKey:myScreenName];
        NSDictionary *yourProgress = [progRoot objectForKey:yourScreenName];
        
        if (!myProgress || !yourProgress)
            continue;
        
        NSDictionary *game = [NSDictionary dictionaryWithObjectsAndKeys:
                              uid, @"uid",
                              [inGame objectForKey:@"BoxArt"], @"boxArtUrl",
                              [inGame objectForKey:@"Url"], @"url",
                              [inGame objectForKey:@"Name"], @"title",
                              [inGame objectForKey:@"PossibleAchievements"], @"achievesTotal",
                              [inGame objectForKey:@"PossibleScore"], @"gamerScoreTotal",
                              [myProgress objectForKey:@"Achievements"], @"myAchievesUnlocked",
                              [myProgress objectForKey:@"Score"], @"myGamerScoreEarned",
                              [yourProgress objectForKey:@"Achievements"], @"yourAchievesUnlocked",
                              [yourProgress objectForKey:@"Score"], @"yourGamerScoreEarned",
                              nil];
        
        [games addObject:game];
    }
    
    NSLog(@"parseCompareGamesWithScreenName: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return payload;
}

-(NSDictionary*)parseCompareAchievementsWithUid:(NSString*)uid
                                     screenName:(NSString*)screenName
                                    withAccount:(XboxLiveAccount*)account
                                          error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *url = [NSString stringWithFormat:URL_COMPARE_ACHIEVEMENTS, 
                     LOCALE, [screenName gtm_stringByEscapingForURLArgument], uid];
    
    NSString *achievementPage = [self loadWithGET:url
                                           fields:nil
                                           useXhr:NO
                                            error:error];
    
    if (!achievementPage)
        return NO;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_COMPARE_ACH_JSON
                                                                           options:0
                                                                             error:NULL];
    
    NSTextCheckingResult *match = [regex firstMatchInString:achievementPage
                                                    options:0
                                                      range:NSMakeRange(0, [achievementPage length])];
    
    if (!match)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorAchievementsNotFound"];
        }
        
        return NO;
    }
    
    NSString *jsonScript = [achievementPage substringWithRange:[match rangeAtIndex:1]];
    NSDictionary *data = [XboxLiveParser jsonObjectFromPage:jsonScript
                                                      error:error];
    
    if (!data)
        return NO;
    
    NSMutableDictionary *payload = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSDictionary *game = [data objectForKey:@"Game"];
    
    NSArray *players = [data objectForKey:@"Players"];
    if ([players count] < 2)
        return payload;
    
    NSDictionary *you = [players objectAtIndex:0];
    NSDictionary *me = [players objectAtIndex:1];
    
    NSString *yourScreenName = [you objectForKey:@"Gamertag"];
    NSString *myScreenName = [me objectForKey:@"Gamertag"];
    
    [payload setObject:[game objectForKey:@"Name"] forKey:@"title"];
    [payload setObject:[game objectForKey:@"Url"] forKey:@"detailUrl"];
    
    [payload setObject:[you objectForKey:@"Gamerpic"] forKey:@"yourIconUrl"];
    [payload setObject:[me objectForKey:@"Gamerpic"] forKey:@"myIconUrl"];
    [payload setObject:[you objectForKey:@"Gamerscore"] forKey:@"yourGamerScore"];
    [payload setObject:[me objectForKey:@"Gamerscore"] forKey:@"myGamerscore"];
    
    NSMutableArray *achievements = [[[NSMutableArray alloc] init] autorelease];
    [payload setObject:achievements forKey:@"achievements"];
    
    NSArray *inAchieves = [data objectForKey:@"Achievements"];
    for (NSDictionary *inAchieve in inAchieves)
    {
        NSDictionary *progRoot = [inAchieve objectForKey:@"EarnDates"];
        
        if (!progRoot)
            continue;
        
        NSDictionary *myProgress = [progRoot objectForKey:myScreenName];
        NSDictionary *yourProgress = [progRoot objectForKey:yourScreenName];
        
        NSMutableDictionary *achieve = [[[NSMutableDictionary alloc] init] autorelease];
        
        [achieve setObject:[inAchieve objectForKey:@"Score"] forKey:@"gamerScore"];
        [achieve setObject:[inAchieve objectForKey:@"Id"] forKey:@"uid"];
        
        if ([[inAchieve objectForKey:@"IsHidden"] boolValue])
        {
            [achieve setObject:NSLocalizedString(@"SecretAchieveTitle", nil) forKey:@"title"];
            [achieve setObject:NSLocalizedString(@"SecretAchieveDesc", nil) forKey:@"achDescription"];
            [achieve setObject:URL_SECRET_ACHIEVE_TILE forKey:@"iconUrl"];
            [achieve setObject:[NSNumber numberWithBool:YES] forKey:@"isSecret"]; // isSecret
        }
        else
        {
            [achieve setObject:[inAchieve objectForKey:@"Name"] forKey:@"title"];
            [achieve setObject:[inAchieve objectForKey:@"Description"] forKey:@"achDescription"];
            [achieve setObject:[inAchieve objectForKey:@"TileUrl"] forKey:@"iconUrl"];
            [achieve setObject:[NSNumber numberWithBool:NO] forKey:@"isSecret"]; // isSecret
        }
        
        if (myProgress)
        {
            [achieve setObject:[NSNumber numberWithBool:NO] forKey:@"myIsLocked"];
            
            if ([[myProgress objectForKey:@"IsOffline"] boolValue])
            {
                [achieve setObject:[NSDate distantPast] forKey:@"myAcquired"];
            }
            else
            {
                NSDate *dateEarned = [XboxLiveParser ticksFromJSONString:[myProgress objectForKey:@"EarnedOn"]];
                [achieve setObject:dateEarned forKey:@"myAcquired"];
            }
        }
        else
        {
            [achieve setObject:[NSNumber numberWithBool:YES] forKey:@"myIsLocked"];
        }
        
        if (yourProgress)
        {
            [achieve setObject:[NSNumber numberWithBool:NO] forKey:@"yourIsLocked"];
            
            if ([[yourProgress objectForKey:@"IsOffline"] boolValue])
            {
                [achieve setObject:[NSDate distantPast] forKey:@"yourAcquired"];
            }
            else
            {
                NSDate *dateEarned = [XboxLiveParser ticksFromJSONString:[yourProgress objectForKey:@"EarnedOn"]];
                [achieve setObject:dateEarned forKey:@"yourAcquired"];
            }
        }
        else
        {
            [achieve setObject:[NSNumber numberWithBool:YES] forKey:@"yourIsLocked"];
        }
        
        [achievements addObject:achieve];
    }
    
    NSLog(@"parseCompareAchievementsWithScreenName: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return payload;
}

-(NSDictionary*)parseGameOverview:(NSString*)detailUrl
                            error:(NSError**)error
{
    NSString *redirUrl = [self getRedirectionUrl:detailUrl
                                           error:error];
    
    if (!redirUrl)
        return nil;
    
    NSString *overviewPage = [self loadWithGET:[redirUrl stringByAppendingString:@"?NoSplash=1"]
                                        fields:nil
                                        useXhr:NO
                                         error:error];
    
    if (!overviewPage)
        return nil;
    
    NSRegularExpression *regex;
    NSTextCheckingResult *match;
    NSString *text;
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAME_OVERVIEW_TITLE
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:overviewPage
                              options:0
                                range:NSMakeRange(0, [overviewPage length])];
    
    if (!match)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorLoadingGameDetails"];
        }
        
        return nil;
    }
    
    NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
    
    text = [[overviewPage substringWithRange:[match rangeAtIndex:1]] 
            gtm_stringByUnescapingFromHTML];
    
    [data setObject:text forKey:@"title"];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"/(\\d+)$"
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:detailUrl
                              options:0
                                range:NSMakeRange(0, [detailUrl length])];
    
    if (match)
    {
        int gameUid = [[detailUrl substringWithRange:[match rangeAtIndex:1]] intValue];
        NSString *boxArtUrl = [self getBoxArtForTitleId:[NSNumber numberWithInt:gameUid] 
                                         largeBoxArt:YES];
        
        if (boxArtUrl)
        {
            [data setObject:boxArtUrl
                     forKey:@"boxArtUrl"];
        }
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAME_OVERVIEW_DESCRIPTION
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:overviewPage
                              options:0
                                range:NSMakeRange(0, [overviewPage length])];
    
    if (match)
    {
        text = [[overviewPage substringWithRange:[match rangeAtIndex:1]] 
                gtm_stringByUnescapingFromHTML];
        
        [data setObject:text forKey:@"description"];
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAME_OVERVIEW_MANUAL
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:overviewPage
                              options:0
                                range:NSMakeRange(0, [overviewPage length])];
    
    if (match)
    {
        text = [overviewPage substringWithRange:[match rangeAtIndex:1]];
        [data setObject:text forKey:@"manualUrl"];
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAME_OVERVIEW_ESRB
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:overviewPage
                              options:0
                                range:NSMakeRange(0, [overviewPage length])];
    
    if (match)
    {
        text = [[overviewPage substringWithRange:[match rangeAtIndex:1]]
                gtm_stringByUnescapingFromHTML];
        
        [data setObject:text forKey:@"esrbDescription"];
        [data setObject:[overviewPage substringWithRange:[match rangeAtIndex:2]]
                 forKey:@"esrbIconUrl"];
    }
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAME_OVERVIEW_BANNER
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:overviewPage
                              options:0
                                range:NSMakeRange(0, [overviewPage length])];
    
    if (match)
    {
        [data setObject:[overviewPage substringWithRange:[match rangeAtIndex:1]]
                 forKey:@"bannerImageUrl"];
    }
    
    NSMutableArray *screenshots = [[NSMutableArray alloc] init];
    [data setObject:screenshots forKey:@"screenshots"];
    [screenshots release];
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAME_OVERVIEW_IMAGE
                                                      options:0
                                                        error:NULL];
    
    [regex enumerateMatchesInString:overviewPage 
                            options:0
                              range:NSMakeRange(0, [overviewPage length])
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) 
     {
         NSString *imageUrl = [overviewPage substringWithRange:[result rangeAtIndex:1]];
         [screenshots addObject:imageUrl];
     }];
    
    return data;
}

-(NSDictionary*)parseXboxLiveStatus:(NSError**)error
{
    NSString *url = [NSString stringWithFormat:URL_STATUS, LOCALE];
    NSString *statusPage = [self loadWithGET:url
                                      fields:nil
                                      useXhr:NO
                                       error:error];
    
    if (!statusPage)
        return nil;
    
    NSMutableArray *statusList = [[[NSMutableArray alloc] initWithCapacity:15] autorelease];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_STATUS_LINE
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:NULL];
    
    [regex enumerateMatchesInString:statusPage 
                            options:0
                              range:NSMakeRange(0, [statusPage length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) 
     {
         NSString *line = [statusPage substringWithRange:[result rangeAtIndex:1]];
         
         NSRegularExpression *regex;
         NSTextCheckingResult *match;
         
         regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_STATUS_NAME
                                                           options:0
                                                             error:NULL];
         
         match = [regex firstMatchInString:line
                                   options:0
                                     range:NSMakeRange(0, [line length])];
         
         if (!match)
             return;
         
         NSString *name = [[line substringWithRange:[match rangeAtIndex:1]] 
                           gtm_stringByUnescapingFromHTML];
         
         regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_STATUS_IS_OK
                                                           options:0
                                                             error:NULL];
         
         match = [regex firstMatchInString:line
                                   options:0
                                     range:NSMakeRange(0, [line length])];
         
         BOOL isOk = (match != nil);
         NSString *description;
         
         if (isOk)
         {
             description = NSLocalizedString(@"UpAndRunning", nil);
         }
         else
         {
             regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_STATUS_DESCRIPTION
                                                               options:NSRegularExpressionDotMatchesLineSeparators
                                                                 error:NULL];
             
             match = [regex firstMatchInString:line
                                       options:0
                                         range:NSMakeRange(0, [line length])];
             
             if (match)
             {
                 description = [[line substringWithRange:[match rangeAtIndex:1]] 
                                gtm_stringByUnescapingFromHTML];
             }
             else
             {
                 description = NSLocalizedString(@"UnknownProblem", nil);
             }
         }
         
         [statusList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                name, @"name",
                                [NSNumber numberWithBool:isOk], @"isOk",
                                description, @"description",
                                nil]];
     }];
    
    if ([statusList count] < 1)
    {
        [statusList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               NSLocalizedString(@"GeneralStatus", nil), @"name",
                               [NSNumber numberWithBool:NO],
                               NSLocalizedString(@"UnableToLoadStatuses", nil), @"description",
                               nil]];
    }
    
    return [NSDictionary dictionaryWithObject:statusList
                                       forKey:@"statusList"];
}

-(BOOL)parseDeleteMessageWithUid:(NSString*)uid
                      forAccount:(XboxLiveAccount*)account
                           error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_MESSAGES];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_DELETE_MESSAGE, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       vtoken, @"__RequestVerificationToken",
                                                       uid, @"msgID",
                                                       nil];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                          error:error];
    
    NSLog(@"parseDeleteMessageWithUid: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return data != nil;
}

-(BOOL)parseSendMessageToRecipients:(NSArray*)recipients
                               body:(NSString*)body
                         forAccount:(XboxLiveAccount*)account
                              error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    if (!account.canSendMessages)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPGeneralError
                                   localizationKey:@"OnlyGoldCanSendMessages"];
        }
        
        return NO;
    }
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_MESSAGES];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return NO;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_SEND_MESSAGE, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       vtoken, @"__RequestVerificationToken",
                                                       body, @"message",
                                                       recipients, @"recipients",
                                                       nil];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return NO;
    
    NSDictionary *response = [XboxLiveParser jsonObjectFromPage:page
                                                          error:error];
    
    if (!response)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"MessageCouldNotBeSent"];
        }
    }
    
    NSLog(@"parseSendMessageToRecipients: %.04f", CFAbsoluteTimeGetCurrent() - startTime);
    
    return [[response objectForKey:@"Success"] boolValue];
}

-(NSDictionary*)parseSyncMessageWithUid:(NSString*)uid
                             forAccount:(XboxLiveAccount*)account
                                  error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *vtoken = [self obtainTokenFrom:URL_VTOKEN_MESSAGES];
    if (!vtoken)
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPParsingError
                                   localizationKey:@"ErrorCannotObtainToken"];
        }
        
        return nil;
    }
    
    NSString *url = [NSString stringWithFormat:URL_JSON_READ_MESSAGE, LOCALE];
    NSDictionary *inputs = [NSDictionary dictionaryWithObjectsAndKeys:
                            vtoken, @"__RequestVerificationToken", 
                            uid, @"msgID", nil];
    
    NSString *page = [self loadWithPOST:url
                                 fields:inputs
                                 useXhr:YES
                                  error:error];
    
    if (!page)
        return nil;
    
    NSDictionary *data = [XboxLiveParser jsonDataObjectFromPage:page
                                                          error:error];
    
    if (!data)
        return nil;
    
    NSMutableDictionary *message = [[[NSMutableDictionary alloc] init] autorelease];
    NSString *messageText = [[data objectForKey:@"Text"] gtm_stringByUnescapingFromHTML];
    
    [message setObject:[NSNumber numberWithBool:YES] forKey:@"isRead"];
    [message setObject:messageText forKey:@"messageText"];
    [message setObject:messageText forKey:@"excerpt"];
    
    NSLog(@"parseMessageWithUid: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return message;
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
    [profile setObject:[object objectForKey:@"tiertext"] forKey:@"accountType"];
    
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"pointsbalancetext"] intValue]] forKey:@"pointsBalance"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"gamerscore"] intValue]] forKey:@"gamerScore"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"tier"] intValue]] forKey:@"tier"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"messages"] intValue]] forKey:@"unreadMessages"];
    [profile setObject:[NSNumber numberWithInt:[[object objectForKey:@"notifications"] intValue]] forKey:@"unreadNotifications"];
    
    url = [NSString stringWithFormat:URL_PROFILE, LOCALE];
    
    NSString *profilePage = [self loadWithGET:url
                                       fields:nil
                                       useXhr:NO
                                        error:error];
    
    if (profilePage)
    {
        NSRegularExpression *regex = nil;
        NSTextCheckingResult *match = nil;
        NSString *text = nil;
        
        // Name
        
        regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_NAME
                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                            error:NULL];
        
        match = [regex firstMatchInString:profilePage
                                  options:0
                                    range:NSMakeRange(0, [profilePage length])];
        
        if (match)
        {
            text = [[profilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
            [profile setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                       forKey:@"name"];
        }
        
        // Location
        
        regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_LOCATION
                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                            error:NULL];
        
        match = [regex firstMatchInString:profilePage
                                  options:0
                                    range:NSMakeRange(0, [profilePage length])];
        
        if (match)
        {
            text = [[profilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
            [profile setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] 
                       forKey:@"location"];
        }
        
        // Motto
        
        regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_MOTTO
                                                          options:0
                                                            error:NULL];
        
        match = [regex firstMatchInString:profilePage
                                  options:0
                                    range:NSMakeRange(0, [profilePage length])];
        
        if (match)
        {
            text = [[profilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
            [profile setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                        forKey:@"motto"];
        }
        
        // Rep
        
        regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_REP
                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                            error:NULL];
        
        match = [regex firstMatchInString:profilePage
                                  options:0
                                    range:NSMakeRange(0, [profilePage length])];
        
        if (match)
        {
            text = [profilePage substringWithRange:[match rangeAtIndex:1]];
            [profile setObject:[XboxLiveParser getStarRatingFromPage:text] forKey:@"rep"];
        }
        
        // Bio
        
        regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_SUMMARY_BIO
                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                            error:NULL];
        
        match = [regex firstMatchInString:profilePage
                                  options:0
                                    range:NSMakeRange(0, [profilePage length])];
        
        if (match)
        {
            text = [[profilePage substringWithRange:[match rangeAtIndex:1]] gtm_stringByUnescapingFromHTML];
            [profile setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                       forKey:@"bio"];
        }
    }
    
    NSLog(@"parseSynchronizeProfile: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(NSManagedObject*)profileForAccount:(XboxLiveAccount*)account
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxProfile"
                                                         inManagedObjectContext:self.context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [self.context executeFetchRequest:request 
                                                 error:nil];
    
    [request release];
    
    return [array lastObject];
}

-(NSManagedObject*)friendWithUid:(NSString*)uid
                         account:(XboxLiveAccount*)account
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                                         inManagedObjectContext:self.context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile.uuid == %@", 
                              uid, account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [self.context executeFetchRequest:request 
                                                 error:nil];
    
    [request release];
    
    return [array lastObject];
}

-(NSManagedObject*)getGameWithTitleId:(NSString*)titleId
                              account:(XboxLiveAccount*)account
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxGame"
                                                         inManagedObjectContext:self.context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile.uuid = %@", 
                              titleId, account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [self.context executeFetchRequest:request 
                                                 error:nil];
    
    [request release];
    
    return [array lastObject];
}

#pragma mark Authentication, sessions

-(void)clearAllSessions
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    
    for (NSHTTPCookie *cookie in cookies)
        [cookieStorage deleteCookie:cookie];
}

-(BOOL)restoreSessionForAccount:(XboxLiveAccount*)account
{
    return [self restoreSessionForEmailAddress:account.emailAddress];
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

-(void)saveSessionForAccount:(XboxLiveAccount*)account
{
    [self saveSessionForEmailAddress:account.emailAddress];
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

-(BOOL)authenticateAccount:(XboxLiveAccount *)account
                     error:(NSError **)error
{
    return [self authenticate:account.emailAddress
                 withPassword:account.password
                        error:error];
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

#pragma mark - write*Data

-(BOOL)synchronizeProfileWithAccount:(XboxLiveAccount*)account
                 withRetrievedObject:(NSDictionary*)dict
                               error:(NSError**)error
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxProfile"
                                                         inManagedObjectContext:self.context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", account.uuid];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    
    [request release];
    
    NSManagedObject *profile = [array lastObject];
    if (!profile)
    {
        // The profile is gone/nonexistent. Create a new one
        
        profile = [NSEntityDescription insertNewObjectForEntityForName:@"XboxProfile" 
                                                inManagedObjectContext:self.context];
        
        [profile setValue:account.uuid forKey:@"uuid"];
    }
    
    NSString *gamertag = [dict objectForKey:@"screenName"];
    
    [profile setValue:gamertag forKey:@"screenName"];
    [profile setValue:[self avatarUrlForGamertag:gamertag] forKey:@"avatarUrl"];
    
    [profile setValue:[dict objectForKey:@"iconUrl"] forKey:@"iconUrl"];
    [profile setValue:[dict objectForKey:@"accountType"] forKey:@"accountType"];
    [profile setValue:[dict objectForKey:@"pointsBalance"] forKey:@"pointsBalance"];
    [profile setValue:[dict objectForKey:@"gamerScore"] forKey:@"gamerScore"];
    [profile setValue:[dict objectForKey:@"unreadMessages"] forKey:@"unreadMessages"];
    [profile setValue:[dict objectForKey:@"unreadNotifications"] forKey:@"unreadNotifications"];
    
    id value;
    if ((value = [dict objectForKey:@"rep"]))
        [profile setValue:value forKey:@"rep"];
    if ((value = [dict objectForKey:@"motto"]))
        [profile setValue:value forKey:@"motto"];
    if ((value = [dict objectForKey:@"name"]))
        [profile setValue:value forKey:@"name"];
    if ((value = [dict objectForKey:@"location"]))
        [profile setValue:value forKey:@"location"];
    if ((value = [dict objectForKey:@"bio"]))
        [profile setValue:value forKey:@"bio"];
    
    if (![self.context save:nil])
    {
        if (error)
        {
            *error = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                   localizationKey:@"ErrorCouldNotSaveProfile"];
        }
        
        return NO;
    }
    
    account.screenName = [dict objectForKey:@"screenName"];
    account.accountTier = [[dict objectForKey:@"tier"] integerValue];
    account.lastProfileUpdate = [NSDate date];
    [account save];
    
    NSLog(@"synchronizeProfileWithAccount: %.04f", 
          CFAbsoluteTimeGetCurrent() - startTime);
    
    return YES;
}

-(void)writeProfile:(NSDictionary*)args
{
    NSError *error = nil;
    
    [self synchronizeProfileWithAccount:[args objectForKey:@"account"]
                    withRetrievedObject:[args objectForKey:@"data"]
                                  error:&error];
    
    self.lastError = error;
}

-(void)writeGames:(NSDictionary*)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSDictionary *data = [args objectForKey:@"data"];
    XboxLiveAccount *account = [args objectForKey:@"account"];
    
    NSManagedObject *profile = [self profileForAccount:account];
    if (!profile)
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorProfileNotFound"];
        
        return;
    }
    
    NSDate *lastUpdated = [NSDate date];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxGame"
                                                         inManagedObjectContext:self.context];
    
    int newItems = 0;
    int existingItems = 0;
    int listOrder = 0;
    
    NSArray *inGames = [data objectForKey:@"games"];
    
    for (NSDictionary *inGame in inGames)
    {
        listOrder++;
        
        // Fetch game, or create a new one
        NSManagedObject *game;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile == %@", 
                                  [inGame objectForKey:@"uid"], profile];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSArray *array = [self.context executeFetchRequest:request 
                                                     error:nil];
        
        [request release];
        
        if (!(game = [array lastObject]))
        {
            newItems++;
            game = [NSEntityDescription insertNewObjectForEntityForName:@"XboxGame"
                                                 inManagedObjectContext:self.context];
            
            // These will not change, so just set them up the first time
            
            [game setValue:[inGame objectForKey:@"uid"] forKey:@"uid"];
            [game setValue:profile forKey:@"profile"];
            [game setValue:[inGame objectForKey:@"gameUrl"] forKey:@"gameUrl"];
            [game setValue:[inGame objectForKey:@"title"] forKey:@"title"];
            [game setValue:[inGame objectForKey:@"boxArtUrl"] forKey:@"boxArtUrl"];
            [game setValue:[NSNumber numberWithBool:YES] forKey:@"achievesDirty"];
        }
        else
        {
            existingItems++;
            if (![[game valueForKey:@"achievesUnlocked"] isEqualToNumber:[inGame objectForKey:@"achievesUnlocked"]] ||
                ![[game valueForKey:@"achievesTotal"] isEqualToNumber:[inGame objectForKey:@"achievesTotal"]] ||
                ![[game valueForKey:@"gamerScoreEarned"] isEqualToNumber:[inGame objectForKey:@"gamerScoreEarned"]] ||
                ![[game valueForKey:@"gamerScoreTotal"] isEqualToNumber:[inGame objectForKey:@"gamerScoreTotal"]])
            {
                [game setValue:[NSNumber numberWithBool:YES] forKey:@"achievesDirty"];
            }
        }
        
        // We now have a game object (new or existing)
        // Handle the rest of the data
        
        // Game achievements
        
        [game setValue:[inGame objectForKey:@"achievesUnlocked"] forKey:@"achievesUnlocked"];
        [game setValue:[inGame objectForKey:@"achievesTotal"] forKey:@"achievesTotal"];
        
        // Game score
        
        [game setValue:[inGame objectForKey:@"gamerScoreEarned"] forKey:@"gamerScoreEarned"];
        [game setValue:[inGame objectForKey:@"gamerScoreTotal"] forKey:@"gamerScoreTotal"];
        
        // Last played
        
        NSDate *lastPlayed = nil;
        if ([inGame objectForKey:@"lastPlayed"] != [NSDate distantPast])
            lastPlayed = [inGame objectForKey:@"lastPlayed"];
        
        [game setValue:lastPlayed forKey:@"lastPlayed"];
        [game setValue:lastUpdated forKey:@"lastUpdated"];
        [game setValue:[NSNumber numberWithInt:listOrder] forKey:@"listOrder"];
    }
    
    // Find "stale" games
    
    NSPredicate *stalePredicate = [NSPredicate predicateWithFormat:@"lastUpdated != %@ AND profile == %@", 
                                   lastUpdated, profile];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:stalePredicate];
    
    NSArray *staleObjs = [self.context executeFetchRequest:request 
                                                     error:NULL];
    [request release];
    
    // Delete "stale" games
    
    for (NSManagedObject *staleObj in staleObjs)
        [self.context deleteObject:staleObj];
    
    // Save
    
    if (![self.context save:NULL])
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorCouldNotSaveGameList"];
        
        return;
    }
    
    account.lastGamesUpdate = [NSDate date];
    [account save];
    
    NSLog(@"writeGames: (%i new, %i existing) %.04fs", 
          newItems, existingItems, CFAbsoluteTimeGetCurrent() - startTime);
}

-(void)writeAchievements:(NSDictionary*)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSDictionary *data = [args objectForKey:@"data"];
    XboxLiveAccount *account = [args objectForKey:@"account"];
    
    NSManagedObject *game = [self getGameWithTitleId:[data objectForKey:@"titleId"]
                                             account:account];
    
    if (!game)
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorGameNotFound"];
        return;
    }
    
    NSDate *lastUpdated = [NSDate date];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxAchievement"
                                                         inManagedObjectContext:self.context];
    
    NSArray *inAchieves = [data objectForKey:@"achievements"];
    
    int newItems = 0;
    int existingItems = 0;
    
    for (NSDictionary *inAchieve in inAchieves)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND game == %@", 
                                  [inAchieve objectForKey:@"uid"], game];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSArray *array = [self.context executeFetchRequest:request 
                                                     error:nil];
        
        [request release];
        
        BOOL update = NO;
        NSManagedObject *achieve = [array lastObject];
        
        if (!achieve)
        {
            achieve = [NSEntityDescription insertNewObjectForEntityForName:@"XboxAchievement"
                                                    inManagedObjectContext:self.context];
            
            [achieve setValue:game forKey:@"game"];
            [achieve setValue:[inAchieve objectForKey:@"uid"] forKey:@"uid"];
            [achieve setValue:[inAchieve objectForKey:@"gamerScore"] forKey:@"gamerScore"];
            
            newItems++;
            update = YES;
        }
        else
        {
            existingItems++;
            update = [[inAchieve objectForKey:@"isLocked"] boolValue] 
            != [[achieve valueForKey:@"isLocked"] boolValue];
        }
        
        [achieve setValue:lastUpdated forKey:@"lastUpdated"];
        [achieve setValue:[inAchieve objectForKey:@"sortIndex"] forKey:@"sortIndex"];
        
        if (update)
        {
            [achieve setValue:[inAchieve objectForKey:@"isSecret"] forKey:@"isSecret"];
            [achieve setValue:[inAchieve objectForKey:@"isLocked"] forKey:@"isLocked"];
            [achieve setValue:[inAchieve objectForKey:@"title"] forKey:@"title"];
            [achieve setValue:[inAchieve objectForKey:@"iconUrl"] forKey:@"iconUrl"];
            [achieve setValue:[inAchieve objectForKey:@"achDescription"] forKey:@"achDescription"];
            [achieve setValue:[inAchieve objectForKey:@"acquired"] forKey:@"acquired"];
        }
    }
    
    NSDictionary *inGame = [data objectForKey:@"game"];
    if (inGame)
    {
        [game setValue:[inGame objectForKey:@"achievesTotal"]
                forKey:@"achievesTotal"];
        [game setValue:[inGame objectForKey:@"gamerScoreTotal"]
                forKey:@"gamerScoreTotal"];
        
        if ([inGame objectForKey:@"achievesUnlocked"])
            [game setValue:[inGame objectForKey:@"achievesUnlocked"]
                    forKey:@"achievesUnlocked"];
        if ([inGame objectForKey:@"gamerScoreEarned"])
            [game setValue:[inGame objectForKey:@"gamerScoreEarned"]
                    forKey:@"gamerScoreEarned"];
        if ([inGame objectForKey:@"lastPlayed"])
            [game setValue:[inGame objectForKey:@"lastPlayed"]
                    forKey:@"lastPlayed"];
        
        [game setValue:lastUpdated
                forKey:@"lastUpdated"];
        [game setValue:[NSNumber numberWithBool:NO]
                forKey:@"achievesDirty"];
    }
    
    // Find achievements no longer in the game (will it ever happen?)
    
    NSPredicate *removedPredicate = [NSPredicate predicateWithFormat:@"lastUpdated != %@ AND game == %@", 
                                     lastUpdated, game];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:removedPredicate];
    
    NSArray *removedObjs = [self.context executeFetchRequest:request 
                                                       error:NULL];
    
    [request release];
    
    // Delete removed achievements
    
    for (NSManagedObject *removedObj in removedObjs)
        [self.context deleteObject:removedObj];
    
    // Save
    
    if (![self.context save:NULL])
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorCouldNotSaveGameList"];
        return;
    }
    
    NSLog(@"writeAchievements: (%i new, %i existing) %.04fs", 
          newItems, existingItems, CFAbsoluteTimeGetCurrent() - startTime);
}

-(void)writeMessages:(NSDictionary *)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSDictionary *data = [args objectForKey:@"data"];
    XboxLiveAccount *account = [args objectForKey:@"account"];
    
    NSManagedObject *profile = [self profileForAccount:account];
    if (!profile)
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorProfileNotFound"];
        
        return;
    }
    
    NSDate *lastUpdated = [NSDate date];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxMessage"
                                                         inManagedObjectContext:self.context];
    
    int newItems = 0;
    int existingItems = 0;
    
    NSArray *inMessages = [data objectForKey:@"messages"];
    
    for (NSDictionary *inMessage in inMessages)
    {
        // Fetch game, or create a new one
        NSManagedObject *message;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile == %@", 
                                  [inMessage objectForKey:@"uid"], profile];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSArray *array = [self.context executeFetchRequest:request 
                                                     error:nil];
        
        [request release];
        
        if (!(message = [array lastObject]))
        {
            newItems++;
            message = [NSEntityDescription insertNewObjectForEntityForName:@"XboxMessage"
                                                    inManagedObjectContext:self.context];
            
            // These will not change, so just set them up the first time
            
            [message setValue:profile forKey:@"profile"];
            [message setValue:[inMessage objectForKey:@"uid"] forKey:@"uid"];
            [message setValue:[inMessage objectForKey:@"sender"] forKey:@"sender"];
            [message setValue:[inMessage objectForKey:@"senderIconUrl"] forKey:@"senderIconUrl"];
            [message setValue:[inMessage objectForKey:@"isDeletable"] forKey:@"isDeletable"];
            [message setValue:[inMessage objectForKey:@"hasText"] forKey:@"hasText"];
            [message setValue:[inMessage objectForKey:@"hasPicture"] forKey:@"hasPicture"];
            [message setValue:[inMessage objectForKey:@"hasVoice"] forKey:@"hasVoice"];
            [message setValue:[inMessage objectForKey:@"sent"] forKey:@"sent"];
            [message setValue:[NSNumber numberWithBool:YES] forKey:@"isDirty"];
            
            [message setValue:[inMessage objectForKey:@"messageText"] forKey:@"excerpt"];
            [message setValue:[inMessage objectForKey:@"messageText"] forKey:@"messageText"];
        }
        else
        {
            existingItems++;
        }
        
        // We now have a message object (new or existing)
        // Handle the rest of the data
        
        [message setValue:lastUpdated forKey:@"lastUpdated"];
        [message setValue:[inMessage objectForKey:@"isRead"] forKey:@"isRead"];
    }
    
    // Find missing messages
    
    NSPredicate *stalePredicate = [NSPredicate predicateWithFormat:@"lastUpdated != %@ AND profile == %@", 
                                   lastUpdated, profile];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:stalePredicate];
    
    NSArray *staleObjs = [self.context executeFetchRequest:request 
                                                     error:NULL];
    [request release];
    
    // Delete missing messages
    
    for (NSManagedObject *staleObj in staleObjs)
        [self.context deleteObject:staleObj];
    
    // Save
    
    if (![self.context save:NULL])
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorCouldNotSaveMessageList"];
        
        return;
    }
    
    account.lastMessagesUpdate = [NSDate date];
    [account save];
    
    NSLog(@"writeMessages: (%i new, %i existing) %.04fs", 
          newItems, existingItems, CFAbsoluteTimeGetCurrent() - startTime);
}

-(void)writeFriends:(NSDictionary *)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSDictionary *data = [args objectForKey:@"data"];
    XboxLiveAccount *account = [args objectForKey:@"account"];
    
    NSManagedObject *profile = [self profileForAccount:account];
    if (!profile)
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorProfileNotFound"];
        
        return;
    }
    
    NSDate *lastUpdated = [NSDate date];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                                         inManagedObjectContext:self.context];
    
    int newItems = 0;
    int existingItems = 0;
    
    NSArray *inFriends = [data objectForKey:@"friends"];
    
    for (NSDictionary *inFriend in inFriends)
    {
        NSManagedObject *friend;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile == %@", 
                                  [inFriend objectForKey:@"uid"], profile];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        [request setEntity:entityDescription];
        [request setPredicate:predicate];
        
        NSArray *array = [self.context executeFetchRequest:request 
                                                     error:nil];
        
        [request release];
        
        if (!(friend = [array lastObject]))
        {
            newItems++;
            friend = [NSEntityDescription insertNewObjectForEntityForName:@"XboxFriend"
                                                   inManagedObjectContext:self.context];
            
            // These will not change, so just set them up the first time
            
            [friend setValue:profile forKey:@"profile"];
            [friend setValue:[inFriend objectForKey:@"uid"] forKey:@"uid"];
            
            // These will be updated later by other parsers
            
            [friend setValue:[NSDate distantPast] forKey:@"profileLastUpdated"];
            [friend setValue:[NSNumber numberWithBool:NO] forKey:@"isFavorite"];
            [friend setValue:nil forKey:@"bio"];
            [friend setValue:nil forKey:@"location"];
            [friend setValue:nil forKey:@"motto"];
            [friend setValue:nil forKey:@"name"];
            [friend setValue:[NSNumber numberWithInt:0] forKey:@"rep"];
        }
        else
        {
            existingItems++;
        }
        
        // We now have an object (new or existing)
        // Handle the rest of the data
        
        NSString *gamertag = [inFriend objectForKey:@"screenName"];
        
        [friend setValue:gamertag forKey:@"screenName"];
        [friend setValue:[self avatarUrlForGamertag:gamertag] forKey:@"avatarUrl"];
        [friend setValue:lastUpdated forKey:@"lastUpdated"];
        [friend setValue:[inFriend objectForKey:@"isOnline"] forKey:@"isOnline"];
        [friend setValue:[inFriend objectForKey:@"iconUrl"] forKey:@"iconUrl"];
        [friend setValue:[inFriend objectForKey:@"gamerScore"] forKey:@"gamerScore"];
        [friend setValue:[inFriend objectForKey:@"lastSeen"] forKey:@"lastSeen"];
        [friend setValue:[inFriend objectForKey:@"activityText"] forKey:@"activityText"];
        [friend setValue:[inFriend objectForKey:@"isIncoming"] forKey:@"isIncoming"];
        [friend setValue:[inFriend objectForKey:@"isOutgoing"] forKey:@"isOutgoing"];
        
        if ([[inFriend objectForKey:@"isIncoming"] boolValue] ||
            [[inFriend objectForKey:@"isOutgoing"] boolValue])
        {
            [friend setValue:[NSNumber numberWithInt:XBLFriendPending] forKey:@"statusCode"];
        }
        else if ([[inFriend objectForKey:@"isOnline"] boolValue])
        {
            [friend setValue:[NSNumber numberWithInt:XBLFriendOnline] forKey:@"statusCode"];
        }
        else
        {
            [friend setValue:[NSNumber numberWithInt:XBLFriendOffline] forKey:@"statusCode"];
        }
        
        id titleObj;
        if ((titleObj = [inFriend objectForKey:@"activityTitleId"]))
            [friend setValue:titleObj forKey:@"activityTitleId"];
        if ((titleObj = [inFriend objectForKey:@"activityTitleName"]))
            [friend setValue:titleObj forKey:@"activityTitleName"];
        if ((titleObj = [inFriend objectForKey:@"activityTitleIconUrl"]))
            [friend setValue:titleObj forKey:@"activityTitleIconUrl"];
    }
    
    // Find missing objects
    
    NSPredicate *stalePredicate = [NSPredicate predicateWithFormat:@"lastUpdated != %@ AND profile == %@", 
                                   lastUpdated, profile];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:stalePredicate];
    
    NSArray *staleObjs = [self.context executeFetchRequest:request 
                                                     error:NULL];
    [request release];
    
    // Delete missing objects
    
    for (NSManagedObject *staleObj in staleObjs)
        [self.context deleteObject:staleObj];
    
    // Save
    
    if (![self.context save:NULL])
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorCouldNotSaveFriendsList"];
        
        return;
    }
    
    account.lastFriendsUpdate = [NSDate date];
    [account save];
    
    NSLog(@"writeFriends: (%i new, %i existing) %.04fs", 
          newItems, existingItems, CFAbsoluteTimeGetCurrent() - startTime);
}

-(void)writeFriendProfile:(NSDictionary *)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSDictionary *data = [args objectForKey:@"data"];
    XboxLiveAccount *account = [args objectForKey:@"account"];
    NSString *uid = [args objectForKey:@"uid"];
    
    NSManagedObject *friend = [self friendWithUid:uid
                                          account:account];
    
    // No need to throw an error if friend is not found
    
    if (friend)
    {
        NSArray *keys = [NSArray arrayWithObjects:
                         @"gamerScore",
                         @"bio", 
                         @"location", 
                         @"motto",
                         @"name",
                         @"rep",
                         nil];
        
        for (NSString *key in keys) 
        {
            id info = [data objectForKey:key];
            if (info)
                [friend setValue:info forKey:key];
        }
        
        [friend setValue:[NSDate date] forKey:@"lastUpdated"];
        [friend setValue:[NSDate date] forKey:@"profileLastUpdated"];
        
        if (![self.context save:NULL])
        {
            self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                           localizationKey:@"ErrorCouldNotSaveFriendsProfile"];
            
            return;
        }
    }
    else
    {
        NSLog(@"Friend not found");
    }
    
    [account save];
    
    NSLog(@"writeFriendProfile: %.04fs", 
          CFAbsoluteTimeGetCurrent() - startTime);
}

-(void)writeRemoveFromFriends:(NSDictionary *)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    XboxLiveAccount *account = [args objectForKey:@"account"];
    NSString *screenName = [args objectForKey:@"screenName"];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxFriend"
                                                         inManagedObjectContext:self.context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"screenName == %@ AND profile.uuid == %@", 
                              screenName, account.uuid];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [self.context executeFetchRequest:request 
                                                 error:nil];
    
    [request release];
    
    NSManagedObject *obj = [array lastObject];
    if (obj)
    {
        [self.context deleteObject:obj];
        [self.context save:NULL]; // Suppress any errors
    }
    
    account.lastFriendsUpdate = [NSDate distantPast];
    [account save];
    
    NSLog(@"writeRemoveFromFriends: %.04fs", 
          CFAbsoluteTimeGetCurrent() - startTime);
}

-(void)writeDeleteMessage:(NSDictionary *)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *uid = [args objectForKey:@"uid"];
    XboxLiveAccount *account = [args objectForKey:@"account"];
    
    NSManagedObject *profile = [self profileForAccount:account];
    if (!profile)
    {
        self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                       localizationKey:@"ErrorProfileNotFound"];
        
        return;
    }
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxMessage"
                                                         inManagedObjectContext:self.context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile == %@", 
                              uid, profile];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [self.context executeFetchRequest:request 
                                                 error:nil];
    
    [request release];
    
    NSManagedObject *message = [array lastObject];
    if (message)
    {
        [self.context deleteObject:message];
        if (![self.context save:NULL])
        {
            self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                           localizationKey:@"ErrorCouldNotSaveChanges"];
            
            return;
        }
    }
    
    [account save];
    
    NSLog(@"writeDeleteMessage: %.04fs", CFAbsoluteTimeGetCurrent() - startTime);
}

-(void)writeSyncMessage:(NSDictionary*)args
{
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent(); 
    
    NSString *uid = [args objectForKey:@"uid"];
    XboxLiveAccount *account = [args objectForKey:@"account"];
    NSDictionary *inMessage = [args objectForKey:@"data"];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XboxMessage"
                                                         inManagedObjectContext:self.context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@ AND profile.uuid == %@", 
                              uid, account.uuid];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSArray *array = [self.context executeFetchRequest:request 
                                                 error:nil];
    
    [request release];
    
    NSManagedObject *message = [array lastObject];
    if (message && inMessage)
    {
        [message setValue:[inMessage objectForKey:@"isRead"]
                   forKey:@"isRead"];
        [message setValue:[inMessage objectForKey:@"messageText"]
                   forKey:@"messageText"];
        [message setValue:[inMessage objectForKey:@"excerpt"]
                   forKey:@"excerpt"];
        [message setValue:[NSNumber numberWithBool:NO]
                   forKey:@"isDirty"];
        
        if (![self.context save:NULL])
        {
            self.lastError = [XboxLiveParser errorWithCode:XBLPCoreDataError
                                           localizationKey:@"ErrorCouldNotSaveChanges"];
            
            return;
        }
    }
    
    [account save];
    
    NSLog(@"writeSyncMessage: %.04fs", CFAbsoluteTimeGetCurrent() - startTime);
}

#pragma mark Helpers

-(NSString*)getBoxArtForTitleId:(NSNumber*)titleId
                    largeBoxArt:(BOOL)largeBoxArt
{
    if (!titleId)
        return nil;
    
    return [NSString stringWithFormat:BOXART_TEMPLATE, 
            [titleId intValue], LOCALE, largeBoxArt ? @"large" : @"small"];
}

-(NSString*)getDetailUrlForTitleId:(NSNumber *)titleId
{
    if (!titleId)
        return nil;
    
    return [NSString stringWithFormat:GAME_DETAIL_URL_TEMPLATE, 
            LOCALE, [titleId intValue]];
}

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
    NSDictionary *dict = [json JSONValue];
    
    if (!dict)
    {
        if (error)
        {
            *error = [self errorWithCode:XBLPParsingError
                         localizationKey:@"ErrorParsingJSONFormat"];
        }
        
        return nil;
    }
    
    return dict;
}

+(id)jsonDataObjectFromPage:(NSString*)json
                      error:(NSError**)error
{
    NSDictionary *object = [XboxLiveParser jsonObjectFromPage:json
                                                        error:error];
    
    if (!object)
        return nil;
    
    if (![[object objectForKey:@"Success"] boolValue])
    {
        if (error)
        {
            *error = [self errorWithCode:XBLPGeneralError
                         localizationKey:@"ErrorJSONDidNotSucceed"];
        }
        
        return nil;
    }
    
    return [object objectForKey:@"Data"];
}

+(NSDate*)ticksFromJSONString:(NSString*)jsonTicks
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
    NSMutableDictionary *inputs = [[[NSMutableDictionary alloc] init] autorelease];
    
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
    
    return inputs;
}

-(NSString*)obtainTokenFrom:(NSString*)url
                  parameter:(NSString*)param
{
    NSString *page = [self loadWithGET:[NSString stringWithFormat:url, 
                                        LOCALE, [param gtm_stringByEscapingForURLArgument]]
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

-(NSString*)obtainTokenFrom:(NSString*)url
{
    NSString *page = [self loadWithGET:[NSString stringWithFormat:url, LOCALE]
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

-(NSString*)parseObtainNewToken
{
    return [self obtainTokenFrom:URL_VTOKEN];
}

-(NSString*)largeGamerpicFromIconUrl:(NSString*)url
{
    NSRegularExpression *regex = nil;
    NSTextCheckingResult *match = nil;
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAMERPIC_CLASSIC
                                                      options:0
                                                        error:NULL];
    
    match = [regex firstMatchInString:url
                              options:0
                                range:NSMakeRange(0, [url length])];
    
    // Classic (non-avatar) gamerpic
    
    if (match)
    {
        return [NSString stringWithFormat:@"%@2%@", 
                [url substringWithRange:NSMakeRange(0, [match rangeAtIndex:1].location)],
                [url substringWithRange:[match rangeAtIndex:2]]];
    }
    
    // Avatar (NXE) gamerpic
    
    regex = [NSRegularExpression regularExpressionWithPattern:PATTERN_GAMERPIC_AVATAR
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:NULL];
    
    match = [regex firstMatchInString:url
                              options:0
                                range:NSMakeRange(0, [url length])];
    
    if (match)
    {
        return [NSString stringWithFormat:@"%@l%@", 
                [url substringWithRange:NSMakeRange(0, [match rangeAtIndex:1].location)],
                [url substringWithRange:[match rangeAtIndex:2]]];
    }
    
    NSLog(@"%@ has an unrecognized format; returning original", url);
    
    return url;
}

-(NSString*)gamerpicUrlForGamertag:(NSString*)gamertag
{
    if (!gamertag)
        return nil;
    
    return [NSString stringWithFormat:URL_GAMERPIC,
            [gamertag gtm_stringByEscapingForURLArgument]];
}

-(NSString*)avatarUrlForGamertag:(NSString *)gamertag
{
    if (!gamertag)
        return nil;
    
    return [NSString stringWithFormat:URL_AVATAR_BODY,
            [gamertag gtm_stringByEscapingForURLArgument]];
}

#pragma mark Core stuff

- (NSString*)getRedirectionUrl:(NSString*)url
                         error:(NSError**)error
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:error];
    
    return [[response URL] absoluteString];
}

- (NSString*)loadWithMethod:(NSString*)method
                        url:(NSString*)requestUrl
                     fields:(NSDictionary*)fields
                 addHeaders:(NSDictionary*)headers
                     useXhr:(BOOL)useXhr
                      error:(NSError**)error
{
    NSString *httpBody = nil;
    NSURL *url = [NSURL URLWithString:requestUrl];
    
    NSLog(@"Fetching %@ ...", requestUrl);
    
    if (fields)
    {
        NSMutableArray *urlBuilder = [[NSMutableArray alloc] init];
        
        for (NSString *key in fields)
        {
            NSString *ueKey = [key gtm_stringByEscapingForURLArgument];
            id field = [fields objectForKey:key];
            
            if ([field isKindOfClass:[NSArray class]])
            {
                for (NSString *item in field)
                {
                    [urlBuilder addObject:[NSString stringWithFormat:@"%@=%@", 
                                           ueKey, [item gtm_stringByEscapingForURLArgument]]];
                }
            }
            else
            {
                [urlBuilder addObject:[NSString stringWithFormat:@"%@=%@", 
                                       ueKey, [field gtm_stringByEscapingForURLArgument]]];
            }
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
