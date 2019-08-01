//
//  MMPopupWindow.m
//  MMPopupView
//
//  Created by Ralph Li on 9/6/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import "MMPopupWindow.h"
#import "MMPopupCategory.h"
#import "MMPopupDefine.h"
#import "MMPopupView.h"

@interface MMPopupWindow()

@end

@implementation MMPopupWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        self.windowLevel = UIWindowLevelAlert - 1;
    }
    return self;
}

+ (MMPopupWindow *)sharedWindow
{
    static MMPopupWindow *window;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        window = [[MMPopupWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = [UIViewController new];
    });
    
    return window;
}

- (void)cacheWindow
{
    [self makeKeyAndVisible];
    [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
    
    [self attachView].mm_dimBackgroundView.hidden = YES;
    self.hidden = YES;
}

- (UIView *)attachView
{
    return self.rootViewController.view;
}

@end
