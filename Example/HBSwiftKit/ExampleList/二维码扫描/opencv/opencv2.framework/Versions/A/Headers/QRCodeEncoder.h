//
// This file is auto-generated. Please don't modify it!
//
#pragma once

#ifdef __cplusplus
//#import "opencv.hpp"
#import "opencv2/objdetect.hpp"
#else
#define CV_EXPORTS
#endif

#import <Foundation/Foundation.h>


@class Mat;
@class QRCodeEncoderParams;


// C++: enum CorrectionLevel (cv.QRCodeEncoder.CorrectionLevel)
typedef NS_ENUM(int, CorrectionLevel) {
    CORRECT_LEVEL_L = 0,
    CORRECT_LEVEL_M = 1,
    CORRECT_LEVEL_Q = 2,
    CORRECT_LEVEL_H = 3
};


// C++: enum ECIEncodings (cv.QRCodeEncoder.ECIEncodings)
typedef NS_ENUM(int, ECIEncodings) {
    ECI_UTF8 = 26
};


// C++: enum EncodeMode (cv.QRCodeEncoder.EncodeMode)
typedef NS_ENUM(int, EncodeMode) {
    MODE_AUTO = -1,
    MODE_NUMERIC = 1,
    MODE_ALPHANUMERIC = 2,
    MODE_BYTE = 4,
    MODE_ECI = 7,
    MODE_KANJI = 8,
    MODE_STRUCTURED_APPEND = 3
};



NS_ASSUME_NONNULL_BEGIN

// C++: class QRCodeEncoder
/**
 * Groups the object candidate rectangles.
 *     rectList  Input/output vector of rectangles. Output vector includes retained and grouped rectangles. (The Python list is not modified in place.)
 *     weights Input/output vector of weights of rectangles. Output vector includes weights of retained and grouped rectangles. (The Python list is not modified in place.)
 *     groupThreshold Minimum possible number of rectangles minus 1. The threshold is used in a group of rectangles to retain it.
 *     eps Relative difference between sides of the rectangles to merge them into a group.
 *
 * Member of `Objdetect`
 */
CV_EXPORTS @interface QRCodeEncoder : NSObject


#ifdef __cplusplus
@property(readonly)cv::Ptr<cv::QRCodeEncoder> nativePtr;
#endif

#ifdef __cplusplus
- (instancetype)initWithNativePtr:(cv::Ptr<cv::QRCodeEncoder>)nativePtr;
+ (instancetype)fromNative:(cv::Ptr<cv::QRCodeEncoder>)nativePtr;
#endif


#pragma mark - Methods


//
// static Ptr_QRCodeEncoder cv::QRCodeEncoder::create(QRCodeEncoder_Params parameters = QRCodeEncoder::Params())
//
/**
 * Constructor
 * @param parameters QR code encoder parameters QRCodeEncoder::Params
 */
+ (QRCodeEncoder*)create:(QRCodeEncoderParams*)parameters NS_SWIFT_NAME(create(parameters:));

/**
 * Constructor
 */
+ (QRCodeEncoder*)create NS_SWIFT_NAME(create());


//
//  void cv::QRCodeEncoder::encode(String encoded_info, Mat& qrcode)
//
/**
 * Generates QR code from input string.
 * @param encoded_info Input string to encode.
 * @param qrcode Generated QR code.
 */
- (void)encode:(NSString*)encoded_info qrcode:(Mat*)qrcode NS_SWIFT_NAME(encode(encoded_info:qrcode:));


//
//  void cv::QRCodeEncoder::encodeStructuredAppend(String encoded_info, vector_Mat& qrcodes)
//
/**
 * Generates QR code from input string in Structured Append mode. The encoded message is splitting over a number of QR codes.
 * @param encoded_info Input string to encode.
 * @param qrcodes Vector of generated QR codes.
 */
- (void)encodeStructuredAppend:(NSString*)encoded_info qrcodes:(NSMutableArray<Mat*>*)qrcodes NS_SWIFT_NAME(encodeStructuredAppend(encoded_info:qrcodes:));



@end

NS_ASSUME_NONNULL_END


