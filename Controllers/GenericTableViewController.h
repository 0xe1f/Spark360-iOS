//
//  GenericTableViewController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"
#import "EGORefreshTableHeaderView.h"

@interface GenericTableViewController : GenericController <UITableViewDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, assign) IBOutlet UITableViewCell *tableViewCell;

-(UIImage*)tableCellImageFromUrl:(NSString*)url
                       indexPath:(NSIndexPath*)indexPath;
-(UIImage*)tableCellImageFromUrl:(NSString*)url
                        cropRect:(CGRect)cropRect
                       indexPath:(NSIndexPath*)indexPath;

-(void)synchronizeWithRemote;
-(void)mustSynchronizeWithRemote;
-(NSDate*)lastSynchronized;
-(void)updateSynchronizationDate;

-(void)hideRefreshHeaderTableView;
-(BOOL)useRefreshTableHeaderView;

@end
