//
//  HBTitleView.m
//  LoopBrowsDemo
//
//  Created by Mac on 2017/2/16.
//  Copyright © 2017年 TUTK. All rights reserved.
//

#import "HBTitleView.h"

const CGFloat kpadding = 2.0f;
const CGFloat HBShowOutstandingFontMaxSize = 16.0f;
const CGFloat HBShowOutstandingFontMinSize = 14.0f;

@interface HBTitleView()
{
    CGRect _frame; // 视图frame
    NSArray *_titles;   // 标题数组
}


/**
 !!!!:UILabel换成UIImageView, 否则大屏幕手机会有黑线
 */
@property (nonatomic, strong) UIImageView *indexLabel; //下标label

@end

@implementation HBTitleView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles showStyle:(HBTITLESTYLE)style
{
    _style = style;
    
    return [self initWithFrame:frame andTitles:titles];
}

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles
{
    if(self = [super initWithFrame:frame])
    {
        _frame = frame;
        _titles = titles;
        
        _normalColor = [UIColor grayColor];
        _selectColor = [UIColor blueColor];
        _indexLineColor = [UIColor blueColor];
        _titleViewColor = [UIColor whiteColor];
        
        _isNeedSeparateLine = NO;
        _isNeedBottomLine = NO;
        _isNeedBorderLine = NO;
        _isShowOutstanding = NO;
        
        // 默认宽度比例
        _indexLineScale =  (frame.size.width - frame.size.height)/frame.size.width;
        
        [self layout];
    }
    return self;
}

#pragma mark - Layout

- (void)layout
{
    [self setBackgroundColor:_titleViewColor];

    NSInteger btnCount = [_titles count];
    CGFloat btnWidth = (btnCount > 1)? ((_frame.size.width - (btnCount - 1) * kpadding)/ btnCount) : _frame.size.width;
    
    CGRect assagnBtnRect = CGRectZero;
    for (NSInteger index = 0; index < btnCount; index ++)
    {
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if(btnCount > 1)
        {
            titleBtn.frame = CGRectMake((btnWidth + kpadding) * index, 2 * kpadding, btnWidth, _frame.size.height - 4 * kpadding);
        }
        else
        {
            titleBtn.frame = CGRectMake(btnWidth* index, 2 * kpadding, btnWidth, _frame.size.height - 4 * kpadding);
        }
        titleBtn.tag = 100 + index;
        titleBtn.selected = NO;
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:HBShowOutstandingFontMinSize];
        [titleBtn setTitle:[_titles objectAtIndex:index] forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.normalColor forState:UIControlStateNormal];
        if(_style == HBTITLESTYLE_Color||_style == HBTITLESTYLE_All)
        {
            [titleBtn setTitleColor:self.selectColor forState:UIControlStateSelected];
        }
        [titleBtn addTarget:self action:@selector(tapTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:titleBtn];
        
        // 设置下划线初始位置
        assagnBtnRect = (index == 0)? titleBtn.frame : assagnBtnRect;
    }
    
    if(_style == HBTITLESTYLE_Line || _style == HBTITLESTYLE_All)
    {
        if(btnCount > 1)
        {
            // 下划线 // 仅有一个标题不需要下划线
            CGRect indexLabelFrame = assagnBtnRect;
            indexLabelFrame.origin.y   += (assagnBtnRect.size.height + kpadding / 2);
            indexLabelFrame.origin.x   += assagnBtnRect.size.width *(1- _indexLineScale) /2;
            indexLabelFrame.size.width  = assagnBtnRect.size.width *_indexLineScale;
            indexLabelFrame.size.height = 1.5f ;
            
            _indexLabel = [[UIImageView alloc]initWithFrame:indexLabelFrame];
            _indexLabel.backgroundColor = self.indexLineColor;
            [self addSubview:_indexLabel];
        }
    }
}

#pragma mark - Setter/Getter

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    
    for (UIView *view in self.subviews)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)view;
            [btn setTitleColor:_normalColor forState:UIControlStateNormal];
        }
    }
}

- (void)setSelectColor:(UIColor *)selectColor
{
    _selectColor = selectColor;
    
    for (UIView *view in self.subviews)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)view;
            [btn setTitleColor:_selectColor forState:UIControlStateSelected];
        }
    }
}

- (void)setTitleViewColor:(UIColor *)titleViewColor
{
    _titleViewColor = titleViewColor;
    
    self.backgroundColor = _titleViewColor;
}

- (void)setIndexLineColor:(UIColor *)indexLineColor
{
    _indexLineColor = indexLineColor;
    _indexLabel.backgroundColor = _indexLineColor;
}

- (void)setIndexLineScale:(CGFloat)indexLineScale
{
    //NSAssert(indexLineScale < 0 || indexLineScale > 1, @"下划线宽度比例取值错误! :%f",indexLineScale);

    _indexLineScale = indexLineScale;
    
    if([_titles count] > 1)
    {
        CGRect indexLabelFrame = _indexLabel.frame;
        CGFloat btnWidth = (_frame.size.width - ([_titles count] - 1) * kpadding)/ [_titles count];
        indexLabelFrame.origin.x = btnWidth *(1- _indexLineScale)/2;
        indexLabelFrame.size.width = btnWidth *_indexLineScale;
        
        _indexLabel.frame = indexLabelFrame;
    }
}

- (void)setIsNeedSeparateLine:(BOOL)isNeedSeparateLine
{
    _isNeedSeparateLine = isNeedSeparateLine;
    
    if(_isNeedSeparateLine)
    {
        for (UIView *view in self.subviews)
        {
            if([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)view;
                NSUInteger index = btn.tag - 100;
                
                if (index != ([_titles count] - 1))
                {
                    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(btn.frame.origin.x + btn.frame.size.width, _frame.size.height / 4, kpadding/2, _frame.size.height / 2)];
                    lineView.backgroundColor = [UIColor lightGrayColor];
                    [self addSubview:lineView];
                }
            }
        }
    }
}

- (void)setIsNeedBottomLine:(BOOL)isNeedBottomLine
{
    _isNeedBottomLine = isNeedBottomLine;
    
    if(_isNeedBottomLine)
    {
        UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _frame.size.height - 1, _frame.size.width, 1)];
        bottomLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:bottomLabel];
    }    
}

-  (void)setIsNeedBorderLine:(BOOL)isNeedBorderLine
{
    _isNeedBorderLine = isNeedBorderLine;
    
    if(_isNeedBorderLine)
    {
        self.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
        self.layer.borderWidth = 1.0f;
    }
}

#pragma mark - Call backs

- (void)tapTitleBtn:(UIButton *)sender
{
    //NSLog(@"titleView:------%@",sender.titleLabel.text);

    __weak typeof(self)weakSelf = self;
    if (_style == HBTITLESTYLE_Color) {
        
        for (UIView *view in self.subviews)
        {
            if([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)view;
                btn.selected = NO;
            }
        }
        sender.selected = YES;
        if(_isShowOutstanding) sender.titleLabel.font = [UIFont systemFontOfSize:HBShowOutstandingFontMaxSize];
    }
    else if (_style == HBTITLESTYLE_Line)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = weakSelf.indexLabel.frame;
            rect.origin.x = sender.frame.origin.x + sender.frame.size.width *(1 - weakSelf.indexLineScale)/2;
            weakSelf.indexLabel.frame = rect;
        }];
    }
    else
    {
        // color
        for (UIView *view in self.subviews)
        {
            if([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)view;
                btn.selected = NO;
                btn.titleLabel.font = [UIFont systemFontOfSize:HBShowOutstandingFontMinSize];
            }
        }
        sender.selected = YES;
        if(_isShowOutstanding) sender.titleLabel.font = [UIFont systemFontOfSize:HBShowOutstandingFontMaxSize];

        // line
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = weakSelf.indexLabel.frame;
            rect.origin.x = sender.frame.origin.x + sender.frame.size.width *(1 - weakSelf.indexLineScale)/2;
            weakSelf.indexLabel.frame = rect;
        }];
    }
    
    if(_hb_titleBtnBlock) _hb_titleBtnBlock(sender.tag ,sender.titleLabel.text);
}

- (void)updataIndexLabelUIWithNum:(NSInteger)num
{
    __weak typeof(self)weakSelf = self;

    if(num < 0 || num > _titles.count - 1) return;
   
    UIButton *tmpBtn = [self viewWithTag:100 + num];
    
    if (_style == HBTITLESTYLE_Color) {
        
        for (UIView *view in self.subviews)
        {
            if([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)view;
                btn.selected = NO;
            }
        }
        tmpBtn.selected = YES;
        if(_isShowOutstanding) tmpBtn.titleLabel.font = [UIFont systemFontOfSize:HBShowOutstandingFontMaxSize];
    }
    else if (_style == HBTITLESTYLE_Line)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = weakSelf.indexLabel.frame;
            rect.origin.x = tmpBtn.frame.origin.x + tmpBtn.frame.size.width *(1 - weakSelf.indexLineScale)/2;
            weakSelf.indexLabel.frame = rect;
        }];
    }
    else
    {
        // color
        for (UIView *view in self.subviews)
        {
            if([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)view;
                btn.selected = NO;
                btn.titleLabel.font = [UIFont systemFontOfSize:HBShowOutstandingFontMinSize];
            }
        }
        tmpBtn.selected = YES;
        if(_isShowOutstanding) tmpBtn.titleLabel.font = [UIFont systemFontOfSize:HBShowOutstandingFontMaxSize];

        // line
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = weakSelf.indexLabel.frame;
            rect.origin.x = tmpBtn.frame.origin.x + tmpBtn.frame.size.width *(1 - weakSelf.indexLineScale)/2;
            weakSelf.indexLabel.frame = rect;
        }];
    }
}

@end
