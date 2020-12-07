//
//  HBScrollAdView.h
//  customizewidget
//
//  Created by 黄胡斌(EX-HUANGHUBIN001) on 2019/3/18.
//  Copyright © 2019年 平安产险. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HBScrollAdModel;

NS_ASSUME_NONNULL_BEGIN

/** 视图展示样式 */
typedef NS_ENUM(NSUInteger, HBAdViewStyle) {
    HBAdViewStyle_ScrollLabel = 0, // 走马灯
    HBAdViewStyle_ScrollBanner // 轮播图
};

/** 视图动画方式 */
typedef NS_ENUM(NSUInteger, HBAnimationType) {
    HBAnimationType_LeftRight = 0, // 左右
    HBAnimationType_UpDown // 上下
};


@interface HBScrollAdView : UIView

/** 展示样式 */
@property (nonatomic, assign) HBAdViewStyle showStyle;

/** 动画方式 */
@property (nonatomic, assign) HBAnimationType animationType;

/** 数据源 */
@property (nonatomic, strong) NSArray <HBScrollAdModel *>* items;

/** 自动动画间隔 默认2s*/
@property (nonatomic, assign) NSTimeInterval autoScrollTimeInterval;

/** 循环 默认YES*/
@property (nonatomic, assign) BOOL infiniteLoop;

/** 自动循环 默认YES*/
@property (nonatomic, assign) BOOL autoScroll;

/** 点击item回调*/
@property (nonatomic, copy) void (^callBackSelectItemModelBlock)(HBScrollAdModel *model);

/**
 初始方法

 @param frame frame
 @param items 数据源
 @return adview对象
 */
- (instancetype)initWithFrame:(CGRect)frame withfillDataSource:(NSArray <HBScrollAdModel *>*)items;

@end

NS_ASSUME_NONNULL_END
