//
//  ImageViewController.h
//  BachZero
//
//  Created by Akop Karapetyan on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericController.h"

@interface ImageViewController : GenericController

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

-(id)initWithUrl:(NSString*)url;

@end
