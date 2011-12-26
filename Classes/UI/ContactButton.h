#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface ContactButton : UIButton 

@property (nonatomic, retain) UIColor *highColor;
@property (nonatomic, retain) UIColor *lowColor;

@property (nonatomic, retain) CAGradientLayer *gradientLayer;

-(void)setButtonText:(NSString*)text;

@end
