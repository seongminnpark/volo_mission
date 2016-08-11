//
//  VLOLocalStorage.h
//  Volo
//
//  Created by bamsae on 2015. 1. 22..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

#define VLO_DATABASE_NAME       @"VOLODB"
#define VLO_DATABASE_VERSION    21
#define VLO_POSTSYNC_LIMIT      10
#define VLO_GETSYNC_LIMT        20

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import "MTLModel+VLOExtenstion.h"

@class FMDatabase;
@class VLOTravel;
@class VLOPhoto;
@class VLOLog;
@class VLOPhotoLog;
@class VLOUser;
@class VLOAuthToken;
@class VLOSync;
@class VLOInsertDiffFromLocal;
@class VLODeleteDiffFromLocal;
@class VLOStickerSet;
@class VLOSticker;

static NSString * const VLO_RECOMMEND_REVIEW_KEY_1 = @"recommendReviewKey1";
static NSString * const VLO_CELL_WRITE_COUNT_KEY = @"cellWirteCountKey";
static NSString * const VLO_APP_LAUNCHED_COUNT_KEY = @"appLaunchedCountKey";

@interface VLOLocalStorage : NSObject

+ (NSString *)pathToLocalStorage:(NSString *)database;

+ (FMDatabase *)database:(NSString *)database;

+ (NSUInteger)userVersion:(NSString *)database;

+ (void)setUserVersion:(NSUInteger)version database:(NSString *)database;

+ (BOOL)isTableExist:(NSString *)tableName database:(NSString *)database;

+ (BOOL)createTableIfNotExistTableName:(NSString *)tableName recordCSVString:(NSString *)records database:(NSString *)database;

+ (BOOL)removeDatabaseTable:(NSString *)tableName database:(NSString *)database;

+ (BOOL)canRecommendToReview;

@end


@interface VLOLocalStorage (travel)

+ (BOOL)createTravelTableIfNotExist;

+ (NSMutableArray *)loadTravels;

+ (VLOTravel *)loadTravelWithId:(NSString *)travelId;
+ (VLOTravel *)loadTravelWithServerId:(NSString *)serverId;

+ (BOOL)insertTravel:(VLOTravel *)travel;
+ (BOOL)insertTravels:(NSMutableArray *)travelList;

+ (BOOL)updateTravel:(VLOTravel *)travel;
+ (BOOL)updateTravel:(VLOTravel *)travel withDB:(FMDatabase *)db;
+ (BOOL)updateTravels:(NSMutableArray *)travelList;

+ (BOOL)removeTravel:(VLOTravel *)travel;

+ (NSArray *)nationListFromTravelId:(NSString *)travelId withDB:(FMDatabase *)db;
+ (NSInteger)lastDayOfTravel:(VLOTravel *)travel;

+ (NSArray *)travelTitleList;

+ (NSInteger)countOfTravelsWithUser:(VLOUser *)user;

@end


@interface VLOLocalStorage (photo)

+ (BOOL)createPhotoTableIfNotExist;

+ (NSMutableArray *)getPhotosWith:(NSArray *)photoIdList;
+ (NSMutableArray *)getPhotosWith:(NSArray *)photoIdList withDB:(FMDatabase *)db;

+ (BOOL)insertPhoto:(VLOPhoto *)photo withDB:(FMDatabase *)db;
+ (BOOL)insertPhoto:(VLOPhoto *)photo;
+ (BOOL)insertPhotos:(NSMutableArray *)photoList;

+ (BOOL)updatePhoto:(VLOPhoto *)photo;
+ (BOOL)updatePhotosMetaWithPhoto:(VLOPhoto *)photo;

+ (BOOL)upsertPhotos:(NSMutableArray *)photoList;
+ (BOOL)upsertPhoto:(VLOPhoto *)photo;
+ (BOOL)upsertPhoto:(VLOPhoto *)photo withDB:(FMDatabase *)db;

+ (BOOL)removePhoto:(VLOPhoto *)photo;
+ (BOOL)removePhoto:(VLOPhoto *)photo withDB:(FMDatabase *)db;

@end


@interface VLOLocalStorage (timeline)

+ (BOOL)createTimelineTableIfNotExist;

+ (NSMutableArray *)loadTimelineCellsIn:(VLOTravel *)travel fromCell:(NSString *)cellId;
+ (NSMutableArray *)loadTimelineCellsIn:(VLOTravel *)travel fromCell:(NSString *)cellId withDB:(FMDatabase *)db;
+ (VLOLog *)loadTimelineCellIn:(VLOTravel *)travel cellId:(NSString *)timelineId;
+ (VLOLog *)loadTimelineCellIn:(NSString *)travelId cellId:(NSString *)timelineId withDB:(FMDatabase *)db;

+ (BOOL)insertTimelineCell:(VLOLog *)timelineCell;

+ (BOOL)updateTimelineCell:(VLOLog *)timelineCell isChangedOrder:(BOOL)isChangedOrder;
+ (BOOL)updateFromAddPhotoTimelineCell:(VLOPhotoLog *)timelineCell;
+ (BOOL)updateFromPhotoDownloadTimelineCell:(VLOPhotoLog *)timelineCell;
+ (BOOL)updateFromPhotoInfoChangeTimelineCell:(VLOPhotoLog *)timelineCell withDB:(FMDatabase *)db;

+ (BOOL)removeTimelineCellForUserInteraction:(VLOLog *)timelineCell;
+ (BOOL)removeTimelineCell:(VLOLog *)timelineCell withDB:(FMDatabase *)db;

+ (NSMutableArray *)loadSyncedPhotoTypeCellsIn:(VLOTravel *)travel;

+ (BOOL)updateLikeInfoWithTimelineCell:(VLOLog *)timelineCell;
+ (NSArray *)updateLikeInfoWithLikeInfos:(NSArray *)infos;

@end


@interface VLOLocalStorage (auth)

+ (BOOL)createAuthTableIfNotExist;

+ (BOOL)setCurrentUser:(VLOUser *)user;
+ (VLOUser *)getCurrentUser;
+ (VLOUser *)getCurrentUserWithDB:(FMDatabase *)db;
+ (BOOL)removeCurrentUser;

+ (NSMutableArray *)getNationListWithUser:(VLOUser *)user;

+ (BOOL)setAuthToken:(VLOAuthToken *)authToken;

+ (VLOAuthToken *)getAuthToken;

@end


@interface VLOLocalStorage (user)

+ (BOOL)createUserTableIfNotExist;
+ (VLOUser *)getUserWithUserId:(NSString *)userId;
+ (VLOUser *)getUserWithUserId:(NSString *)userId withDB:(FMDatabase *)db;
+ (BOOL)setUser:(VLOUser *)user;
+ (BOOL)setUser:(VLOUser *)user withDB:(FMDatabase *)db;

@end


@interface VLOLocalStorage (sync)

+ (BOOL)createSyncTableIfNotExist;

+ (BOOL)setSyncTable:(VLOSync *)sync;
+ (BOOL)setSyncTableWithTravelId:(NSString *)travelId version:(NSInteger)version;

+ (VLOSync *)getSyncTravelId:(NSString *)travelId;

+ (VLODeleteDiffFromLocal *)loadUnSyncedDeletedDiff:(VLOTravel *)travel;
+ (BOOL)resetDeletedHistoryInTravel:(VLOTravel *)travel cellIds:(NSArray *)cellIds;

+ (VLOInsertDiffFromLocal *)loadUnSyncedTimelineDiff:(VLOTravel *)travel;
+ (BOOL)updateTimelineSynced:(NSArray *)cellIds;

+ (NSArray *)loadUnSyncedUpdatedTimelineDiff:(VLOTravel *)travel;
+ (BOOL)updateTimelineSyncUpdateWork:(NSString *)cellId;

+ (NSDictionary *)syncServerInsertDiff:(NSArray *)insertDiff andDeleteDiff:(NSArray *)deleteDiff;

+ (NSInteger)countOfUnsyncedTimeline:(VLOTravel *)travel;

@end


@interface VLOLocalStorage (sticker)

+ (BOOL)createStickerTableIfNotExist;
+ (BOOL)initStickerSet;

+ (BOOL)isStickerSetExistWithId:(NSInteger)stickerSetId;
+ (BOOL)isStickerSetNeedUpdatedWithId:(NSInteger)stickerSetId andHash:(NSString *)hash;
+ (NSArray *)getStickerSets;
+ (NSArray *)getStickerSetsWithDB:(FMDatabase *)db;
+ (NSArray *)getStickerSetsWhichNeedResource;
+ (NSArray *)getStickersFromSet:(VLOStickerSet *)stickerSet;
+ (NSArray *)getStickersFromSet:(VLOStickerSet *)stickerSet withDB:(FMDatabase *)db;

+ (BOOL)insertStickerSet:(VLOStickerSet *)stickerSet;
+ (BOOL)updateStickerSet:(VLOStickerSet *)stickerSet;
+ (BOOL)insertStickersFromStickerSet:(VLOStickerSet *)stickerSet withDB:(FMDatabase *)db;
+ (BOOL)updateStickerSet:(VLOStickerSet *)stickerSet basicResource:(NSString *)thumbnailPath onIconPath:(NSString *)onIconPath offIconPath:(NSString *)offIconPath;

+ (BOOL)updateStickersInStickerSet:(VLOStickerSet *)stickerSet withPathList:(NSArray *)pathList;

@end


@interface VLOLocalStorage (migration)

+ (NSInteger)dbCurrentVersion;
+ (BOOL)migrateFromV1ToV2WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV2ToV3WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV3ToV4WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV4ToV5WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV5ToV6WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV6ToV7WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV7ToV8WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV8ToV9WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV9ToV10WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV10ToV11WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV11ToV12WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV12ToV13WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV13ToV14WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV14ToV15WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV15ToV16WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV16ToV17WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV17ToV18WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV18ToV19WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV19ToV20WithVersion:(NSInteger)version;
+ (BOOL)migrateFromV20ToV21WithVersion:(NSInteger)version;

@end


@interface VLOLocalStorage (poi)

+ (BOOL)createPoiTableIfNotExist;
+ (BOOL)initPoiList;
+ (NSArray *)getPoiList;

@end