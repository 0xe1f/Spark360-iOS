//
//  Globals.m
//  BachZero
//
//  Created by Akop Karapetyan on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Globals.h"

BOOL DeviceIsPad(void)
{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
	{
        return([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);	
	}
    
    return(NO);
}