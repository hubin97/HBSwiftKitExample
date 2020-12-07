//
//  HBScrollAdModel.h
//  customizewidget
//
//  Created by 黄胡斌(EX-HUANGHUBIN001) on 2019/3/18.
//  Copyright © 2019年 平安产险. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBScrollAdModel : NSObject

/** 左图 flag url or filename*/
@property (nonatomic, copy) NSString *iconName;

/** 右图 flag url or filename*/
@property (nonatomic, copy) NSString *flagName;

/** 右文 标题 */
@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
