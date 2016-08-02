//
//  VLOCountry.h
//  Volo
//
//  Created by 1001246 on 2015. 1. 13..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLOCountry : NSObject 

@property (nonatomic, strong) NSString *isoCountryCode;
@property (nonatomic, strong) NSString *country;

- (instancetype)initWithCode:(NSString *)isoCountryCode country:(NSString *)country;
- (instancetype)initWithResponseDictionary:(NSDictionary *)dictionary;

+ (NSArray *)countriesWithResponseObject:(NSArray *)responseObject;

@end
