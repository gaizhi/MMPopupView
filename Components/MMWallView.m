//
//  MMWallView.m
//  MMPopupView
//
//  Created by gaizhi on 2016/11/3.
//  Copyright © 2017年 gaizhi. All rights reserved.
//

#import "MMWallView.h"
#import "MMPopupCategory.h"
#import <Masonry/Masonry.h>

///////////////////////////////////////
// MARK - MMWallViewCollectionCell - //
///////////////////////////////////////

@interface MMWallViewCollectionCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIButton *imageView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

@end

@implementation MMWallViewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = NO;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];

        _textLabel = [[UILabel alloc] init];
        _textLabel.userInteractionEnabled = NO;
        _textLabel.textColor = [UIColor darkGrayColor];
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
    }
    return self;
}

#pragma mark - WallView item layout / appearance

- (void)setModel:(MMWallItemModel *)model
      withLayout:(MMWallViewLayout *)layout
      appearance:(MMWallViewAppearance *)appearance
{
    [_imageView setImage:model.image forState:UIControlStateNormal];
    _textLabel.text = model.title;

    // appearance
    self.backgroundColor = appearance.itemBackgroundColor;
    _imageView.layer.cornerRadius = appearance.imageViewCornerRadius;
    _imageView.imageView.contentMode = appearance.imageViewContentMode;
    [_imageView setBackgroundImage:[UIImage mm_imageWithColor:appearance.imageViewBackgroundColor] forState:UIControlStateNormal];
    [_imageView setBackgroundImage:[UIImage mm_imageWithColor:appearance.imageViewHighlightedColor] forState:UIControlStateHighlighted];
    _textLabel.backgroundColor = appearance.textLabelBackgroundColor;
    _textLabel.textColor = appearance.textLabelTextColor;
    _textLabel.font = appearance.textLabelFont;

    // layout
    _imageView.mm_size = CGSizeMake(layout.imageViewSideLength, layout.imageViewSideLength);
    _imageView.mm_centerX = layout.itemSize.width / 2;
    if (_textLabel.text.length > 0) {
        CGFloat h = layout.itemSize.height - layout.imageViewSideLength - layout.itemSubviewsSpacing;
        CGSize size = [_textLabel sizeThatFits:CGSizeMake(layout.itemSize.width, MAXFLOAT)];
        if (size.height > h) size.height = h;
        _textLabel.mm_size = CGSizeMake(layout.itemSize.width, size.height);
        _textLabel.mm_y = _imageView.mm_bottom + layout.itemSubviewsSpacing;
        _textLabel.mm_centerX = layout.itemSize.width / 2;
    }
}

@end

////////////////////////////
// MARK -MMWallViewCell - //
////////////////////////////

static NSString *MM_CellIdentifier = @"MM_wallViewCollectionCell";

typedef void(^MMPopupIndexPathHandler)(NSIndexPath *indexPath);

@interface MMWallViewCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MMWallViewLayout *wallLayout;
@property (nonatomic, strong) MMWallViewAppearance *wallAppearance;

@property (nonatomic, strong) NSArray<MMWallItemModel *> *models;

@property (nonatomic, assign) NSInteger rowIndex;

@property (nonatomic, copy) MMPopupIndexPathHandler handler;

@end

@implementation MMWallViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                       layout:(MMWallViewLayout *)layout
                   appearance:(MMWallViewAppearance *)appearance
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _wallLayout = layout;
        _wallAppearance = appearance;

        self.backgroundColor = appearance.sectionBackgroundColor;

        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = layout.itemPadding;
        flowLayout.itemSize = layout.itemSize;
        flowLayout.sectionInset = layout.itemEdgeInset;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];

        [_collectionView registerClass:[MMWallViewCollectionCell class]
            forCellWithReuseIdentifier:MM_CellIdentifier];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MMWallViewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MM_CellIdentifier forIndexPath:indexPath];
    if (indexPath.row < _models.count) {
        id object = [_models objectAtIndex:indexPath.row];
        NSAssert([object isKindOfClass:[MMWallItemModel class]], @"** MMWallView ** - 传入的数据必须使用MMWallItemModel进行打包，不能是其它对象!");
        [cell setModel:object withLayout:_wallLayout appearance:_wallAppearance];
    }
    cell.imageView.tag = indexPath.row;
    [cell.imageView addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)itemClicked:(UIButton *)sender
{
    if (self.handler) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:self.rowIndex];
        self.handler(indexPath);
    }
}

#pragma mark - setter

- (void)setModels:(NSArray<MMWallItemModel *> *)models
{
    _models = models;
    [_collectionView reloadData];
}

@end

// MARK - MMWallItemModel -

@implementation MMWallItemModel

+ (instancetype)modelWithImage:(UIImage *)image title:(NSString *)title
{
    MMWallItemModel *model = [[MMWallItemModel alloc] init];
    model.image = image;
    model.title = title;
    
    return model;
}

@end

////////////////////////
// MARK -MMWallView - //
////////////////////////

@interface MMWallView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MMPopupIndexPathHandler handler;

@end

@implementation MMWallView

@synthesize wallLayout=_wallLayout;
@synthesize wallAppearance=_wallAppearance;

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:240 / 255. green:240 / 255. blue:240 / 255. alpha:0xff / 255.];

        self.type = MMPopupTypeSheet;

        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        }];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];

        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.delaysContentTouches = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tableView];

        _wallHeaderLabel = [self labelWithTextColor:[UIColor darkGrayColor] font:[UIFont systemFontOfSize:12] action:@selector(headerClicked)];
        _tableView.tableHeaderView = _wallHeaderLabel;

        _wallFooterButton = [UIButton mm_buttonWithTarget:self action:@selector(footerClicked)];
        _wallFooterButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_wallFooterButton setBackgroundImage:[UIImage mm_imageWithColor:UIColor.whiteColor] forState:UIControlStateNormal];
        [_wallFooterButton setBackgroundImage:[UIImage mm_imageWithColor:UIColor.whiteColor] forState:UIControlStateHighlighted];
        [_wallFooterButton setTitle:@"取消" forState:UIControlStateNormal];
        [_wallFooterButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];

        _tableView.tableFooterView = _wallFooterButton;

        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self);
        }];

        [self autoAdjustFitHeight];
    }
    return self;
}

- (UILabel *)labelWithTextColor:(UIColor *)textColor font:(UIFont *)font action:(nullable SEL)action
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.text = @"MMWallView";
    label.textColor = textColor;
    label.font = font;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:action]];
    return label;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self wallSectionHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMWallViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MM_wallViewCell"];
    if (!cell) {
        cell = [[MMWallViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MM_wallViewCell" layout:self.wallLayout appearance:self.wallAppearance];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.rowIndex = indexPath.row;
    id object = [_models objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSArray class]]) {
        cell.models = (NSArray *)object;
    }
    cell.handler = self.handler;

    return cell;
}

#pragma mark - Gesture block

- (void)headerClicked
{
    if (self.didClickHeader) self.didClickHeader(self);
}

- (void)footerClicked
{
    [self hide];

    if (nil != self.didClickFooter) self.didClickFooter(self);
}

#pragma mark - Setter Getter
- (MMPopupIndexPathHandler)handler {
    if (!_handler) {
        MMWeakify(self);
        _handler = ^(NSIndexPath *indexPath) {
            MMStrongify(self);
            [self hide];
            
            if (self.models.count <= indexPath.section) {
                return;
            }
            NSArray *models = self.models[indexPath.section];
            if (models.count <= indexPath.row) {
                return;
            }
            MMWallItemModel *item = models[indexPath.row];
            if (item.handler) {
                item.handler(indexPath.row);
            }
        };
    }

    return _handler;
}
- (MMWallViewLayout *)wallLayout
{
    if (_wallLayout) {
        return _wallLayout;
    }
    return [[MMWallViewLayout alloc] init];
}

- (MMWallViewAppearance *)wallAppearance
{
    if (_wallAppearance) {
        return _wallAppearance;
    }
    return [[MMWallViewAppearance alloc] init];
}

- (void)setModels:(NSArray<NSArray<MMWallItemModel *> *> *)models
{
    _models = models;
    [_tableView reloadData];

    [self reloadTableViewHeaderAndFooterHeight];
    [self autoAdjustFitHeight];
}

- (void)setWallLayout:(MMWallViewLayout *)wallLayout {
    _wallLayout = wallLayout;

    [_tableView reloadData];
    [self reloadTableViewHeaderAndFooterHeight];
    [self autoAdjustFitHeight];
}

- (void)setWallAppearance:(MMWallViewAppearance *)wallAppearance {
    _wallAppearance = wallAppearance;

    [_tableView reloadData];
    [self reloadTableViewHeaderAndFooterHeight];
    [self autoAdjustFitHeight];
}

- (void)reloadTableViewHeaderAndFooterHeight
{
    _wallFooterButton.titleEdgeInsets  = self.wallLayout.wallFooterTitleInsets;
    _tableView.tableHeaderView.mm_size = CGSizeMake(self.mm_width, self.wallLayout.wallHeaderHeight);
    _tableView.tableFooterView.mm_size = CGSizeMake(self.mm_width, self.wallLayout.wallFooterHeight);
}

#pragma mark - Wall section height

- (CGFloat)wallSectionHeight
{
    return self.wallLayout.itemEdgeInset.top + self.wallLayout.itemEdgeInset.bottom + self.wallLayout.itemSize.height;
}

- (void)autoAdjustFitHeight
{
    CGFloat totalHeight = [self wallSectionHeight] * _models.count;
    if (!CGRectEqualToRect(CGRectZero, _wallHeaderLabel.frame)) {
        totalHeight += self.wallLayout.wallHeaderHeight;
    }
    if (!CGRectEqualToRect(CGRectZero, _wallFooterButton.frame)) {
        totalHeight += self.wallLayout.wallFooterHeight;
    }

    //totalHeight += MM_safeAreaHeight();

    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(totalHeight));
    }];
}

@end
