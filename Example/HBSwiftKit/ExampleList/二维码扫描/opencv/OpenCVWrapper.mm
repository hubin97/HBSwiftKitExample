//
//  OpenCVWrapper.m
//  HBSwiftKit_Example
//
//  Created by design on 2021/11/6.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "opencv2/imgcodecs/ios.h"
#import "opencv2/imgproc/types_c.h"
#import "opencv2/imgproc/imgproc_c.h"
#import "opencv2/core/types_c.h"

#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

+ (Mat *)imageToMat: (UIImage *)image {
    Mat *mat = [[Mat alloc] init];
    UIImageToMat(image, mat.nativeRef, true);
    return mat;
}

@end
