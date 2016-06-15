//
//  VLODevicemodel.m
//  VLOGetCoordinates
//
//  Created by M on 2016. 6. 15..
//  Copyright © 2016년 M. All rights reserved.
//


// 사용자 핸드폰의 기종을 가져오기 위한 클래스

#import <Foundation/Foundation.h>
#import "VLODevicemodel.h"
#import <sys/utsname.h>

@import UIKit;

@implementation VLODevicemodel

- (NSString *) Get_Device_model
{
    NSString *platform = [self deviceModel];
    
    if([platform isEqualToString:@"iPhone3,1"]||[platform isEqualToString:@"iPhone3,3"])
        return @"iPhone 4";
    if([platform isEqualToString:@"iPhone4,1"])
        return @"iPhone 4S";
    if([platform isEqualToString:@"iPhone5,1"]||[platform isEqualToString:@"iPhone5,2"])
        return @"iPhone 5";
    if([platform isEqualToString:@"iPhone5,3"]||[platform isEqualToString:@"iPhone5,4"])
        return @"iPhone 5c";
    if([platform isEqualToString:@"iPhone6,1"]||[platform isEqualToString:@"iPhone6,2"])
        return @"iPhone 5s";
    if([platform isEqualToString:@"iPhone7,2"])
        return @"iPhone 6";
    if([platform isEqualToString:@"iPhone7,1"])
        return @"iPhone 6 Plus";
    if([platform isEqualToString:@"iPhone8,1"])
        return @"iPhone 6S";
    if([platform isEqualToString:@"iPhone8,2"])
        return @"iPhone 6S Plus";
    if([platform isEqualToString:@"iPhone8,4"])
        return @"iPhone SE";
    if([platform isEqualToString:@"iPad1,1"])
        return @"iPad";
    if([platform isEqualToString:@"iPad2,1"]||[platform isEqualToString:@"iPad2,2"]||[platform isEqualToString:@"iPad2,3"])
        return @"iPad 2";
    if([platform isEqualToString:@"iPad2,5"]||[platform isEqualToString:@"iPad4,4"]||[platform isEqualToString:@"iPad4,5"]||[platform isEqualToString:@"iPad4,7"])
        return @"iPad Mini";
    
    
    NSLog(@"my device -> %@",[self deviceModel]);
    return platform;
}

- (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}
@end

