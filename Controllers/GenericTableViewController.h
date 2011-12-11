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
{
    EGORefreshTableHeaderView *_refreshHeaderView;
};

@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, assign) IBOutlet UITableViewCell *tableViewCell;

-(void)refreshUsingRefreshHeaderTableView;
-(void)hideRefreshHeaderTableView;

@end
