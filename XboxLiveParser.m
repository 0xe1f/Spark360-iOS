//
//  XboxLiveParser.m
//  ListTest
//
//  Created by Akop Karapetyan on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GTMNSString+HTML.h"
#import "XboxLiveParser.h"

@implementation XboxLiveParser

NSString* const URL_GAMES = @"http://www.akop.org/xtest/games.html";

NSString* const PATTERN_GAMES = @"<div *class=\"LineItem\">(.*?)<br clear=\"all\" />";
NSString* const PATTERN_GAME_TITLE = @"<h3><a href=\"([^\"]*)\"[^>]*?>([^<]*)<";
NSString* const PATTERN_GAME_GAMERSCORE = @"GamerScore Stat\">\\s*(\\d+)\\s*\\/\\s*(\\d+)\\s*<";
NSString* const PATTERN_GAME_ACHIEVEMENTS = @"Achievement Stat\">\\s*(\\d+)\\s*\\/\\s*(\\d+)\\s*<";
NSString* const PATTERN_GAME_ACHIEVEMENT_URL = @"href=\"([^\"]*Achievements\\?titleId=(\\d+)[^\"]*)\"";
NSString* const PATTERN_GAME_BOXART_URL = @"src=\"([^\"]*)\" class=\"BoxShot\"";
NSString* const PATTERN_GAME_LAST_PLAYED = @"class=\"lastPlayed\">\\s*(\\S+)\\s*<";

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSDate*)parseDate:(NSString*)dateStr
{
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [dateFormatter dateFromString:dateStr];
}

- (NSString*)getUniversalIcon:(NSString*)icon
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

- (void)parseGames:(XboxLiveAccount*)account
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
                 
                 [game setValue:[self getUniversalIcon:boxArtUrl] forKey:@"BoxArtUrl"];
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
             lastPlayed = [self parseDate:[gameSection substringWithRange:[match rangeAtIndex:1]]];
         
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

@end
