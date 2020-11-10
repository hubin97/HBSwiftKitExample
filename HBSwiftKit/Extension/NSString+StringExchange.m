//
//  NSString+StringExchange.m
//  test
//
//  Created by design on 2020/6/4.
//  Copyright © 2020 design. All rights reserved.
//

#import "NSString+StringExchange.h"

@implementation NSString (StringExchange)

- (NSString *)qjToBj {

    //NSString * string = @"ａｂｃｄｅｆｇ，";
    NSMutableString *convertedString = [self mutableCopy];
    CFStringTransform((CFMutableStringRef)convertedString, NULL, kCFStringTransformFullwidthHalfwidth, false);
    //NSLog(@"ddc:%@",convertedString);
    return convertedString;
}

- (NSString *)bjToQj {

    //NSString * string = @"abcdefg,";
    NSMutableString *convertedString = [self mutableCopy];
    CFStringTransform((CFMutableStringRef)convertedString, NULL, kCFStringTransformFullwidthHalfwidth, true);
    //NSLog(@"ddc:%@",convertedString);
    return convertedString;
}


@end
