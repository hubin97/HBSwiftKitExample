//
//  NSString+StringExchange.h
//  test
//
//  Created by design on 2020/6/4.
//  Copyright © 2020 design. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (StringExchange)

///  全角转半角方法
- (NSString *)qjToBj;

///  半角转全角方法
- (NSString *)bjToQj;

@end

NS_ASSUME_NONNULL_END
