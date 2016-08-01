//
//  VLOCountry.m
//  Volo
//
//  Created by 1001246 on 2015. 1. 13..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

#import "VLOCountry.h"

@implementation VLOCountry

- (instancetype)initWithCode:(NSString *)isoCountryCode country:(NSString *)country
{
    self = [super init];
    if (self) {
        self.isoCountryCode = isoCountryCode;
        self.country = country;
    }
    return self;
}

- (instancetype)initWithResponseDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _isoCountryCode = [dictionary objectForKey:@"isoCountryCode"];
        _country = [dictionary objectForKey:@"country"];
    }
    return self;
}

+ (NSArray *)countriesWithResponseObject:(NSArray *)responseObject
{
    NSMutableArray *countryList = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *countryJSON in responseObject) {
        if (![countryJSON isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        VLOCountry *country = [[VLOCountry alloc] initWithResponseDictionary:countryJSON];
        [countryList addObject:country];
    }
    return countryList;
}

@end
