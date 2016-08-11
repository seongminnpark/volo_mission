//
//  VLOLocalStorage+poi.m
//  Volo
//
//  Created by Seongmin on 8/10/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOLocalStorage.h"
#import "VLOPoi.h"
#import "VLOLocationCoordinate.h"

@implementation VLOLocalStorage (poi)

+ (BOOL)createPoiTableIfNotExist {
    
    NSString *records = @"poi_name TEXT PRIMARY KEY, poi_latitude FLOAT, poi_longitude FLOAT, poi_imageName TEXT";
    BOOL result = [VLOLocalStorage createTableIfNotExistTableName:@"poi"
                                                  recordCSVString:records
                                                         database:VLO_DATABASE_NAME];
    
    return result;
}

+ (BOOL)initPoiList
{
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db beginTransaction];
    
    BOOL result = NO;
    
    if ([db intForQuery:@"SELECT count(*) FROM poi WHERE poi_name = ?", @1] < 1) {
        result = [db executeUpdate:@"INSERT INTO poi (poi_name, poi_latitude, poi_longitude, poi_imageName) VALUES (?, ?, ?, ?)",
                  @"osaka", @(34.6937), @(135.5022), @"icon_marker_osaka"];
        if (result) {
            result = [db executeUpdate:@"INSERT INTO poi (poi_name, poi_latitude, poi_longitude, poi_imageName) VALUES (?, ?, ?, ?)",
                      @"seoul", @(37.5665), @(126.9780), @"icon_marker_seoul"];
            
            if (result) {
                result = [db executeUpdate:@"INSERT INTO poi (poi_name, poi_latitude, poi_longitude, poi_imageName) VALUES (?, ?, ?, ?)",
                          @"newyork", @(40.7128), @(-74.0059), @"icon_marker_newyork"];
            }
        }
    }
    
    if (result) {
        [db commit];
    }
    else {
        [db rollback];
    }
    
    [db close];
    
    return result;
}

+ (NSArray *)getPoiList
{
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return nil;
    }
    
    NSArray *poiList = [self getPoiListWithDB:db];
    [db close];
    return poiList;
}

+ (NSArray *)getPoiListWithDB:(FMDatabase *)db
{
    FMResultSet *result = [db executeQuery:@"SELECT * FROM poi"];
    
    NSMutableArray *poiList = [[NSMutableArray alloc] initWithCapacity:0];
    while (result.next) {
        VLOPoi *poi = [[VLOPoi alloc] init];
        poi.name = [result stringForColumn:@"poi_name"];
        CGFloat latitude = [result doubleForColumn:@"poi_latitude"];
        CGFloat longitude = [result doubleForColumn:@"poi_longitude"];
        poi.coordinates = [[VLOLocationCoordinate alloc] initWithLatitude:latitude longitude:longitude];
        poi.imageName = [result stringForColumn:@"poi_imageName"];
    
        [poiList addObject:poi];
    }
    
    [db close];
    
    return poiList;
}



@end
