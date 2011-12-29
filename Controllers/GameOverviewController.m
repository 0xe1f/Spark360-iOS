//
//  GameOverviewController.m
//  BachZero
//
//  Created by Akop Karapetyan on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameOverviewController.h"

#import "TaskController.h"
#import "ImageCache.h"
#import "ScreenshotGridViewCell.h"

#import "ImageViewController.h"

@interface GameOverviewController (Private)

-(void)updateGameDetails;

@end

@implementation GameOverviewController

@synthesize gameTitle = _gameTitle;
@synthesize detailUrl = _detailUrl;
@synthesize gameDetails = _gameDetails;
@synthesize screenshots = _screenshots;

@synthesize gameDescription;
@synthesize boxArt;
@synthesize gridView;
@synthesize gameTitleLabel;

-(id)initWithTitle:(NSString*)gameTitle
         detailUrl:(NSString*)detailUrl
           account:(XboxLiveAccount *)account;
{
    if ((self = [super initWithAccount:account
                               nibName:@"GameOverviewController"]))
    {
        self.gameDetails = nil;
        self.gameTitle = gameTitle;
        self.detailUrl = detailUrl;
        
        _screenshots = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    self.gameDetails = nil;
    self.gameTitle = nil;
    self.detailUrl = nil;
    self.screenshots = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncCompleted:)
                                                 name:BACHGameOverviewLoaded
                                               object:nil];
    
    self.title = NSLocalizedString(@"GameDetails", nil);
    self.gameTitleLabel.text = self.gameTitle;
    
    [[TaskController sharedInstance] loadGameOverviewWithUrl:self.detailUrl
                                                     account:self.account];
    
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BACHGameOverviewLoaded
                                                  object:nil];
}

#pragma mark Grid View Data Source

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)aGridView
{
    return [self.screenshots count];
}

- (AQGridViewCell*)gridView:(AQGridView*)aGridView 
         cellForItemAtIndex:(NSUInteger)index
{
    ScreenshotGridViewCell* cell = (ScreenshotGridViewCell*)[aGridView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell)
    {
        cell = [[ScreenshotGridViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 135.0, 76.0)
                                             reuseIdentifier:@"Cell"];
        
        cell.selectionGlowColor = [UIColor blueColor];
        cell.selectionGlowShadowRadius = 4.0;
    }
    
    cell.image = [[self.screenshots objectAtIndex:index] objectAtIndex:1];
    
    return cell;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView*)aGridView
{
    return CGSizeMake(145.0, 86.0);
}

- (void)gridView:(AQGridView*)gridView 
didSelectItemAtIndex:(NSUInteger)index
{
    NSString *url = [[self.screenshots objectAtIndex:index] objectAtIndex:0];
    
    ImageViewController *ctlr = [[ImageViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:ctlr animated:YES];
    [ctlr release];
}

#pragma mark - Notifications

-(void)syncCompleted:(NSNotification *)notification
{
    NSString *detailUrl = [[notification userInfo] objectForKey:BACHNotificationUid];
    
    if ([detailUrl isEqualToString:self.detailUrl])
    {
        self.gameDetails = [[notification userInfo] objectForKey:BACHNotificationData];
        
        NSArray *screenshots = [self.gameDetails objectForKey:@"screenshots"];
        
        [self.screenshots removeAllObjects];
        
        for (NSString *screenshotUrl in screenshots) 
        {
            UIImage *screenshot = [[ImageCache sharedInstance] getCachedFile:screenshotUrl
                                                                notifyObject:self
                                                              notifySelector:@selector(screenshotLoaded:)];
            
            if (screenshot)
            {
                [self.screenshots addObject:[NSArray arrayWithObjects:screenshotUrl,
                                             screenshot, nil]];
            }
        }
        
        [self updateGameDetails];
    }
}

-(void)onSyncError:(NSNotification *)notification
{
    [super onSyncError:notification];
    
    if (!self.gameDetails)
    {
        // Assume information could not be found. Close the view
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)imageLoaded:(NSString*)imageUrl
{
    [self updateGameDetails];
}

- (void)screenshotLoaded:(NSString*)imageUrl
{
    UIImage *screenshot = [[ImageCache sharedInstance] getCachedFile:imageUrl
                                                        notifyObject:nil
                                                      notifySelector:nil];
    
    if (screenshot)
    {
        [self.screenshots addObject:[NSArray arrayWithObjects:imageUrl, 
                                     screenshot, nil]];
    }
    
    [self.gridView reloadData];
}

#pragma mark - Misc

-(void)updateGameDetails
{
    NSDictionary *data = self.gameDetails;
    
    self.gameDescription.text = [data objectForKey:@"description"];
    
    UIImage *boxArtImage = [[ImageCache sharedInstance] getCachedFile:[data objectForKey:@"boxArtUrl"]
                                                       notifyObject:self
                                                     notifySelector:@selector(imageLoaded:)];
    
    self.boxArt.image = boxArtImage;
    
    [self.gridView reloadData];
}

@end
