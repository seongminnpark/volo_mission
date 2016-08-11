
//
//  VLOLocalStorage+migration.m
//  Volo
//
//  Created by bamsae on 2015. 3. 2..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

#import "VLOLocalStorage.h"
#import "VLOLog.h"
#import "VLOPlace.h"
#import "VLORouteLog.h"
#import "VLORouteNode.h"
#import "VLOTimezone.h"

@implementation VLOLocalStorage (migration)

+ (NSInteger)dbCurrentVersion
{
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    if (![db open]) {return -1;}
    
    NSInteger result = -1;
    if (![db tableExists:@"poi"]) {
        result = VLO_DATABASE_VERSION;
    } else if (![db columnExists:@"route_type" inTableWithName:@"timeline"]) {
        result = 1;
    } else if (![db columnExists:@"route_trans" inTableWithName:@"timeline"]) {
        result = 2;
    } else if (![db columnExists:@"route_nodes" inTableWithName:@"timeline"]) {
        result = 3;
    } else if (![db columnExists:@"is_synced" inTableWithName:@"timeline"]) {
        result = 4;
    } else if (![db tableExists:@"user"]) {
        result = 5;
    } else if (![db columnExists:@"created_at" inTableWithName:@"timeline"]) {
        result = 6;
    } else if (![db columnExists:@"has_date" inTableWithName:@"travel"]) {
        result = 7;
    } else if (![db columnExists:@"photo_user_id" inTableWithName:@"photo"]) {
        result = 8;
    } else if (![db columnExists:@"sticker_url" inTableWithName:@"timeline"]) {
        result = 9;
    } else if (![db columnExists:@"is_walkthrough" inTableWithName:@"travel"]) {
        result = 10;
    } else if (![db columnExists:@"map_zoom" inTableWithName:@"timeline"]) {
        result = 11;
    } else if (![db columnExists:@"tags" inTableWithName:@"travel"] || ![db columnExists:@"like_count" inTableWithName:@"travel"]) {
        result = 12;
    } else if (![db columnExists:@"ancestor_id" inTableWithName:@"timeline"]) {
        result = 13;
    } else if (![db columnExists:@"like_count" inTableWithName:@"timeline"] || ![db columnExists:@"like_users" inTableWithName:@"timeline"]) {
        result = 14;
    } else if (![db columnExists:@"is_from_watch" inTableWithName:@"timeline"]) {
        result = 15;
    } else if (![db columnExists:@"map_caption" inTableWithName:@"timeline"]) {
        result = 16;
    } else if (![db columnExists:@"is_updated" inTableWithName:@"timeline"]) {
        result = 17;
    } else if (![db columnExists:@"photo_status" inTableWithName:@"photo"]) {
        result = 18;
    } else if (![db columnExists:@"privacy_type" inTableWithName:@"travel"] || ![db columnExists:@"privacy_set_user_id" inTableWithName:@"travel"]) {
        result = 19;
    } else if (![db tableExists:@"travel"]) {
        result = 20;
    } else {
        result = VLO_DATABASE_VERSION;
    }
    [db close];

    return result;
}

+ (BOOL)migrateFromV1ToV2WithVersion:(NSInteger)version
{
    if (version > 1) {
        return YES;
    }
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    BOOL result = NO;
    
    NSString *sql = @"ALTER TABLE timeline ADD COLUMN route_type INTEGER";
    result = [db executeUpdate:sql];
    [db close];
    
    if (![db open]) {
        return NO;
    }
    [db beginTransaction];
    
    FMResultSet *boardCells = [db executeQuery:@"SELECT timeline_id, board_f_poi, board_t_poi FROM timeline WHERE type = ?", @(VLOLogTypeRoute)];
    while (boardCells.next) {
        NSString *timelineId = [boardCells stringForColumn:@"timeline_id"];
        NSInteger type; // 0 departure 1 trans 2 arrive
        VLOPlace *poi = nil;
        VLOPlace *toPlace = [[VLOPlace alloc] initWithJSONString:[boardCells stringForColumn:@"board_t_poi"]];
        VLOPlace *fromPlace = [[VLOPlace alloc] initWithJSONString:[boardCells stringForColumn:@"board_f_poi"]];
        
        if (toPlace.country) {
            poi = toPlace;
            type = 2;
        }
        else if (fromPlace.country) {
            poi = fromPlace;
            type = 0;
        }
        else {
            poi = [[VLOPlace alloc] init];
            type = 0;
        }
        
        result = [db executeUpdate:@"UPDATE timeline SET poi = ?, route_type = ? WHERE timeline_id = ?", [poi JSONString], @(type), timelineId];
        if (!result) {
            break;
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

+ (BOOL)migrateFromV2ToV3WithVersion:(NSInteger)version
{
    if (version > 2) {
        return YES;
    }
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    
    NSString *sql = @"ALTER TABLE timeline ADD COLUMN route_trans TEXT";
    [db executeUpdate:sql];
    sql = @"ALTER TABLE timeline ADD COLUMN sticker_name TEXT";
    [db executeUpdate:sql];
    
    [db close];
    
    if (![db open]) {
        return NO;
    }
    [db beginTransaction];
    
    BOOL result = NO;
    
    FMResultSet *boardCells = [db executeQuery:@"SELECT timeline_id, board_trans FROM timeline WHERE type = ?", @(VLOLogTypeRoute)];
    while (boardCells.next) {
        NSString *timelineId = [boardCells stringForColumn:@"timeline_id"];
        NSInteger boardTrans = [boardCells intForColumn:@"board_trans"];
        NSString *routeTrans;

        switch (boardTrans) {
            case 0:
                routeTrans = @"car";
                break;
            case 1:
                routeTrans = @"taxi";
                break;
            case 2:
                routeTrans = @"train";
                break;
            case 3:
                routeTrans = @"sub";
                break;
            case 4:
                routeTrans = @"bus";
                break;
            case 5:
                routeTrans = @"tram";
                break;
            case 6:
                routeTrans = @"plane";
                break;
            case 7:
                routeTrans = @"ship";
                break;
            case 8:
                routeTrans = @"walk";
                break;
            case 9:
                routeTrans = @"cycle";
                break;
            case 10:
                routeTrans = @"motocycle";
                break;
            default:
                routeTrans = @"unknown";
                break;
        }
        
        result = [db executeUpdate:@"UPDATE timeline SET route_trans = ? WHERE timeline_id = ?", routeTrans, timelineId];
        if (!result) {
            break;
        }
    }
    if (result) {
        FMResultSet *textCells = [db executeQuery:@"SELECT timeline_id, sticker FROM timeline WHERE type = ? AND sticker != ?", @(VLOLogTypeText), @(-1)];
        while (textCells.next) {
            NSString *timelineId = [textCells stringForColumn:@"timeline_id"];
            NSInteger sticker = [textCells intForColumn:@"sticker"];
            NSString *stickerName;
            
            switch (sticker) {
                case 0:
                    stickerName = @"gy_baggage";
                    break;
                case 1:
                    stickerName = @"gy_airport";
                    break;
                case 2:
                    stickerName = @"gy_busstop";
                    break;
                case 3:
                    stickerName = @"gy_trainstation";
                    break;
                case 4:
                    stickerName = @"gy_nature";
                    break;
                case 5:
                    stickerName = @"gy_night";
                    break;
                case 6:
                    stickerName = @"gy_rain";
                    break;
                case 7:
                    stickerName = @"gy_hot";
                    break;
                case 8:
                    stickerName = @"gy_cold";
                    break;
                case 9:
                    stickerName = @"gy_move";
                    break;
                case 10:
                    stickerName = @"gy_drive";
                    break;
                case 11:
                    stickerName = @"gy_photo";
                    break;
                case 12:
                    stickerName = @"gy_foodchopstick";
                    break;
                case 13:
                    stickerName = @"gy_foodfork";
                    break;
                case 14:
                    stickerName = @"gy_coffee";
                    break;
                case 15:
                    stickerName = @"gy_hotel";
                    break;
                case 16:
                    stickerName = @"gy_house";
                    break;
                case 17:
                    stickerName = @"gy_camping";
                    break;
                case 18:
                    stickerName = @"gy_shopping";
                    break;
                case 19:
                    stickerName = @"gy_present";
                    break;
                case 20:
                    stickerName = @"gy_dance";
                    break;
                case 21:
                    stickerName = @"gy_dinner";
                    break;
                case 22:
                    stickerName = @"gy_bar";
                    break;
                case 23:
                    stickerName = @"gy_cellphone";
                    break;
                case 24:
                    stickerName = @"gy_twisted";
                    break;
                case 25:
                    stickerName = @"gy_backhome";
                    break;
                default:
                    stickerName = @"";
                    break;
            }
            
            result = [db executeUpdate:@"UPDATE timeline SET sticker_name = ? WHERE timeline_id = ?", stickerName, timelineId];
            if (!result) {
                break;
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


+ (BOOL)migrateFromV3ToV4WithVersion:(NSInteger)version
{
    if (version > 3) {
        return YES;
    }
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    BOOL result = NO;
    
    NSString *sql = @"ALTER TABLE timeline ADD COLUMN route_nodes TEXT";
    result = [db executeUpdate:sql];
    [db close];
    
    if (![db open]) {
        return NO;
    }
    [db beginTransaction];
    
    FMResultSet *routeCells = [db executeQuery:@"SELECT timeline_id, route_type, poi, date, has_time, display_time, timezone FROM timeline WHERE type = ?", @(VLOLogTypeRoute)];
    while (routeCells.next) {
        NSString *timelineId = [routeCells stringForColumn:@"timeline_id"];
        VLORouteLogType routeType = [routeCells intForColumn:@"route_type"];
        
        VLORouteNode *routeNode = [[VLORouteNode alloc] init];
        routeNode.place = [[VLOPlace alloc] initWithJSONString:[routeCells stringForColumn:@"poi"]];
        routeNode.date = [routeCells dateForColumn:@"date"];
        routeNode.displayTime = [routeCells dateForColumn:@"display_time"];
        routeNode.timezone = [[VLOTimezone alloc] initWithJSONString:[routeCells stringForColumn:@"timezone"]];
        routeNode.hasTime = @([routeCells boolForColumn:@"has_time"]);

        VLORouteNode *imsiRouteNode = [[VLORouteNode alloc] init];
        VLOPlace *imsiPlace = routeNode.place.copy;
        imsiPlace.name = @"SOMEWHERE";
        imsiRouteNode.place = imsiPlace;
        imsiRouteNode.date = routeNode.date;
        imsiRouteNode.displayTime = routeNode.displayTime;
        imsiRouteNode.timezone = routeNode.timezone;
        imsiRouteNode.hasTime = routeNode.hasTime;
        
        if (routeType == VLORouteLogTypeArrival) {
            routeNode.order = @(1);
            imsiRouteNode.order = @(0);
            result = [db executeUpdate:@"UPDATE timeline SET route_nodes = ? WHERE timeline_id = ?", [NSString stringWithFormat:@"[%@, %@]", [imsiRouteNode JSONString], [routeNode JSONString]], timelineId];
        }
        else {
            routeNode.order = @(0);
            imsiRouteNode.order = @(1);
            result = [db executeUpdate:@"UPDATE timeline SET route_nodes = ? WHERE timeline_id = ?", [NSString stringWithFormat:@"[%@, %@]", [routeNode JSONString], [imsiRouteNode JSONString]], timelineId];
        }
        if (!result) {
            break;
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

+ (BOOL)migrateFromV4ToV5WithVersion:(NSInteger)version
{
    if (version > 4) {
        return YES;
    }
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    BOOL result = NO;
    
    NSString *sql = @"ALTER TABLE timeline ADD COLUMN is_synced BOOL DEFAULT 0";
    result = [db executeUpdate:sql];
    sql = @"ALTER TABLE timeline ADD COLUMN is_deleted BOOL DEFAULT 0";
    result = [db executeUpdate:sql];
    
    [db close];
    
    if (![db open]) {
        return NO;
    }
    [db beginTransaction];
    
    result = [db executeUpdate:@"UPDATE timeline SET is_synced = 1 WHERE timeline_id = synced_id"];
    FMResultSet *cells = [db executeQuery:@"SELECT synced_id, travel_id FROM timeline WHERE timeline_id != synced_id"];
    while ([cells next]) {
        result = [db executeUpdate:@"INSERT into sync_delete (travel_id, timeline_id) VALUES (?, ?)", [cells stringForColumn:@"travel_id"], [cells stringForColumn:@"synced_id"]];
    }
    
    [db commit];
    [db close];
    
    return result;
}

+ (BOOL)migrateFromV5ToV6WithVersion:(NSInteger)version
{
    if (version > 5) {
        return YES;
    }
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    BOOL result = NO;
    
    NSString *sql = @"ALTER TABLE timeline ADD COLUMN user_id TEXT";
    result = [db executeUpdate:sql];
    [db close];
    
    if (![db open]) {
        return NO;
    }
    [db beginTransaction];
    
    FMResultSet *travels = [db executeQuery:@"SELECT user_id, travel_id FROM travel"];
    while ([travels next]) {
        result = [db executeUpdate:@"UPDATE timeline SET user_id = ? WHERE travel_id = ?", [travels stringForColumn:@"user_id"], [travels stringForColumn:@"travel_id"]];
    }
    [VLOLocalStorage setUser:[VLOLocalStorage getCurrentUserWithDB:db] withDB:db];
    
    [db commit];
    [db close];
    
    return result;
}

+ (BOOL)migrateFromV6ToV7WithVersion:(NSInteger)version
{
    if (version > 6) {
        return YES;
    }
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    BOOL result = NO;
    
    result = [db executeUpdate:@"ALTER TABLE auth ADD COLUMN created_at DATETIME DEFAULT CURRENT_DATETIME"];
    result = [db executeUpdate:@"ALTER TABLE user ADD COLUMN created_at DATETIME DEFAULT CURRENT_DATETIME"];
    result = [db executeUpdate:@"ALTER TABLE travel ADD COLUMN created_at DATETIME DEFAULT CURRENT_DATETIME"];
    result = [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN created_at DATETIME DEFAULT CURRENT_DATETIME"];
    result = [db executeUpdate:@"ALTER TABLE photo ADD COLUMN created_at DATETIME DEFAULT CURRENT_DATETIME"];
    [db close];
    
    return result;
}

+ (BOOL)migrateFromV7ToV8WithVersion:(NSInteger)version
{
    if (version > 7) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    BOOL result = NO;
    result = [db executeUpdate:@"ALTER TABLE travel ADD COLUMN has_date BOOL DEFAULT 1"];
    
    [db close];
    return result;
}

+ (BOOL)migrateFromV8ToV9WithVersion:(NSInteger)version
{
    if (version > 8) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
//    meta_is_cropped BOOL, meta_crop_x DOUBLE, meta_crop_y DOUBLE, meta_crop_width DOUBLE, meta_crop_height DOUBLE, user_id TEXT
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE photo ADD COLUMN meta_is_cropped BOOL DEFAULT 0"];
    [db executeUpdate:@"ALTER TABLE photo ADD COLUMN meta_crop_x DOUBLE"];
    [db executeUpdate:@"ALTER TABLE photo ADD COLUMN meta_crop_y DOUBLE"];
    [db executeUpdate:@"ALTER TABLE photo ADD COLUMN meta_crop_width DOUBLE"];
    [db executeUpdate:@"ALTER TABLE photo ADD COLUMN meta_crop_height DOUBLE"];
    [db executeUpdate:@"ALTER TABLE photo ADD COLUMN photo_user_id TEXT"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV9ToV10WithVersion:(NSInteger)version
{
    if (version > 9) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE sticker ADD COLUMN sticker_url TEXT"];
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN sticker_url TEXT"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV10ToV11WithVersion:(NSInteger)version
{
    if (version > 10) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE travel ADD COLUMN is_walkthrough BOOL"];
    [db executeUpdate:@"ALTER TABLE travel ADD COLUMN is_deleted BOOL"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV11ToV12WithVersion:(NSInteger)version
{
    if (version > 11) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN map_zoom DOUBLE DEFAULT 16"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV12ToV13WithVersion:(NSInteger)version
{
    if (version > 12) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE travel ADD COLUMN tags TEXT"];
    [db executeUpdate:@"ALTER TABLE travel ADD COLUMN like_count INTEGER"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV13ToV14WithVersion:(NSInteger)version
{
    if (version > 13) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN ancestor_id TEXT"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV14ToV15WithVersion:(NSInteger)version
{
    if (version > 14) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN like_count INTEGER"];
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN like_users TEXT"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV15ToV16WithVersion:(NSInteger)version
{
    if (version > 15) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN is_from_watch BOOL"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV16ToV17WithVersion:(NSInteger)version
{
    if (version > 16) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN map_caption TEXT"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV17ToV18WithVersion:(NSInteger)version
{
    if (version > 17) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE timeline ADD COLUMN is_updated BOOL default 0"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV18ToV19WithVersion:(NSInteger)version
{
    if (version > 18) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE photo ADD COLUMN photo_status INTEGER default 0"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV19ToV20WithVersion:(NSInteger)version
{
    if (version > 19) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    [db executeUpdate:@"ALTER TABLE travel ADD COLUMN privacy_type INTEGER"];
    [db executeUpdate:@"ALTER TABLE travel ADD COLUMN privacy_set_user_id TEXT"];
    
    [db close];
    return YES;
}

+ (BOOL)migrateFromV20ToV21WithVersion:(NSInteger)version
{
    if (version > 20) {
        return YES;
    }
    
    FMDatabase *db = [VLOLocalStorage database:VLO_DATABASE_NAME];
    
    if (![db open]) {
        return NO;
    }
    
    [db executeUpdate:@"ALTER TABLE poi ADD COLUMN poi_name TEXT"];
    [db executeUpdate:@"ALTER TABLE poi ADD COLUMN poi_longitude FLOAT"];
    [db executeUpdate:@"ALTER TABLE poi ADD COLUMN poi_longitude FLOAT"];
    [db executeUpdate:@"ALTER TABLE poi ADD COLUMN poi_imageName TEXT"];
    
    [db close];
    return YES;
}

@end
