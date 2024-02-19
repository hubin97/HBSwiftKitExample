//
//  OpenCVWrapper.h
//  HBSwiftKit_Example
//
//  Created by design on 2021/11/6.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "opencv2/opencv2.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (Mat *)imageToMat: (UIImage *)image;

@end

NS_ASSUME_NONNULL_END
