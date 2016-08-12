//
//
//  AppDelegate.m
//  VOLO
//
//  Created by 1001246 on 2014. 12. 29..
//  Copyright (c) 2014년 SK Planet. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Flurry.h"
#import "VLOConfig.h"

#import "VLOApplication.h"
#import "VLOLocalStorage.h"
#import "VLOSyncManager.h"
#import "VLOAnalyticsManager.h"
#import "VLOLogger.h"
#import "UIColor+VLOExtension.h"
#import "VLOSplashViewController.h"
#import "VLOIntroViewController.h"
#import "VLONetwork.h"
#import "VLOUser.h"
#import "VLOUrgentNotice.h"
#import "UIColor+VLOExtension.h"
#import "VLOWatchHandler.h"
#import "VLOWatchConstants.h"
#import "VLOAuthToken.h"
#import "VLONetwork.h"
#import "VLOAPNS.h"
#import "VLOAPNSManager.h"
#import "VLOUtilities.h"
#import "VLOShortcutManager.h"
#import "VLOMainTabBarController.h"
#import "VLOImageRestoreManager.h"


@interface AppDelegate () <UIAlertViewDelegate>

@property (nonatomic ,strong) VLOUrgentNotice *notice;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];    // Do not stop iPod music while splash video play.
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [VLOAnalyticsManager setConfiguration];
    
    // API 키는 google developer console에 가셔서 volo-direction 카테고리에 있습니다.
    [GMSServices provideAPIKey:[VLOConfig gmsServiceKey]];
    
    [Fabric with:@[[Crashlytics class]]];
    SDWebImageManager.sharedManager.cacheKeyFilter = ^(NSURL *url) {
        if (url.scheme && url.host && url.path) {
            url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        }
        return [url absoluteString];
    };
    
    // Register APNS
    [VLOAPNSManager sharedManager].oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:[VLOConfig oneSignalKey]
                                           handleNotification:nil autoRegister:NO];
    [[VLOAPNSManager sharedManager].oneSignal enableInAppAlertNotification:NO];
    //[VLOAPNSManager registerForRemoteNotifications];
    
    // Logger
    [Flurry setCrashReportingEnabled:NO];
    [Flurry startSession:[VLOConfig flurryKey]];
    // inject analytics: flurry and console logger
    VLOLogger *logger= [VLOLogger sharedLogger];
    [logger injectFlurry];
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        [self application:application didReceiveRemoteNotification:(NSDictionary*)notification];
        [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryPush action:VLOActionLaunchWithPush label:nil andValue:nil];
    }
    
    // shortcut init
    [VLOShortcutManager sharedManager].isOpenedFromBackground = NO;
    
    // db migration
    [self dbMigration];
    // create table
    [VLOLocalStorage createTravelTableIfNotExist];
    [VLOLocalStorage createPhotoTableIfNotExist];
    [VLOLocalStorage createTimelineTableIfNotExist];
    [VLOLocalStorage createAuthTableIfNotExist];
    [VLOLocalStorage createUserTableIfNotExist];
    [VLOLocalStorage createSyncTableIfNotExist];
    [VLOLocalStorage createStickerTableIfNotExist];
    [VLOLocalStorage createPoiTableIfNotExist];
    [VLOLocalStorage initStickerSet];
    [VLOLocalStorage initPoiList];
    
    [self emergeWork];
    
    // Initialize window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorWithHexString:@"9CE7E9"];
    
    VLOSplashViewController *splashViewController = [[VLOSplashViewController alloc] initWithDelegate:self];
    
    self.window.rootViewController = splashViewController;
    [self.window makeKeyAndVisible];
    
    NSNumber *appLaunchCount = [[NSUserDefaults standardUserDefaults] objectForKey:VLO_APP_LAUNCHED_COUNT_KEY];
    if (!appLaunchCount) {
        [[NSUserDefaults standardUserDefaults] setValue:@(1) forKey:VLO_APP_LAUNCHED_COUNT_KEY];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:@(appLaunchCount.integerValue+1) forKey:VLO_APP_LAUNCHED_COUNT_KEY];
    }
    
    NSString *lastAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:VLOLastAppVersionKey];
    if (!lastAppVersion || ![lastAppVersion isEqualToString:[VLOApplication sharedApplication].version]) {
        [[NSUserDefaults standardUserDefaults] setObject:[VLOApplication sharedApplication].version forKey:VLOLastAppVersionKey];
//        [VLONetwork updateAPNSAppVersionWithSuccess:^{
//        } failure:^(NSError *error, NSString *message) {
//            
//        }];
    }
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_3) {
        
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        BOOL launchFromShortCut = NO;
        if (shortcutItem) {
            launchFromShortCut = YES;
            [VLOShortcutManager sharedManager].shortcutItem = shortcutItem;
        }
        
        return !launchFromShortCut;
    }
    
    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    // You code here, you app will already be unload so you can only see what went wrong.
    [[NSUserDefaults standardUserDefaults] setObject:VLOLastOpenedDiscover forKey:VLOLastOpenedHomeKey];
}

- (void)splashViewController:(VLOSplashViewController *)splashViewController didFinishLoadWithNextViewController:(id)viewController
{
    [VLOUtilities changeRootViewController:viewController];
}

- (void)dbMigration
{
    NSInteger dbVersion = [VLOLocalStorage dbCurrentVersion];
    if ([VLOLocalStorage migrateFromV1ToV2WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV2ToV3WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV3ToV4WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV4ToV5WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV5ToV6WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV6ToV7WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV7ToV8WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV8ToV9WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV9ToV10WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV10ToV11WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV11ToV12WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV12ToV13WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV13ToV14WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV14ToV15WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV15ToV16WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV16ToV17WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV17ToV18WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV18ToV19WithVersion:dbVersion] &&
        [VLOLocalStorage migrateFromV19ToV20WithVersion:dbVersion])
        [VLOLocalStorage migrateFromV20ToV21WithVersion:dbVersion];
}

- (void)emergeWork
{
    VLOImageRestoreManager *imageRestoreManager = [[VLOImageRestoreManager alloc] init];
    [imageRestoreManager restore1_5VersionBug];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.absoluteString containsString:@"withvolo"]) {
        NSURL *decodedUrl = [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"]];
        [[VLOShortcutManager sharedManager] setShortCutURL:decodedUrl];
        return YES;
    }
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
        __block UIBackgroundTaskIdentifier watchKitHandler;
    watchKitHandler = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"backgroundTask"
                                                                   expirationHandler:^{
                                                                       watchKitHandler = UIBackgroundTaskInvalid;
                                                                   }];
    
    [[VLOWatchHandler sharedWatchHandler] handleRequest:userInfo withBlock:^(NSDictionary *response, NSError *error) {
        if (response) {
            reply(response);
        } else {
            if (error) {
                reply(@{@"error": error});
            } else {
                reply(@{});
            }
            
        }
    }];
    
    dispatch_after( dispatch_time( DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC * 1 ), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
    } );
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkNotice];
    [[NSNotificationCenter defaultCenter] postNotificationName:VLOAPNSPushNotificationAndReloadNotiName object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if (shortcutItem) {
        [VLOShortcutManager sharedManager].shortcutItem = shortcutItem;
        [[VLOShortcutManager sharedManager] actionShortcut];
    }
}

#pragma mark - Notice from server

- (void)checkNotice
{
    if ([VLOApplication sharedApplication].isOpenUrgentNotice) {
        return;
    }
    [VLOApplication sharedApplication].isOpenUrgentNotice = YES;
    [VLONetwork checkUrgentNotificationWithSuccess:^(VLOUrgentNotice *notice) {
        _notice = notice;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title_notice", )
                                                            message:notice.notice
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"alert_close", )
                                                  otherButtonTitles:nil];
        if (notice.link && notice.link.length) {
            [alertView addButtonWithTitle:notice.linkTitle];
        }
        [alertView show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        [[UIApplication sharedApplication] openURL:_notice.linkURL];
    }
}

#pragma mark - Push notification service

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // 푸쉬 테스트를 위해 하는 리퀘스트입니다. 평상시에는 주석을 겁니다.
    //    AFHTTPRequestOperationManager *manager = [VLONetwork managerWithHeader];
    //
    //    NSString *logString = [NSString stringWithFormat:@"%@||%@||%@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion];
    //
    //    [manager POST:@"http://doornot.ga/volo/add" parameters:@{@"log": logString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //
    //    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //
    //    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Register device token to VLOAPNSManager
    [VLOAPNSManager sharedManager].deviceToken = deviceToken;
//    if ([VLOLocalStorage getAuthToken].accessToken) {
//        if ([VLOAPNSManager sharedManager].lastDeviceTokenString) {
//            [VLONetwork updateDeviceTokenWithSuccess:nil failure:nil];
//        } else {
//            [VLONetwork registerDeviceTokenWithSuccess:nil failure:nil];
//        }
//    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    [[VLOAPNSManager sharedManager] receivedRemoteNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    BOOL handled = NO;
    
    // Extract the payload
    NSString *type = [userActivity activityType];
    NSDictionary *userInfo = [userActivity userInfo];
    
    restorationHandler(@[self.window.rootViewController]);
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        // do something with the URL
    }
    
    handled = YES;
    return handled;
}

@end