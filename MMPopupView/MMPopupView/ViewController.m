//
//  ViewController.m
//  MMPopupView
//
//  Created by Ralph Li on 9/6/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "MMPopupItem.h"
#import "MMAlertView.h"
#import "MMSheetView.h"
#import "MMPinView.h"
#import "MMDateView.h"
#import "MMPopupWindow.h"
#import "MMWallView.h"

@interface ViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UIButton *btnAlert;
@property (nonatomic, strong) UIButton *btnConfirm;
@property (nonatomic, strong) UIButton *btnInput;
@property (nonatomic, strong) UIButton *btnSheet;
@property (nonatomic, strong) UIButton *btnPin;
@property (nonatomic, strong) UIButton *btnDate;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [UITableView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
//    [[MMPopupWindow sharedWindow] cacheWindow];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    
    MMAlertViewConfig *alertConfig = [MMAlertViewConfig globalConfig];
    MMSheetViewConfig *sheetConfig = [MMSheetViewConfig globalConfig];
    
    alertConfig.defaultTextOK = @"OK";
    alertConfig.defaultTextCancel = @"Cancel";
    alertConfig.defaultTextConfirm = @"Confirm";
    
    sheetConfig.defaultTextCancel = @"Cancel";
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = @[@"Alert - Default", @"Alert - Confirm", @"Alert - Input", @"Sheet - Default", @"Sheet - WallView", @"Custom - PinView", @"Custom - DateView"][indexPath.row];
    cell.textLabel.textColor = [UIColor redColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelect");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self action:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)action:(NSUInteger)index;
{
    MMPopupItemHandler block = ^(NSInteger index){
        NSLog(@"clickd %@ button",@(index));
    };
    
    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
        NSLog(@"animation complete");
    };
    
    switch ( index ) {
        case 0:
        {
            NSArray *items =
            @[MMItemMake(@"Done", MMItemTypeNormal, block),
              MMItemMake(@"Save", MMItemTypeHighlight, block),
              MMItemMake(@"Cancel", MMItemTypeNormal, block)];
            
            MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"AlertView"
                                         detail:@"each button take one row if there are more than 2 items"
                                          items:items];
//            alertView.attachedView = self.view;
            alertView.attachedView.mm_dimBackgroundBlurEnabled = YES;
            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
            
            [alertView show];
            
            break;
        }
        case 1:
        {
            MMAlertView *alertView = [[MMAlertView alloc] initWithConfirmTitle:@"AlertView" detail:@"Confirm Dialog"];
            alertView.attachedView = self.view;
            alertView.attachedView.mm_dimBackgroundBlurEnabled = YES;
            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleDark;
            [alertView showWithBlock:completeBlock];
            break;
        }
        case 2:
        {
            MMAlertView *alertView = [[MMAlertView alloc] initWithInputTitle:@"AlertView" detail:@"Input Dialog" placeholder:@"Your placeholder" handler:^(NSString *text) {
                NSLog(@"input:%@",text);
            }];
            alertView.attachedView = self.view;
            alertView.attachedView.mm_dimBackgroundBlurEnabled = YES;
            alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleExtraLight;
            [alertView showWithBlock:completeBlock];
            
            break;
        }
        case 3:
        {
            if (@available(iOS 11.0, *)) {
                MMSheetViewConfig.globalConfig.cancelButtonHeight = MMSheetViewConfig.globalConfig.buttonHeight + self.view.safeAreaInsets.bottom;
                MMSheetViewConfig.globalConfig.cancelButtonTitleInsets = UIEdgeInsetsMake(0, 0, MAX(0, self.view.safeAreaInsets.bottom), 0);
            } else {
                // Fallback on earlier versions
            }

            MMSheetViewConfig.globalConfig.innerMargin = 8;
            MMSheetViewConfig.globalConfig.splitColor = UIColor.groupTableViewBackgroundColor;
            
            NSArray *items =
            @[MMItemMake(@"Normal", MMItemTypeNormal, block),
              MMItemMake(@"Highlight", MMItemTypeHighlight, block),
              MMItemMake(@"Disabled", MMItemTypeDisabled, block)];

            NSString *title = @"这是一个模仿微信底部ActionSheet风格的ActionSheet, 如果你对MMSheetView有更好的建议或者发现Bug的话可以在Github上issue, Thx.";
            
            MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:title
                                                                  items:items];
            
            sheetView.attachedView = self.view;
            sheetView.attachedView.mm_dimBackgroundBlurEnabled = NO;
            [sheetView showWithBlock:completeBlock];
            break;
        }
        case 4:
        {
            MMWallView *wallView = [self wallView];
            wallView.didClickFooter = ^(MMWallView * _Nonnull sheetView) {

            };

            wallView.attachedView = self.view;
            wallView.attachedView.mm_dimBackgroundBlurEnabled = NO;
            [wallView showWithBlock:completeBlock];
            break;
        }
        case 5:
        {
            MMPinView *pinView = [MMPinView new];
            
            [pinView showWithBlock:completeBlock];
            
            break;
        }
        case 6:
        {
            MMDateView *dateView = [MMDateView new];
            
            [dateView showWithBlock:completeBlock];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MMDateView hideAll];
            });
            
            break;
        }
            
        default:
            break;
    }
}

- (MMWallView *)wallView {
    MMWallViewLayout *layout = [MMWallViewLayout new];
    layout.itemSubviewsSpacing = 9;
    if (@available(iOS 11.0, *)) {
        layout.wallFooterHeight = 50 + self.view.safeAreaInsets.bottom;
        layout.wallFooterTitleInsets = UIEdgeInsetsMake(0, 0, self.view.safeAreaInsets.bottom, 0);
    } else {
        // Fallback on earlier versions
    }

    MMWallViewAppearance *appearance = [MMWallViewAppearance new];
    appearance.textLabelFont = [UIFont systemFontOfSize:10];

    CGRect rect = CGRectMake(100, 100, [UIScreen mainScreen].bounds.size.width, 300);
    MMWallView *wallView = [[MMWallView alloc] initWithFrame:rect];
    wallView.wallHeaderLabel.text = @"此网页由 mp.weixin.qq.com 提供";
    [wallView.wallFooterButton setTitle:@"取消" forState:(UIControlStateNormal)];
    wallView.wallLayout = layout;
    wallView.wallAppearance = appearance;
    wallView.models = [self wallModels];
    return wallView;
}

#define titleKey @"title"
#define imgNameKey @"imageName"

- (NSArray *)wallModels {

    NSArray *arr1 = @[@{titleKey   : @"发送给朋友",
                        imgNameKey : @"sheet_Share"},

                      @{titleKey   : @"分享到朋友圈",
                        imgNameKey : @"sheet_Moments"},

                      @{titleKey   : @"收藏",
                        imgNameKey : @"sheet_Collection"},

                      @{titleKey   : @"分享到\n手机QQ",
                        imgNameKey : @"sheet_qq"},

                      @{titleKey   : @"分享到\nQQ空间",
                        imgNameKey : @"sheet_qzone"},

                      @{titleKey   : @"在QQ浏览器\n中打开",
                        imgNameKey : @"sheet_qqbrowser"}];

    NSArray *arr2 = @[@{titleKey   : @"查看公众号",
                        imgNameKey : @"sheet_Verified"},

                      @{titleKey   : @"复制链接",
                        imgNameKey : @"sheet_CopyLink"},

                      @{titleKey   : @"复制文本",
                        imgNameKey : @"sheet_CopyText"},

                      @{titleKey   : @"刷新",
                        imgNameKey : @"sheet_Refresh"},

                      @{titleKey   : @"调整字体",
                        imgNameKey : @"sheet_Font"},

                      @{titleKey   : @"投诉",
                        imgNameKey : @"sheet_Complaint"}];

    NSMutableArray *array1 = [NSMutableArray array];
    for (NSDictionary *dict in arr1) {
        NSString *text = [dict objectForKey:titleKey];
        NSString *imgName = [dict objectForKey:imgNameKey];
        MMWallItemModel *item = [MMWallItemModel modelWithImage:[UIImage imageNamed:imgName] title:text];
        item.handler = ^(NSInteger index) {
            NSLog(@"wallView click at first section row %ld", index);
        };
        [array1 addObject:item];
    }

    NSMutableArray *array2 = [NSMutableArray array];
    for (NSDictionary *dict in arr2) {
        NSString *text = [dict objectForKey:titleKey];
        NSString *imgName = [dict objectForKey:imgNameKey];
        MMWallItemModel *item = [MMWallItemModel modelWithImage:[UIImage imageNamed:imgName] title:text];
        item.handler = ^(NSInteger index) {
            NSLog(@"wallView click at secend section row %ld", index);
        };
        [array2 addObject:item];
    }

    return [NSMutableArray arrayWithObjects:array1, array2, nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
