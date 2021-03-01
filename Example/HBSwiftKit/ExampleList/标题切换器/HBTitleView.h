//
//  HBTitleView.h
//  LoopBrowsDemo
//
//  Created by Mac on 2017/2/16.
//  Copyright © 2017年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HBTITLESTYLE_Line = 0,  // 底部划线滑动
    HBTITLESTYLE_Color,     // 更换文字颜色
    HBTITLESTYLE_All        // 包含上述样式
} HBTITLESTYLE;

@interface HBTitleView : UIView

/** 实现被点击的按钮下标和内容回调 */
@property (nonatomic, copy) void (^ hb_titleBtnBlock) (NSInteger index, NSString *title);

/** 风格样式 默认 Line */
@property (nonatomic, assign) HBTITLESTYLE style;

/** 正常文字颜色 默认 gray */
@property (nonatomic, strong) UIColor *normalColor;

/** 选中文字颜色 默认 blue */
@property (nonatomic, strong) UIColor *selectColor;

/** 视图背景颜色 默认white */
@property (nonatomic, strong) UIColor *titleViewColor;

/** 下划线颜色 默认blue */
@property (nonatomic, strong) UIColor *indexLineColor;

/** 是否需要分割线 默认NO */
@property (nonatomic, assign) BOOL isNeedSeparateLine;

/** 是否底部划线 默认NO */
@property (nonatomic, assign) BOOL isNeedBottomLine;

/** 是否边框划线 默认NO */
@property (nonatomic, assign) BOOL isNeedBorderLine;

/** 是否突出显示 (fontsize大小改变) 默认NO */
@property (nonatomic, assign) BOOL isShowOutstanding;

/** 下划线长度比例 0 ~ 1,取1与文字按钮同宽 */
@property (nonatomic, assign) CGFloat indexLineScale;

/**
 重写init方法

 @param frame 设置位置
 @param titles 标题数组
 @return titleView对象
 */
- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles;

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles showStyle:(HBTITLESTYLE)style;


/**
 若要实现联合滚动,必须加上setter方法

 @param num 下标数
 */
- (void)updataIndexLabelUIWithNum:(NSInteger)num;

@end
