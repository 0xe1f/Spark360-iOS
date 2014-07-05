/*
 * Spark 360 for iOS
 * https://github.com/pokebyte/Spark360-iOS
 *
 * Copyright (C) 2011-2014 Akop Karapetyan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

#import <Foundation/Foundation.h>

@interface XboxLiveAccount : NSObject

-(id)initWithUuid:(NSString*)uuid;
+(id)preferencesForUuid:(NSString*)uuid;

-(void)reload;
-(void)save;
-(void)purge;

-(NSString*)uuid;

-(NSString*)screenName;
-(void)setScreenName:(NSString*)screenName;

-(NSDate*)lastProfileUpdate;
-(void)setLastProfileUpdate:(NSDate*)lastUpdate;

-(NSDate*)lastGamesUpdate;
-(void)setLastGamesUpdate:(NSDate*)lastUpdate;

-(NSDate*)lastMessagesUpdate;
-(void)setLastMessagesUpdate:(NSDate*)lastUpdate;

-(NSDate*)lastFriendsUpdate;
-(void)setLastFriendsUpdate:(NSDate*)lastUpdate;

-(NSNumber*)stalePeriodInSeconds;
-(void)setStalePeriodInSeconds:(NSNumber*)browseRefreshPeriodInSeconds;

-(NSString*)emailAddress;
-(void)setEmailAddress:(NSString*)emailAddress;

-(NSInteger)accountTier;
-(void)setAccountTier:(NSInteger)accountTier;

-(NSString*)password;
-(void)setPassword:(NSString*)password;

-(BOOL)isEqualToAccount:(XboxLiveAccount*)account;

-(BOOL)areGamesStale;
-(BOOL)areMessagesStale;
-(BOOL)areFriendsStale;
-(BOOL)isProfileStale;
-(BOOL)isDataStale:(NSDate*)lastRefreshed;

-(BOOL)canSendMessages;

@end
