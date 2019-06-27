//
//  MMWallView.h
//  MMPopupView
//
//  Created by gaiMMi on 2016/11/3.
//  Copyright © 2017年 gaiMMi. All rights reserved.
//

#import "MMPopupView.h"
#import "MMWallViewConfig.h"
#import "MMPopupItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMWallItemModel : MMPopupItem

+ (instancetype)modelWithImage:(UIImage *)image title:(NSString *)title;

@property (nonatomic, strong) UIImage *image;

@end

@interface MMWallView : MMPopupView

@property (nonatomic, strong, readonly) UILabel *wallFooterLabel;
@property (nonatomic, strong, readonly) UILabel *wallHeaderLabel;

@property (nonatomic, strong) NSArray<NSArray<MMWallItemModel *> *> *models;

@property (nonatomic, copy) void (^didClickHeader)(MMWallView *wallView);
@property (nonatomic, copy) void (^didClickFooter)(MMWallView *wallView);

@property (nonatomic, strong) MMWallViewLayout *wallLayout;
@property (nonatomic, strong) MMWallViewAppearance *wallAppearance;

@end

NS_ASSUME_NONNULL_END
