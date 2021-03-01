//
//  HBScrollAdView.m
//  customizewidget
//
//  Created by 黄胡斌(EX-HUANGHUBIN001) on 2019/3/18.
//  Copyright © 2019年 平安产险. All rights reserved.
//

#import "HBScrollAdView.h"
#import "HBScrollAdModel.h"

/**
 走马灯itemcell
 左图 右文
 */
@interface HBScrollLabelCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *iconView; // *
@property (nonatomic, strong) UIImageView *flagView; // >

@property (nonatomic, strong) UILabel *titleLabel;

- (void)fillDatasWithModel:(HBScrollAdModel *)adModel;

@end

@implementation HBScrollLabelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat kpadding = 10.0f;
        
        // left icon
        CGRect iconFrame = frame;
        iconFrame.origin.x = kpadding;
        iconFrame.origin.y = kpadding;
        iconFrame.size.height -= 2 *kpadding;
        iconFrame.size.width = iconFrame.size.height;
        _iconView = [[UIImageView alloc]initWithFrame:iconFrame];

        // right icon
        CGRect flagFrame = frame;
        flagFrame.size.height = 20.0f;
        flagFrame.size.width = flagFrame.size.height;
        flagFrame.origin.x = frame.size.width - kpadding - flagFrame.size.width;
        flagFrame.origin.y = (frame.size.height - flagFrame.size.height)/2;
        _flagView = [[UIImageView alloc]initWithFrame:flagFrame];

        // right title
        CGRect titleFrame = frame;
        titleFrame.origin.x = kpadding*2 + iconFrame.size.height;
        titleFrame.origin.y = kpadding;
        titleFrame.size.width -= (titleFrame.origin.x + kpadding + flagFrame.size.width + kpadding);
        titleFrame.size.height -= kpadding *2;
        _titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        
        //notice_more_icon
        [self addSubview:_iconView];
        [self addSubview:_flagView];
        [self addSubview:_titleLabel];
        
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void)fillDatasWithModel:(HBScrollAdModel *)adModel {
    
    _iconView.image = adModel.iconName?[UIImage imageNamed:adModel.iconName]:[UIImage imageNamed:@"notice_icon"];
    _flagView.image = adModel.flagName?[UIImage imageNamed:adModel.flagName]:[UIImage imageNamed:@"notice_more_icon"];

    _titleLabel.text = adModel.title;
}

@end


NSString *const cellIdentifier = @"HBiTemCell";

@interface HBScrollAdView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionBoxLayout;
@property (nonatomic, strong) UICollectionView *collectionBox;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation HBScrollAdView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withfillDataSource:(NSArray <HBScrollAdModel *>*)items {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _items = items;
        
        [self initialization];
        [self setupMainView];
    }
    return self;
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    
    _collectionBox.delegate = nil;
    _collectionBox.dataSource = nil;
}

/** 初始化数据 */
- (void)initialization {
    
    _autoScrollTimeInterval = 2.0f;
    _autoScroll = YES;
    _infiniteLoop = YES;

}

/** 初始化布局 */
- (void)setupMainView {
    
    [self addSubview:self.collectionBox];

}

#pragma mark - actions

- (void)setupTimer {
    [self invalidateTimer]; // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer {
    
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll
{
    if (0 == [_items count]) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;

    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(int)targetIndex
{
    if (targetIndex >= [_items count]) {
        if (self.infiniteLoop) {
            targetIndex = 0;
            [_collectionBox scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [_collectionBox scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (int)currentIndex
{
    if (_collectionBox.frame.size.width == 0 || _collectionBox.frame.size.width == 0) {
        return 0;
    }
    
    int index = 0;
    if (_collectionBoxLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_collectionBox.contentOffset.x + _collectionBoxLayout.itemSize.width * 0.5) / _collectionBoxLayout.itemSize.width;
    } else {
        index = (_collectionBox.contentOffset.y + _collectionBoxLayout.itemSize.height * 0.5) / _collectionBoxLayout.itemSize.height;
    }
    
    return MAX(0, index);
}


#pragma mark - Setter getter
- (void)setShowStyle:(HBAdViewStyle)showStyle {
    
}

- (void)setAnimationType:(HBAnimationType)animationType {
    
    switch (animationType) {
        case HBAnimationType_LeftRight:
        {
            self.collectionBoxLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
             break;
        case HBAnimationType_UpDown:
        {
            self.collectionBoxLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
            break;
        default:
            break;
    }
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    
    [self invalidateTimer];
    
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setItems:(NSArray<HBScrollAdModel *> *)items {
    _items = items;
}

- (void)setAutoScrollTimeInterval:(NSTimeInterval)autoScrollTimeInterval {
    _autoScrollTimeInterval = autoScrollTimeInterval;
}

- (void)setInfiniteLoop:(BOOL)infiniteLoop {
    _infiniteLoop = infiniteLoop;
}

#pragma mark - Lazy loading
- (UICollectionViewFlowLayout *)collectionBoxLayout {
    
    if (_collectionBoxLayout == nil) {
        
        _collectionBoxLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionBoxLayout.minimumLineSpacing = 0.0f;
        _collectionBoxLayout.minimumInteritemSpacing = 0.0f;
        _collectionBoxLayout.itemSize = self.bounds.size;
        _collectionBoxLayout.sectionInset = UIEdgeInsetsZero;
        _collectionBoxLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionBoxLayout;
}

- (UICollectionView *)collectionBox {
 
    if (_collectionBox == nil) {
        
        _collectionBox = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.collectionBoxLayout];
        _collectionBox.backgroundColor = [UIColor clearColor];
        _collectionBox.delegate = self;
        _collectionBox.dataSource = self;
        _collectionBox.showsVerticalScrollIndicator = NO;
        _collectionBox.showsHorizontalScrollIndicator = NO;
        _collectionBox.pagingEnabled = YES;
        _collectionBox.scrollsToTop = NO;

        [_collectionBox registerClass:[HBScrollLabelCell class] forCellWithReuseIdentifier:cellIdentifier];
    }
    return _collectionBox;
}

#pragma mark - collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [_items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HBScrollAdModel *model = _items[indexPath.item];
    
    HBScrollLabelCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    [itemCell fillDatasWithModel:model];
    
    return itemCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HBScrollAdModel *model = _items[indexPath.item];
    //NSLog(@"model.title:%@, model.iconName:%@",model.title, model.iconName);

    if (_callBackSelectItemModelBlock) {
        _callBackSelectItemModelBlock(model);
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.items.count) return; // 解决清除timer时偶尔会出现的问题
    //int itemIndex = [self currentIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //[self scrollViewDidEndScrollingAnimation:self.collectionBox];
}

@end
