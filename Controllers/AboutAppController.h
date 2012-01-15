//
//  AboutAppController.h
//  BachZero
//
//  Created by Akop Karapetyan on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutAppController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UITextView *disclaimerView;

-(id)initAbout;

@end
