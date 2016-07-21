
 //
//  TimelineViewController.m
//  Volo
//
//  Created by 1001246 on 2014. 12. 29..
//  Copyright (c) 2014년 SK Planet. All rights reserved.
//

#import <Flurry-iOS-SDK/Flurry.h>
// View controllers
#import "VLOMainTabBarController.h"
#import "VLOTimelineViewController.h"
#import "VLOTimelineTableViewController.h"
#import "VLOPhotoDetailViewController.h"
#import "VLOTravelListAddViewController.h"
#import "VLOTravelListViewController.h"
#import "VLOSearchFriendsViewController.h"
#import "VLOFriendsListViewController.h"
#import "VLOTagEditViewController.h"
#import "VLOCellEditorViewController.h"
// Map Editor
#import "VLOMapEditorViewController.h"
#import "VLOMapEditorNavigationController.h"
// Text Editor
#import "VLOTextEditorNavigationController.h"
#import "VLOTextEditorViewController.h"
// Emphasis Editor
#import "VLOQuoteEditorViewController.h"
// Photo Editor
#import "VLOPhotoLogEditorViewController.h"
#import "VLOPhotoLogEditorNavigationController.h"
// Route Editor
#import "VLORouteEditorViewController.h"
#import "VLORouteEditorNavigationController.h"

// Views
#import "VLOTimelineCoverView.h"
#import "VLOTimelineNavigationBar.h"
#import "VLOTimelineTableView.h"
#import "VLOActionSheet.h"
#import "VLOShareAlert.h"
#import "VLOActivityIndicator.h"
#import "VLORearrangeTooltip.h"
#import "VLOTableViewDayCell.h"
#import "VLOTableViewMapCell.h"
#import "VLOSearchFriendsToolTip.h"
#import "VLOTimelineScrollIndicator.h"
#import "VLOTimelineDayIndicator.h"
#import "JTSScrollIndicator.h"
#import "VLOMapDetailViewController.h"
#import "VLODiscoverTravelListViewController.h"
#import "VLOInspirationCell.h"
#import "VLOTravelShareAndPrivacySettingViewController.h"
#import "VLOTravelPrivacySettingViewController.h"
#import "VLOAddCellMenuButton.h"

// Models
#import "VLOUser.h"
#import "VLOLog.h"
#import "VLOPhotoLog.h"
#import "VLOQuoteLog.h"
#import "VLOMapLog.h"
#import "VLOTravel.h"
#import "VLOPhoto.h"
#import "VLOTextLog.h"
#import "VLORouteLog.h"
#import "VLOPlace.h"
#import "VLORouteNode.h"
#import "VLOAPNS.h"
#import "VLOTravelListCell.h"
#import "VLODayLog.h"
#import "VLOTimezone.h"
#import "VLOInspiration.h"

// Utilities
#import "NSString+VLOExtension.h"
#import "VLONotificationNames.h"
#import "VLOBlurredImageView.h"
#import "NSDate+VLOExtension.h"
#import "UIColor+VLOExtension.h"
#import "UIFont+VLOExtension.h"
#import "VLOUtilities.h"
#import "VLOShare.h"
#import "VLOViewTransAnimation.h"
#import "VLOLocalStorage.h"
#import "VLONetwork.h"
#import "VLOSyncManager.h"
#import "VLOAPNSManager.h"
#import "VLOAnalyticsManager.h"
#import "VLOShortcutManager.h"

// Library
#import <Masonry/Masonry.h>
#import <AFNetworking/AFNetworking.h>



@interface VLOTimelineViewController () <VLOTimelineTableViewDelegate, VLOTableViewPhotoCellDelegate, VLOTableViewMapCellDelegate,
        VLOTimelineCoverViewDelegate, VLOTravelListModificationDelegate, VLOTimelineTableViewControllerDelegate,
        VLORouteEditorDelegate, VLOMapEditorDelegate, VLOTextEditorDelegate,
        VLOPhotoLogEditorDelegate, VLOQuoteEditorDelegate,
        VLOSearchFriendsViewControllerDelegate, VLOTravelListAddViewControllerDelegate,
        VLOTimelineScrollIndicatorDelegate, VLOTimelineTableFooterDelegate,VLOMenuButtonDelegate, UIGestureRecognizerDelegate,
        VLOTagEditViewDelegate, VLOFriendsListDelegate>
{
    CGFloat lastY;
    
    CGPoint _lastScrollContentOffset;
    CGFloat _scrollMovedOffset;
    
    BOOL _APNSNotificationAdded;
    
    VLORearrangeTooltip *rearrangeTooltip;
    
    UIView *_topBounds;
    CAGradientLayer *_topGradient;
    UIView *_bottomBounds;
    CAGradientLayer *_bottomGradient;
    
    CGFloat _coverTop;
    UIView *_tableViewBackground;
    
    BOOL _isScrollingWithBar;
    BOOL _isCoverMoving;
}

@property (nonatomic) BOOL isHidden;
@property (strong, nonatomic) VLOActivityIndicator *activityIndicator;
@property (strong, nonatomic) VLOTimelineScrollIndicator *scrollIndicator;

@property (nonatomic) BOOL isViewMode;
@property (nonatomic) BOOL isOpenView;

@property (nonatomic, strong) VLOPrivateStatusBar *privateStatusBar;
@property (nonatomic, strong) VLOSyncStatusBar *syncStatusBar;

@end

@implementation VLOTimelineViewController

- (id)init
{
    self = [super init];
    if(self){
        _isHidden = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_shortcutTravel) { // iOS 3d touch
        _travel = _shortcutTravel;
        [(VLOMainTabBarController *)self.tabBarController setIsTimelineViewShown:YES withAnimated:NO];
    }
    
    if (_travel.serverId) {
        [Flurry logEvent:@"TIMELINE_LOADED" withParameters:@{@"travelId": _travel.serverId} timed:YES]; // log
        
        if ([_travel.serverId isKindOfClass:[NSString class]]) { // push용 앱 Notification 시스템 초기화
            [self addAPNSObserverWithServerId:_travel.serverId];
            _APNSNotificationAdded = YES;
        }
        VLOTravel *localTravel = [VLOLocalStorage loadTravelWithServerId:_travel.serverId];
        _isViewMode = !localTravel;
    } else {
        _isViewMode = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDoneEditting:) name:@"editDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:) name:VLOTravelModifiedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSync) name:VLOResyncTimelineNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoSync) name:UIApplicationWillEnterForegroundNotification object:nil];
    // set navigation bar
    self.title = @"";
    self.navigationItem.titleView = nil;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.clipsToBounds = YES;
    
    _activityIndicator = [[VLOActivityIndicator alloc] init];
    
    // init, set coverview
    _coverView = [[VLOTimelineCoverView alloc] initWithFrame:CGRectMake(0, 0, [VLOUtilities screenWidth], [VLOUtilities screenWidth]) andIsViewMode:_isViewMode];
    _coverView.delegate = self;
    _coverView.isViewMode = _isViewMode;
    _coverTop = _coverView.frame.size.height;
    _coverView.travel = _travel;
    [self.view addSubview:_coverView];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(coverGestureAction:)];
    gesture.delegate = self;
    [_coverView addGestureRecognizer:gesture];
    _isCoverOpen = YES;
    
    [self syncLogicWithShowAlert:NO];
    
    // init, set tableview]
    _tableViewBackground = [[UIView alloc] initWithFrame:self.view.bounds];
    _tableViewBackground.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:_tableViewBackground aboveSubview:_coverView];
    
    _tableViewController = [[VLOTimelineTableViewController alloc] initWithNibName:@"VLOTimelineTableViewController" bundle:nil];
    _tableViewController.travel = _travel;
    _tableViewController.photoDelegate = self;
    _tableViewController.mapDelegate = self;
    _tableViewController.delegate = self;
    _tableViewController.footerDelegate = self;
    _tableViewController.activityIndicator = _activityIndicator;
    _tableViewController.isViewMode = _isViewMode;
    
    _tableView = (VLOTimelineTableView *)_tableViewController.tableView;
    _tableView.scrollTopDelegate = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.scrollEnabled = NO;
    _tableView.frame = CGRectMake(0,0,[VLOUtilities screenWidth], [VLOUtilities screenHeight]);
    
    [self setCoverViewWithY:_coverTop];
    
    _lastScrollContentOffset.y = -64;
    [self addChildViewController:_tableViewController];
    [self.view addSubview:_tableView];
    [self.view addSubview:_activityIndicator];
    [_tableView setNeedsDisplay];
    
    _topBounds = [[UIView alloc] init];
    _topBounds.alpha = 0.0f;
    _topBounds.backgroundColor = [UIColor clearColor];
    _topGradient = [CAGradientLayer layer];
    _topGradient.colors = @[(id)[[UIColor colorWithHexString:@"#ffffff" alpha:1.0f] CGColor], (id)[[UIColor colorWithHexString:@"#ffffff" alpha:0.0f] CGColor]];
    [_topBounds.layer addSublayer:_topGradient];
    
    _bottomBounds = [[UIView alloc] init];
    _bottomBounds.alpha = 0.0f;
    _bottomBounds.backgroundColor = [UIColor clearColor];
    _bottomGradient = [CAGradientLayer layer];
    _bottomGradient.colors = @[(id)[[UIColor colorWithHexString:@"#ffffff" alpha:0.0f] CGColor], (id)[[UIColor colorWithHexString:@"#ffffff" alpha:1.0f] CGColor]];
    [_bottomBounds.layer addSublayer:_bottomGradient];
    
    [self.view addSubview:_topBounds];
    [self.view addSubview:_bottomBounds];
    
    // init, set navbar
    self.automaticallyAdjustsScrollViewInsets = NO;


    BOOL isFromUserHome = NO;
    NSInteger selfIndex = [self.navigationController.viewControllers indexOfObject:self];
    if (selfIndex > 0) {
        isFromUserHome = [[self.navigationController.viewControllers objectAtIndex:selfIndex-1] isKindOfClass:[VLOTravelListViewController class]];
    }

    _timelineNavigationBar = [[VLOTimelineNavigationBar alloc] initWithIsViewMode:_isViewMode isFromUserHome:isFromUserHome];
    [_timelineNavigationBar.menuButton addTarget:self action:@selector(showStoryActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [_timelineNavigationBar.shareButton addTarget:self action:@selector(showShareMenu:) forControlEvents:UIControlEventTouchUpInside];
    [_timelineNavigationBar.backButton addTarget:self action:@selector(backToTravelListAtTimeline:) forControlEvents:UIControlEventTouchUpInside];
    [_timelineNavigationBar.syncButton addTarget:self action:@selector(manualSync:) forControlEvents:UIControlEventTouchUpInside];


    [self.view addSubview:_timelineNavigationBar];
    _tableViewController.syncDelegate = _timelineNavigationBar;

    
    /*
    _menu = [[VLOTimelineMenu alloc] init];
    _menu.delegate = self;
     
    // TODO: 이하 확인
     
    _menuButton = [[VLOTimelineMenuButton alloc] initWithHandler:^(BOOL success) {
        if (_tableViewController.isOrderChangeMode) {
            [_tableView reloadData];
            [_tableViewController endOrderChangeModeWithIsChanged:NO];
            return;
        }
        _tableViewController.addToBelowPivotLog = nil;
        [self presentViewController:_menu animated:NO completion:nil];
        [self coverCloseAndHideDayIndicator:YES withComplete:^{
            [self showNavigationBar];
        }];
    }];
    _menuButton.hidden = _isViewMode;
    [self.view addSubview:_menuButton];
    */
    
    
    UIImage *addIcon = [UIImage imageNamed:@"TimelineMenuButton"];
    CGFloat radius = 30.0f;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGPoint center = CGPointMake(screenBounds.size.width - radius -20.0f, screenBounds.size.height - radius - 20.0f);
    CGFloat originY = center.y - radius;
    CGRect toFrame = CGRectMake(10.0, originY, screenBounds.size.width - 20.0f, screenBounds.size.height - originY -10.0f);
    
    VLOAddCellMenuButton *fMenuButton = [[VLOAddCellMenuButton alloc] initWithCenterPoint:center
                                                                        initialButtonIcon:addIcon
                                                                                   radius:radius
                                                                               emitRadius:radius + 20.0f
                                                                                  toFrame:toFrame
                                                                                 toRadius:30.0f
                                                                                fromAlpha:0.5f
                                                                                  toAlpha:1.0f
                                                                                fromColor:[UIColor vlo_greenColor]
                                                                                  toColor:[UIColor vlo_buttonGreenColor]];
    fMenuButton.hidden = _isViewMode;
    fMenuButton.delegate = self;
    [self.view addSubview:fMenuButton];
    
    _addCellMenuButton = fMenuButton;
    
    _scrollIndicator = [[VLOTimelineScrollIndicator alloc] initWithScrollView:_tableView];
    _scrollIndicator.delegate = self;
//    [_scrollIndicator hideWithAnimation:NO];
    _scrollIndicator.scrollIndicator = _tableViewController.indicator;
    _scrollIndicator.isNoDateTravel = !_travel.hasDate;
    _tableViewController.indicator.delegate = _scrollIndicator;
    
    [self.view addSubview:_scrollIndicator];
    
    // set autolayout
    [self makeAutoLayoutConstraints];
    
    [self initNavigationBar];
    [VLOSyncManager resetSyncStateInTravel:_travel];
    
    if (_isOpenedFromEditor) {
        self.navigationController.viewControllers = @[self];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [_coverView updateConstraints];
    [super viewWillAppear:animated];
    
    if (!rearrangeTooltip) {
        rearrangeTooltip = [[VLORearrangeTooltip alloc] init];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [(VLOMainTabBarController *)self.tabBarController setIsTimelineViewShown:YES withAnimated:YES];
    
    [self showCustomStatusBar];
    
    if (!_isViewMode) {
        [[NSUserDefaults standardUserDefaults] setObject:VLOLastOpenedTimeline forKey:VLOLastOpenedHomeKey];
        [[NSUserDefaults standardUserDefaults] setObject:_travel.travelId forKey:VLOLastOpenedTimelineLastTravelIdKey];
    }
}


- (void)showCustomStatusBar
{
    if (!_privateStatusBar) {
        _privateStatusBar = [[VLOPrivateStatusBar alloc] init];
        [self.view addSubview:_privateStatusBar];
        
        UITapGestureRecognizer *privacyStatusBarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarTapGesture:)];
        [_privateStatusBar addGestureRecognizer:privacyStatusBarTapGesture];
    }
    
    if (!_syncStatusBar) {
        _syncStatusBar = [[VLOSyncStatusBar alloc] init];
        [self.view addSubview:_syncStatusBar];
        
        UITapGestureRecognizer *statusBarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarTapGesture:)];
        [_syncStatusBar addGestureRecognizer:statusBarTapGesture];
        _tableViewController.syncStatusBar = _syncStatusBar;
    }
    
    if (_syncStatusBar.isSyncOn) {
        [_syncStatusBar show];
    }
    if (_travel.privacyType == VLOTravelPrivacyPrivateType) {
        [_privateStatusBar show];
    }
}

- (void)hideCustomStatusBar
{
    [_privateStatusBar hide];
    [_syncStatusBar hide];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(_isHidden){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    [VLOAnalyticsManager reportGAScreenWithName:kVLOScreenNameTimeline];
    [_coverView resizeTextViewHeight];
    
    if (!_isViewMode) {
        [VLOShortcutManager setShortcutWithTravel:_travel];
    }
    _isOpenView = NO;
    
    UITapGestureRecognizer *tapSummary =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showSummary)];
    [tapSummary setNumberOfTapsRequired:1];
    [_coverView.summaryView addGestureRecognizer:tapSummary];
    
    [self showSummary];
}

- (void)showSummary
{  
    // summaryView 리셋.
    [[_coverView.summaryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _coverView.summaryView.layer.sublayers = nil;
    
    NSMutableArray *placeList = [[NSMutableArray alloc] init];
    NSArray *logs = _tableViewController.logs;
    
    for (VLOLog *log in logs) {
        if (log.type == VLOLogTypeMap) {
            [placeList addObject:log.place];
        } else if (log.type == VLOLogTypeRoute) {
            for (VLORouteNode *node in ((VLORouteLog *)log).nodes) {
                [placeList addObject:node.place];
            }
        }
    }
    
    // [_coverView addSubview:_summaryView];
    VLOTimelineSummary *summaryMaker = [[VLOTimelineSummary alloc] initWithView:_coverView.summaryView andPlaceList:placeList];
    [summaryMaker animateSummary];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!_isOpenView) {
        [_travelListViewController travelListSync];
        [_travelListViewController.tableView reloadData];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self hideCustomStatusBar];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (!_isOpenedFromDiscover && !_isOpenView && _travelListViewController &&
            ((VLOMainTabBarController *)_travelListViewController.tabBarController).selectedIndex != 0)
    {
        [(VLOMainTabBarController *)_travelListViewController.tabBarController setIsTagWrite:NO withTagWriteTitle:@""];
        [(VLOMainTabBarController *)_travelListViewController.tabBarController setIsTimelineViewShown:NO];
    }
    
    [_privateStatusBar hide];
    [_syncStatusBar hide];
    
    _isOpenView = NO;
}

- (void)makeAutoLayoutConstraints
{
    [_timelineNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(@0);
        make.height.equalTo(@([VLOUtilities customizedNavigationBarHeight]));
    }];
    
    /*
    [_menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(@(-19.0f));
        make.size.equalTo(@45.0f);
    }];
    */
    
    [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@60.0f);
        make.center.equalTo(self.view);
    }];
    
//    [_searchFriendsToolTip mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.right.equalTo(@.0f);
//        make.top.equalTo(_timelineNavigationBar.mas_bottom);
//        make.bottom.equalTo(_searchFriendsToolTip.containerView);
//    }];
    
    [_scrollIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@.0f);
        make.bottom.equalTo(@(-80.0f));
        make.top.equalTo(@85.0f);
        make.width.equalTo(@70.0f);
    }];
}

#pragma mark - tag editor view delegate

 - (void)tagEditView:(VLOTagEditViewController *)tagEditView didDoneWithTags:(NSArray *)tags
 {
     [_tableView reloadData];
     [_tableView.tableFooterView setNeedsLayout];
 }

#pragma mark - Timeline indicator delegate

- (void)timelineScrollIndicatorDidEndRecognizeGesture:(VLOTimelineScrollIndicator *)indicator
{
    _isScrollingWithBar = NO;
    _timelineNavigationBar.hidden = NO;
    
    if (!_tableViewController.isOrderChangeMode) {
        [_timelineNavigationBar show];
    }
    
//    [_scrollIndicator hideWithAnimation:YES];
}

- (void)timelineScrollIndicatorDidBeginRecognizeGesture:(VLOTimelineScrollIndicator *)indicator
{
    _isScrollingWithBar = YES;
    _timelineNavigationBar.hidden = YES;
}

- (void)timelineScrollIndicator:(VLOTimelineScrollIndicator *)indicator didScrollToDay:(VLODayLog *)dayLog
{
    NSInteger index = [_tableViewController.logs indexOfObject:dayLog];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    VLOTableViewDayCell *dayCell = (VLOTableViewDayCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [dayCell sparkle];
}

#pragma mark -------------

- (void)statusBarFrameWillChange:(NSNotification *)notification
{
    CGRect statusBarFrame = [notification.userInfo[UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    CGFloat statusBarHeight = statusBarFrame.size.height;
    if (statusBarFrame.size.height > 30.0f) {
        [_timelineNavigationBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(44.0f + statusBarHeight/2.0f));
        }];
    } else {
        [_timelineNavigationBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(44.0f + statusBarHeight));
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)initNavigationBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    _isHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)backToTravelListAtTimeline:(id)sender;
{
    [VLOSyncManager stopSyncLogicIn:_travel];
    if (_isOpenedFromEditor) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)coverGestureAction:(UIPanGestureRecognizer *)gesture
{
    _isCoverMoving = YES;
    CGFloat yPoint = [gesture locationInView:self.view].y;
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat moveY = yPoint - lastY;
        if ((_tableView.frame.origin.y >= _coverView.frame.size.height && moveY > 0) || _tableView.frame.origin.y > _coverView.frame.size.height) {
            [_coverView coverPageInteractionWithGetureYMove:moveY];
            [self setCoverViewWithY:(_coverView.imageView.frame.size.height-PARALLAX_MAX-_coverView.frame.size.height)/2.0f+_coverView.frame.size.height];
        }
        else {
            [self moveCoverViewWithY:moveY];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([_coverView isCoverPageInteractedForClose]) {
            [self backToTravelListAtTimeline:self];
        }
        else {
            [_coverView coverPageInteractionEnd];
            [self coverViewMoveEnded];
        }
    }
    
    lastY = yPoint;
}

- (void)statusBarTapGesture:(UITapGestureRecognizer *)gesture
{
    [_tableView setContentOffset:CGPointMake(0, -_tableView.contentInset.top) animated:YES];
}


# pragma mark - cover view move action

- (void)setCoverViewWithY:(CGFloat)setY
{
    _tableView.frame = CGRectSetY(_tableView.frame, setY);
    _tableViewBackground.frame = CGRectSetY(_tableViewBackground.frame, setY);
    
    if (_tableView.contentOffset.y <= _tableView.contentInset.top) {
        CGFloat contentInsetTop = MAX(0, 64.0f-(setY/[VLOUtilities screenWidth]*64.0f));
        [_tableView setContentInset:UIEdgeInsetsMake(contentInsetTop, 0, 64, 0)];
        [_tableView setContentOffset:CGPointMake(0, -contentInsetTop)];
    }
    if (setY < [VLOUtilities screenWidth]) {
        CGFloat calcVariation = PARALLAX_MAX * (setY/[VLOUtilities screenWidth]);
        _coverView.imageView.frame = CGRectMake(-calcVariation/2.0f, -calcVariation/2.0f, _coverView.frame.size.width+calcVariation, _coverView.frame.size.width+calcVariation);
        _scrollIndicator.hidden = YES;
    }
}

- (void)moveCoverViewWithY:(CGFloat)moveY
{
//    [_scrollIndicator hideWithAnimation:NO];
//    _searchFriendsToolTip.alpha = .0f;
    if (_tableViewController.isOrderChangeMode) {
        _tableView.isScrollOnTop = NO;
    }
    else if (_coverTop + moveY > _coverView.frame.size.height) {
        _coverTop = _coverView.frame.size.height;
        [self setCoverViewWithY:_coverTop];
    }
    else if (_coverTop + moveY < 0)
    {
        _coverTop = 0.0f;
        [self setCoverViewWithY:_coverTop];
        _tableView.isScrollOnTop = NO;
        [self coverViewMoveEnded];
    }
    else {
        _tableView.scrollEnabled = NO;
        _coverTop += moveY;
        [self setCoverViewWithY:_coverTop];
        [_timelineNavigationBar disappear];
        _isHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)coverViewMoveEnded
{
    if((_isCoverOpen && _coverTop - _coverView.frame.size.height >= -[VLOUtilities screenHeight]/10)
       || (!_isCoverOpen && _coverTop >= [VLOUtilities screenHeight]/10))
    {
        [self coverOpen];
    }
    else {
        [self coverCloseAndHideDayIndicator:YES];
    }
}

- (void)coverOpen
{
//    [_scrollIndicator hideWithAnimation:NO];
    _isCoverOpen = YES;
    _coverTop = _coverView.frame.size.height;
    
    CGFloat duration = (_coverView.frame.size.height - _coverTop)/_coverView.frame.size.height * 0.4;
    if (duration < 0.2) duration = 0.2;
    
    [self setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setCoverViewWithY:_coverTop];
    } completion:^(BOOL finished) {
        _isCoverMoving = NO;
    }];
}

- (void)coverClose
{
    [self coverCloseAndHideDayIndicator:NO];
}

- (void)coverCloseAndHideDayIndicator:(BOOL)hideDayIndicator
{
    [self coverCloseAndHideDayIndicator:hideDayIndicator withComplete:^{
        [self showNavigationBar];
    }];
}


- (void)coverCloseWithComplete:(void (^)())complete
{
    [self coverCloseAndHideDayIndicator:NO withComplete:complete];
}

- (void)coverCloseAndHideDayIndicator:(BOOL)hideDayIndicator withComplete:(void (^)())complete
{
    if(_coverView.isFirstOpen){
        [_coverView checkTimeInCoverViewWithPresentTime:[[NSDate date] timeIntervalSince1970] andWhere:@"TIMELINE"];
    }
    _tableView.scrollEnabled = YES;
    CGFloat duration = _coverTop/_coverView.frame.size.height * 0.4;
    if (duration < 0.2) duration = 0.2;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _coverTop = 0.0f;
        [self setCoverViewWithY:_coverTop];
    } completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
        _isCoverMoving = NO;
        _isCoverOpen = NO;
    }];
    [self setNeedsStatusBarAppearanceUpdate];
//    [_scrollIndicator showWithAnimation:YES];
    //_dayIndicator.hidden = hideDayIndicator;
}


#pragma mark - menu action sheet

- (void)showStoryActionSheet
{
    UIColor *blackItemColor = [UIColor vlo_blackColor];
    UIColor *redItemColor = [UIColor colorWithHexString:@"ff8791"];
    UIFont *itemFont = [UIFont ralewayMediumWithSize:15.0f];
    
    VLOActionSheet *actionSheet = [[VLOActionSheet alloc] init];
    VLOActionSheetSection *menuSection = [[VLOActionSheetSection alloc] init];

    /*
    VLOActionSheetItem *addTagItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"actionSheet_addTagItem", ) color:blackItemColor font:itemFont handler:^{
        _isOpenView = YES;
        VLOTagEditViewController *tagEditor = [[VLOTagEditViewController alloc] init];
        tagEditor.modificationTravel = _travel;
        tagEditor.isFromMenu = YES;
        tagEditor.delegate = self;
        tagEditor.tags = _travel.tags;
        [self presentViewController:tagEditor animated:YES completion:nil];
        
        [VLOAnalyticsManager reportEventWithCategory:VLOCategoryTimeline action:VLOActionAddTag label:_travel.url andValue:nil];
    }];
    */

    VLOActionSheetItem *editItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"actionSheet_editItem", ) color:blackItemColor font:itemFont handler:^{
        [self editCoverViewWithPressType:VLOTimelineCoverPressedViewTypeDefault isLongPress:NO];

        [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionEditCover label:nil andValue:nil];
    }];
    VLOActionSheetItem *inviteFriendsItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"actionSheet_inviteFriends", ) color:blackItemColor font:itemFont handler:^{
        [self presentInviteFriendsView];

        [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionInviteFriends label:_travel.url andValue:nil];
    }];

    VLOActionSheetItem *sharingItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"story_setting_sharing", )
                                                                          color:blackItemColor
                                                                           font:itemFont
                                                                        handler:^{
        _isOpenView = YES;
        [self showShareActionSheet];
    }];

    VLOActionSheetItem *privacyItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"story_setting_privacy", )
                                                                                    color:blackItemColor
                                                                                     font:itemFont handler:^{
        VLOTravelPrivacySettingViewController *settingView = [[VLOTravelPrivacySettingViewController alloc] init];
        settingView.travel = _travel;
        settingView.timelineViewController = self;
        
        _isOpenView = YES;
        [self.navigationController pushViewController:settingView animated:YES];
    }];
    
    NSString *removeTitle = (_travel.users.count > 1) ? NSLocalizedString(@"actionSheet_leaveTrip", ) : NSLocalizedString(@"actionSheet_removeTrip", );
    VLOActionSheetItem *removeItem = [[VLOActionSheetItem alloc] initWithTitle:removeTitle color:redItemColor font:itemFont handler:^{
        
        NSString *message;
        NSString *title;
        
        if (_travel.users.count > 1) {
            title = NSLocalizedString(@"alert_exit_trip_title", );
            message = NSLocalizedString(@"alert_confirm_contents_trip_together", );
        } else {
            title = NSLocalizedString(@"alert_confirm_title", );
            message = NSLocalizedString(@"alert_confirm_contents_trip", );
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"alert_no", )
                                              otherButtonTitles:NSLocalizedString(@"alert_yes", ), nil];
        [alert show];
    }];
    
    [menuSection addItem:editItem];
    //[menuSection addItem:addTagItem];
    [menuSection addItem:inviteFriendsItem];
    [menuSection addItem:sharingItem];
    [menuSection addItem:privacyItem];

    [actionSheet addSection:menuSection];
    actionSheet.cancelSectionItems = [@[removeItem] mutableCopy];
    [actionSheet setCancelTitle:NSLocalizedString(@"actionSheet_cancel", ) andHandler:^{}];
    [actionSheet showInViewController:self];
}

- (void)shareToFacebookWithTravel:(VLOTravel *)travel
{
    if (_travel.serverId) {

    }
}

- (void)copyURLWithTravel:(VLOTravel *)travel
{
    
}

- (void)editCoverViewWithPressType:(VLOTimelineCoverPressedViewType)type isLongPress:(BOOL)isLongPress
{
    _isOpenView = YES;
    VLOTravelListAddViewController *viewController = [[VLOTravelListAddViewController alloc] init];
    viewController.type = VLOTravelListAddViewTypeModification;
    viewController.modificationTravel = _travel;
    viewController.delegate = self;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    viewController.modificationDelegate = self;
    viewController.pressedType = type;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)showShareActionSheet
{

    BOOL isPublic = (_travel.privacyType == VLOTravelPrivacyPublicType);

    UIColor *blackItemColor = [UIColor vlo_blackColor];
    UIFont *itemFont = [UIFont ralewayMediumWithSize:15.0f];
    
    VLOActionSheet *actionSheet = [[VLOActionSheet alloc] init];
    VLOActionSheetSection *shareSection = [[VLOActionSheetSection alloc] init];

    VLOActionSheetItem *shareItem =
    [[VLOActionSheetItem alloc]
     initWithTitle:NSLocalizedString(@"actionSheet_shareItem", )
             color:[UIColor colorWithHexString:@"4468b4"]
              font:itemFont
         handler:^{
             VLOShare *shareManager = [VLOShare sharedInstance];
             [shareManager shareToFacebookWithTravel:_travel
                                  fromViewController:self
                                          completion:nil
                                             failure:nil
                                            withUser:[_travel.users firstObject]];
         }];
    
    VLOActionSheetItem *copyURLItem =
    [[VLOActionSheetItem alloc]
     initWithTitle:NSLocalizedString(@"actionSheet_copyURLItem", )
             color:(isPublic? [UIColor vlo_blackColor]:[UIColor vlo_lightGrayColor])
            font:itemFont
         handler:^{

             NSInteger lastDay = [VLOLocalStorage lastDayOfTravel:_travel];
             VLOShareAlert *alert = [[VLOShareAlert alloc] initWithURL:_travel.url
                                                            andLastDay:lastDay
                                                                  type:VLOShareAlertTypeLinkCopy
                                                              withUser:[_travel.users firstObject]];
             [alert showInViewController:self];

             [VLOAnalyticsManager facebookTrackingEvent:VLOFBLogShareTravelWithLink];
             [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionShareTimelineLink label:_travel.travelId andValue:nil];
             [self copyURLWithTravel:_travel];
         }];

    if(isPublic) {
        actionSheet.message = nil;
    } else {
        NSString *privacyMessage = NSLocalizedString(@"story_setting_share_description_private_disabled", );
        actionSheet.message =  privacyMessage;
    }

    shareItem.enabled = isPublic;
    copyURLItem.enabled = isPublic;
    
    [shareSection addItem:shareItem];
    [shareSection addItem:copyURLItem];

    [actionSheet addSection:shareSection];
    [actionSheet setCancelTitle:NSLocalizedString(@"actionSheet_cancel", ) andHandler:^{
    }];
    
    [actionSheet showInViewController:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        if (!_isOpenedFromDiscover) {
            [(VLOMainTabBarController *)_travelListViewController.tabBarController setIsTagWrite:NO withTagWriteTitle:@""];
            [(VLOMainTabBarController *)_travelListViewController.tabBarController setIsTimelineViewShown:NO];
        }
        
        [self.navigationController popViewControllerAnimated:NO];
        if (_isOpenedFromEditor) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
        }
        else {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            _isHidden = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
        [_travelListViewController removeFromTimelineTravel:_travel];
    }
}


#pragma mark - Sync logic
- (void)syncLogicWithShowAlert:(BOOL)isShowAlert
{
    [self syncLogicWithShowAlert:isShowAlert succeedMessage:nil];
}

- (void)syncLogicWithShowAlert:(BOOL)isShowAlert succeedMessage:(NSString *)message
{
    [self syncLogicWithShowAlert:isShowAlert succeedMessage:message withoutTimelineSync:NO];
}

- (void)syncLogicWithShowAlert:(BOOL)isShowAlert succeedMessage:(NSString *)message withoutTimelineSync:(BOOL)withoutTimelineSync
{
    if (_isViewMode) {
        return;
    }
    if (_travel.serverId) {
        if (_travel.isSynced) {
            [VLONetwork getTravelWithId:_travel.serverId success:^(VLOTravel *serverTravel) {
                BOOL coverChanged = NO;
                BOOL usersInfoChanged = NO;
                BOOL tagsInfoChanged = NO;
                
                if (serverTravel.coverImage != nil && (![_travel.coverImage.serverId isEqualToString:serverTravel.coverImage.serverId] || _travel.coverImage.serverPath == nil)) {
                    _travel.coverImage.imageName = nil;
                    _travel.coverImage.imagePath = nil;
                    _travel.coverImage.serverId = serverTravel.coverImage.serverId;
                    _travel.coverImage.serverUrl = serverTravel.coverImage.serverUrl;
                    _travel.coverImage.serverPath = serverTravel.coverImage.serverPath;
                    _travel.coverImage.photoId = _travel.coverImage.serverId;
                    _travel.coverImage.status = _travel.coverImage.status;
                    _travel.coverImage.isCropped = serverTravel.coverImage.isCropped;
                    _travel.coverImage.cropRect = serverTravel.coverImage.cropRect;
                    [VLOLocalStorage insertPhoto:_travel.coverImage];
                    serverTravel.coverImage = _travel.coverImage;

                    coverChanged = YES;
                } else {
                    serverTravel.coverImage = _travel.coverImage;
                }
                
                if (serverTravel.users.count != _travel.users.count) {
                    usersInfoChanged = YES;
                }
                else {
                    for (NSInteger i = 0; i < _travel.users.count; i ++) {
                        VLOUser *localUser = [_travel.users objectAtIndex:i];
                        VLOUser *serverUser = [serverTravel.users objectAtIndex:i];
                        if ((serverUser.displayName && ![serverUser.displayName isEqualToString:localUser.displayName]) ||
                            (serverUser.profileImage.serverId && ![serverUser.profileImage.serverId isEqualToString:localUser.profileImage.serverId])) {
                            usersInfoChanged = YES;
                            break;
                        }
                    }
                }
                
                if (serverTravel.tags.count != _travel.tags.count) {
                    tagsInfoChanged = YES;
                }
                else {
                    for (NSInteger i = 0; i < _travel.tags.count; i ++) {
                        NSString *serverTag = [serverTravel.tags objectAtIndex:i];
                        NSString *localTag = [_travel.tags objectAtIndex:i];
                        if (![serverTag isEqualToString:localTag]) {
                            tagsInfoChanged = YES;
                            break;
                        }
                    }
                }
                
                if (![_travel.title isEqualToString:serverTravel.title] ||
                    [_travel.startDate compare:serverTravel.startDate] != 0 ||
                    [_travel.endDate compare:serverTravel.endDate] != 0 ||
                    _travel.hasDate != serverTravel.hasDate ||
                    (!_travel.endDate && serverTravel.endDate) ||
                    _travel.likeCount != serverTravel.likeCount ||
                    _travel.privacyType != serverTravel.privacyType ||
                    ![_travel.privacyUserId isEqualToString:serverTravel.privacyUserId] ||
                    usersInfoChanged || coverChanged || tagsInfoChanged)
                {
                    [_travel copyCoverValueFromTravel:serverTravel];
                    
                    [VLOLocalStorage updateTravel:_travel];
                    [_travelListViewController.tableView reloadData];
                }
                _coverView.travel = _travel;
                if (_travel.privacyType == VLOTravelPrivacyPrivateType) {
                    [_privateStatusBar show];
                } else {
                    [_privateStatusBar hide];
                }
            } failure:^(NSError *error, NSString *message) {
                if (isShowAlert && !message.length) {
                    message = NSLocalizedString(@"alert_message_check_network_status", );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_network_error", ) message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_close", ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:closeAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }];
        }
        else {
            [VLONetwork updateTravel:_travel success:^(VLOTravel *travel) {
                travel.isSynced = YES;
                [VLOLocalStorage updateTravel:travel];
            } failure:^(NSError *error, NSString *message) {
                if (isShowAlert && !message.length) {
                    message = NSLocalizedString(@"alert_message_check_network_status", );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_network_error", ) message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_close", ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:closeAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }];
            if (_travel.coverImage.photoId && _travel.coverImage.serverId == nil) {
                [VLONetwork uploadCover:_travel.coverImage inTravel:_travel success:^(NSString *serverUrl, NSString *serverPath, NSString *serverId) {
                    _travel.coverImage.serverId = serverId;
                    _travel.coverImage.serverUrl = serverUrl;
                    _travel.coverImage.serverPath = serverPath;
                    
                    [VLOLocalStorage updatePhoto:_travel.coverImage];
                }];
            }
        }
    }
}


- (void)autoSync
{
    [self syncLogicWithShowAlert:NO];
    [self.tableViewController syncTimeline];
}


#pragma mark - APNS

- (void)pushTravelUpdated:(NSNotification *)notification
{
    [self syncLogicWithShowAlert:NO succeedMessage:nil withoutTimelineSync:YES];
}

- (void)pushInvitationAccepted:(NSNotification *)notification
{
    VLOAPNS *apns = notification.userInfo[@"apns"];
    NSString *message = [NSString stringWithFormat:@"%@ is now in this trip.", apns.api.contents.invitee.name];
    [VLOAPNSManager makeToastWithMessage:message backgroundColor:[UIColor vlo_statusBarGrayColor]];
    
    [self syncLogicWithShowAlert:NO succeedMessage:nil withoutTimelineSync:YES];
}

- (void)pushTravelDeleted:(NSNotification *)notification
{
    [self syncLogicWithShowAlert:NO succeedMessage:nil withoutTimelineSync:YES];
}

- (void)pushSync:(NSNotification *)notification
{
    [self syncLogicWithShowAlert:NO succeedMessage:@"p"];
    [self.tableViewController syncTimeline];
}

- (void)pushPhotoSync:(NSNotification *)notification
{
    [self.tableViewController syncPhotosInTimeline];
}

- (void)manualSync:(UIBarButtonItem *)sender
{
    [self syncLogicWithShowAlert:YES];
    [self.tableViewController syncTimeline];
}

- (void)addAPNSObserverWithServerId:(NSString *)serverId
{
    NSString *APNSSyncTimelineNotificationName = [VLOAPNSSyncTimelineNotificationName stringByAppendingString:serverId];
    NSString *APNSSyncPhotoNotificationName = [VLOAPNSSyncPhotoNotificationName stringByAppendingString:serverId];
    NSString *APNSTravelInformationNotificationName = [VLOAPNSInvitationAcceptedNotificationName stringByAppendingString:serverId];
    NSString *APNSTravelDeletedNotificationName = [VLOAPNSTravelDeletedNotificationName stringByAppendingString:serverId];
    NSString *APNSTravelUpdatedNotificationName = [VLOAPNSTravelUpdatedNotificationName stringByAppendingString:serverId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushSync:) name:APNSSyncTimelineNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushPhotoSync:) name:APNSSyncPhotoNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushInvitationAccepted:) name:APNSTravelInformationNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTravelDeleted:) name:APNSTravelDeletedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTravelUpdated:) name:APNSTravelUpdatedNotificationName object:nil];
}


#pragma mark - Timeline table view controller delegate

- (void)timelineTableViewControllerWillAppear:(VLOTimelineTableViewController *)controller
{
    [self showCustomStatusBar];
}

- (void)timelineTableViewControllerWillDisAppear:(VLOTimelineTableViewController *)controller
{
    [self hideCustomStatusBar];
}

- (void)timelineTableViewControllerDidInitLogList:(VLOTimelineTableViewController *)controller
{
    NSDate *lastViewDate = [_tableViewController getTimelineLastViewDate];
    NSNumber *lastContentOffset = [_tableViewController getTimelineLastContentOffset];
    BOOL isLastContentExist = lastContentOffset && lastViewDate;
    BOOL isContentUpdatedWithin1Day = ([[NSDate date] timeIntervalSince1970] - [lastViewDate timeIntervalSince1970]) < 3600*24;
    
    if (!_isViewMode && isLastContentExist && isContentUpdatedWithin1Day)
    {
        CGFloat contentOffsetY = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastContentOffset]] doubleValue];
        if (contentOffsetY > 0) {
            [self coverCloseWithComplete:^{
                [self showNavigationBar];
            }];
            [_tableView setContentOffset:CGPointMake(0, contentOffsetY) animated:NO];
            //_menuButton.alpha = 1.0f;
            
            if (!_isViewMode) {
                [[NSUserDefaults standardUserDefaults] setObject:@(contentOffsetY) forKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastContentOffset]];
            }
        }
    }
    
    [_tableViewController setTimelineInfoLastViewDate];
    [self calculateDayCells];
}

- (void)timelineTableViewControllerDidUpdateLogList:(VLOTimelineTableViewController *)controller
{
    [self calculateDayCells];
}

- (void)calculateDayCells
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        VLOLog *log = evaluatedObject;
        return log.type == VLOLogTypeDay;
    }];
    NSArray *dayLogs = [_tableViewController.logs filteredArrayUsingPredicate:predicate];
    NSMutableArray *dayIndexes = [NSMutableArray new];
    NSMutableArray *dayYOrigins = [NSMutableArray new];
    
    for (VLODayLog *log in dayLogs) {
        NSInteger index = [_tableViewController.logs indexOfObject:log];
        [dayIndexes addObject:@(index)];
        CGRect cellFrame = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        CGFloat cellY = cellFrame.origin.y;
        [dayYOrigins addObject:@(cellY)];
    }
    
    _scrollIndicator.dayIndexes = dayIndexes;
    _scrollIndicator.dayYOrigins = dayYOrigins;
    _scrollIndicator.dayLogs = dayLogs;
}

- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didGetTravelServerId:(NSString *)serverId
{
    if (!_APNSNotificationAdded && serverId.length > 0) {
        [self addAPNSObserverWithServerId:serverId];
    }
}

- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didChangingOrderStarted:(BOOL)isStarted
{
    if (isStarted) {
        _tableView.clipsToBounds = NO;
        [self coverClose];
        
        
        /*
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = @((135.0f) / 180.0 * M_PI);
        animation.fromValue = @(0);
        animation.delegate = self;
        _menuButton.transform = CGAffineTransformMakeRotation((135.0f) / 180.0 * M_PI);
        [_menuButton.layer addAnimation:animation forKey:@"CloseButtonRotateAnimtaion"];
        [UIView animateWithDuration:0.5f animations:^{
            _menuButton.button.backgroundColor = [UIColor colorWithHexString:@"303a50"];
        } completion:^(BOOL finished) {
        }];
        */
        
        [_addCellMenuButton rotateToXButton];
        
        if (_isHidden) {
            [rearrangeTooltip showTooltipAt:self.view];
            [self hideNavigationBar];
        }
        else {
            _scrollMovedOffset = 0.0;
            [_timelineNavigationBar hideWithComplete:^{
                [rearrangeTooltip showTooltipAt:self.view];
            }];
            _isHidden = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        _topBounds.frame = CGRectMake(-[VLOUtilities screenWidth]/2.0f, 0, [VLOUtilities screenWidth]*2.0f, [VLOUtilities screenHeight]*(1.0f-VLO_REARRANGEPER)/2.0f);
        _topGradient.frame = CGRectMake(0, 0, _topBounds.bounds.size.width, _topBounds.bounds.size.height*3.0f/2.0f);
        _bottomBounds.frame = CGRectMake(-[VLOUtilities screenWidth]/2.0f, self.view.frame.size.height - [VLOUtilities screenHeight]*(1.0f-VLO_REARRANGEPER)/2.0f, [VLOUtilities screenWidth]*2.0f, [VLOUtilities screenHeight]*(1.0f-VLO_REARRANGEPER)/2.0f);
        _bottomGradient.frame = CGRectMake(0, -_bottomBounds.bounds.size.height/2.0f, _bottomBounds.bounds.size.width, _bottomBounds.bounds.size.height*3.0f/2.0f);
        _topBounds.alpha = 1.0f;
        _bottomBounds.alpha = 1.0f;
//        controller.indicator.hidden = YES;
    }
    else {
        _tableView.clipsToBounds = YES;
        
        [rearrangeTooltip hideTooltip];
        
        /*
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = @(0);
        animation.fromValue = @((135.0f) / 180.0 * M_PI);
        animation.delegate = self;
        _menuButton.transform = CGAffineTransformMakeRotation(0);
        [_menuButton.layer addAnimation:animation forKey:@"OpenButtonRotateAnimtaion"];
        
        [UIView animateWithDuration:0.5f animations:^{
            _menuButton.button.backgroundColor = [UIColor colorWithHexString:@"35babc"];
        }];
         */
        
        [_addCellMenuButton rotateToPlusButton];
        
        _topBounds.alpha = 0.0f;
        _bottomBounds.alpha = 0.0f;
//        controller.indicator.hidden = NO;
    }
}

- (void)orderChangeModeStartedTimelineTableViewDidController:(VLOTimelineTableViewController *)controller
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = @((135.0f) / 180.0 * M_PI);
    animation.fromValue = @(0);
    animation.delegate = self;
    
    /*
    _menuButton.transform = CGAffineTransformMakeRotation((135.0f) / 180.0 * M_PI);
    [_menuButton.layer addAnimation:animation forKey:@"CloseButtonRotateAnimtaion"];
     */
}

- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didEditingWasStarted:(BOOL)isStarted
{
    if (isStarted) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self setNeedsStatusBarAppearanceUpdate];
        [self coverClose];
        _isOpenView = YES;
    } else {
        _isOpenView = NO;
    }
}

- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didAddToBelowOfLog:(VLOLog *)log
{
    //[self presentViewController:_menu animated:NO completion:nil];
    [_addCellMenuButton expandToMenu];
//    [self coverCloseAndHideDayIndicator:YES withComplete:^{
//        [self showNavigationBar];
//    }];
}

 - (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didUserProfileSelected:(VLOUser*)user
 {
     [self showTravelListWithUser:user];
 }

- (void)timelineTableViewControllerDidShowEmptyView:(VLOTimelineTableViewController *)controller
{
    if (!_addCellMenuButton.isHaloEmitting && !_addCellMenuButton.isExpanded) {
        [_addCellMenuButton emitHaloWithScaleFactor:1.5
                                           duration:1.5];
    }
}

#pragma mark - Menu contents view delegate

- (BOOL)beforeExpandMenu:(id)sender
{
    [self coverCloseAndHideDayIndicator:YES withComplete:^{
        [self showNavigationBar];
    }];
    return YES; // should return YES not to stop opening menu
}

- (void)timelineMenuDidSelectTextButton:(id)sender
{
    [self timelineMenuDidSelectTextButtonWithAnimated:YES];
}

- (void)timelineMenuDidSelectTextButtonWithAnimated:(BOOL)animated
{
    VLOTextEditorViewController *editor = [[VLOTextEditorViewController alloc] initWithTravel:_travel];
    editor.delegate = self;
    
    [self cellEditorsHeaderDate:editor];
    
    VLOTextEditorNavigationController *navigation = [[VLOTextEditorNavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:navigation animated:animated completion:^{
        [self coverClose];
    }];

    [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionWriteCell label:[VLOLog typeStringWithType:VLOLogTypeText] andValue:nil];
}

- (void)timelineMenuDidSelectRouteButton:(id)sender
{
    VLORouteEditorViewController *editor = [[VLORouteEditorViewController alloc] initWithTravel:_travel];
    VLORouteEditorNavigationController *navigationController = [[VLORouteEditorNavigationController alloc] initWithRootViewController:editor];
    editor.delegate = self;
    
    [self cellEditorsHeaderDate:editor];
    
    [self presentViewController:navigationController animated:YES completion:^{
        [self coverClose];
    }];

    [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionWriteCell label:[VLOLog typeStringWithType:VLOLogTypeRoute] andValue:nil];
}

- (void)timelineMenuDidSelectTitleButton:(id)sender
{
    VLOQuoteEditorViewController *editor = [self.storyboard instantiateViewControllerWithIdentifier:VLOQuoteEditorStoryboardID];
    editor.travel = _travel;
    editor.delegate = self;
    
    [self cellEditorsHeaderDate:editor];
    
    editor.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:editor animated:NO completion:^{
        [self coverClose];
    }];

    [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionWriteCell label:[VLOLog typeStringWithType:VLOLogTypeTitle] andValue:nil];
}

- (void)timelineMenuDidSelectPhotoButton:(id)sender
{
    [self timelineMenuDidSelectPhotoButtonWithAnimated:YES];
}

- (void)timelineMenuDidSelectPhotoButtonWithAnimated:(BOOL)animated
{
    [_activityIndicator startAnimating];
    VLOPhotoLogEditorViewController *editor = [[VLOPhotoLogEditorViewController alloc] initWithTravel:_travel andType:VLOPhotoLogEditorTypeDefault andLastUpdatedDate:_tableViewController.lastDate];
    editor.delegate = self;
    
    [self cellEditorsHeaderDate:editor];
    
    VLOPhotoLogEditorNavigationController *navigation = [[VLOPhotoLogEditorNavigationController alloc] init];
    navigation.viewControllers = @[editor, editor.assetsPickerContainer];
    editor.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:navigation animated:animated completion:^{
        [_activityIndicator stopAnimating];
    }];

    [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionWriteCell label:[VLOLog typeStringWithType:VLOLogTypePhoto] andValue:nil];
}

- (void)timelineMenuDidSelectLocationButton:(id)sender
{
    [self timelineMenuDidSelectLocationButtonWithAnimated:YES];
}

- (void)timelineMenuDidSelectLocationButtonWithAnimated:(BOOL)animated
{
    VLOMapEditorViewController *editor = [[VLOMapEditorViewController alloc] initWithTravel:_travel withType:VLOMapEditorTypeDefault];
    editor.delegate = self;
    
    [self cellEditorsHeaderDate:editor];
    
    VLOMapEditorNavigationController *navigation = [[VLOMapEditorNavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:navigation animated:animated completion:^{
        [self coverClose];
    }];

    [VLOAnalyticsManager reportGAEventWithCategory:VLOCategoryTimeline action:VLOActionWriteCell label:[VLOLog typeStringWithType:VLOLogTypeMap] andValue:nil];
}

- (void)cellEditorsHeaderDate:(VLOCellEditorViewController *)editor
{
    VLOLog *addToBelowPivotLog = _tableViewController.addToBelowPivotLog;
    if (addToBelowPivotLog) {
        [editor setLastUpdatedDate:addToBelowPivotLog.date withTimezone:[addToBelowPivotLog.timezone getNSTimezone] forAddBelow:YES];
    }
    else if ([_tableViewController isOnWriting]) {
        [editor setLastUpdatedDate:_tableViewController.lastDate withTimezone:_tableViewController.lastTimeZone];
    }
    else {
        VLOLog *lastCell = (VLOLog *)[_tableViewController.logs lastObject];
        NSDate *lastCellsDate = lastCell.date;
        if ([[NSDate date] timeIntervalSince1970] - [lastCellsDate timeIntervalSince1970] > 3600 * 24 * 7) { // 1주일
            [editor setLastUpdatedDate:[lastCell date] withTimezone:[lastCell.timezone getNSTimezone]];
        } else {
            [editor setLastUpdatedDate:[NSDate date] withTimezone:[NSTimeZone systemTimeZone]];
        }
    }
}

- (void)timelineMenuDidClickExitButton:(id)sender
{
    [_tableView reloadData];
    [_tableViewController endOrderChangeModeWithIsChanged:NO];
}

#pragma mark - Text editor delegate

- (void)textEditor:(VLOTextEditorViewController *)textEditor didDoneWithTextLog:(VLOTextLog *)log
{
    [_tableViewController addLog:log];
}

#pragma mark - Map editor delegate

- (void)mapEditor:(VLOMapEditorViewController *)mapEditorViewController didDoneWithLog:(VLOMapLog *)log
{
    [_tableViewController addLog:log];
}

#pragma mark - Route editor delegate

- (void)routeEditor:(VLORouteEditorViewController *)routeEditor didFinishEditWithLog:(VLORouteLog *)log
{
    [_tableViewController addLog:log];
}

#pragma mark - Editor insertion delegate

- (void)quoteEditor:(VLOQuoteEditorViewController *)editor didFinishEditingWithLog:(VLOQuoteLog *)log
{
    [_tableViewController addLog:log];
}

- (void)photoLogEditor:(VLOPhotoLogEditorViewController *)editor didFinishEditingWithLog:(VLOPhotoLog *)log
{
    [_tableViewController addLog:log];
}

#pragma mark - Table view scrollDelegate

- (void)hideNavigationBar
{
    _scrollMovedOffset = 0.0;
    [_timelineNavigationBar hide];
    _isHidden = YES;
//    _searchFriendsToolTip.alpha = .0f;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showNavigationBar
{
    if (_tableViewController.isOrderChangeMode) {
        return;
    }
//    [UIView animateWithDuration:.5f animations:^{
//        _searchFriendsToolTip.alpha = 1.0f;
//    }];
    _scrollMovedOffset = 0.0;
    [_timelineNavigationBar show];
    _isHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)tableViewDidScroll:(VLOTimelineTableView *)tableView
{
    if (_isCoverOpen) {
        return;
    }
    CGPoint currentOffset = tableView.contentOffset;
    _scrollMovedOffset += currentOffset.y-_lastScrollContentOffset.y;

    if (tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height + tableView.contentInset.top - 100) {
        [self showNavigationBar];
    }
    else if (tableView.contentOffset.y <= 0) {
        [self showNavigationBar];
    }
    else if (_scrollMovedOffset < -50) {
        [self showNavigationBar];
    }
    else if (_scrollMovedOffset > 50 && tableView.contentOffset.y < tableView.contentSize.height - tableView.frame.size.height - 150) {
        [self hideNavigationBar];
    }
    
    _lastScrollContentOffset = currentOffset;
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSNumber *object = evaluatedObject;
        CGFloat y = object.floatValue;
        CGFloat contentOffsetY = tableView.contentOffset.y + tableView.contentInset.top + (tableView.frame.size.height * (tableView.contentOffset.y + tableView.frame.size.height) / tableView.contentSize.height);
        y = MAX(0, y);
        y = MIN(tableView.contentSize.height, y);
        if (y <= contentOffsetY) {
            return YES;
        }
        return NO;
    }];
    
    NSArray *filteredDayYOrigins = [_scrollIndicator.dayYOrigins filteredArrayUsingPredicate:predicate];
    NSInteger index = filteredDayYOrigins.count - 1;
    index = index < 0 ? 0 : index;
    
    [_scrollIndicator setCurrentIndex:MAX(0, index)];
    
    if (_scrollIndicator.dayLogs.count) {
        VLODayLog *dayLog = [_scrollIndicator.dayLogs objectAtIndex:MAX(0, index)];
        _scrollIndicator.dayLog = dayLog;
    }
}

- (void)tableView:(VLOTimelineTableView *)tableView didScrollOnTopWithY:(CGFloat)y
{
    CGFloat moveY = y;
    if ((_tableView.frame.origin.y >= _coverView.frame.size.height && moveY > 0) || _tableView.frame.origin.y > _coverView.frame.size.height) {
        [_coverView coverPageInteractionWithGetureYMove:moveY];
        [self setCoverViewWithY:(_coverView.imageView.frame.size.height-PARALLAX_MAX-_coverView.frame.size.height)/2.0f+_coverView.frame.size.height];
    }
    else {
        [self moveCoverViewWithY:moveY];
    }
}

- (void)tableViewDidEndScrollOnTop:(VLOTimelineTableView *)tableView
{
    if ([_coverView isCoverPageInteractedForClose]) {
        [self backToTravelListAtTimeline:self];
    }
    else {
        [_coverView coverPageInteractionEnd];
        [self coverViewMoveEnded];
    }
}

- (void)tableView:(VLOTimelineTableView *)tableView didScrolledY:(CGFloat)y
{
    if (_isCoverOpen) {
        return;
    }
}


#pragma mark - cell delegate

- (void)photoCell:(VLOTableViewPhotoCell *)cell didSelectPhotoAtIndex:(NSInteger)index ofPhotos:(NSArray *)photos
{
    if (!_tableViewController.canOpenDetailView) {
        return;
    }
    [self coverCloseWithComplete:^{
        [self hideNavigationBar];
        VLOPhotoDetailViewController *detailView = [[VLOPhotoDetailViewController alloc] initWithImageViews:cell.imageViewList onYPos:[_tableView convertRect:cell.frame toView:self.view].origin.y ofPhotos:photos andIndex:index];
        detailView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        detailView.userViewHidden = (_travel.users.count == 1);
        detailView.defaultUser = cell.log.user;
        detailView.photoLog = (VLOPhotoLog *)cell.log;
        detailView.isViewMode = _isViewMode;
        
        [self presentViewController:detailView animated:NO completion:^{
        }];
    }];
}

- (void)mapCellDidSelectMap:(VLOTableViewMapCell *)cell
{
    if (!_tableViewController.canOpenDetailView) {
        return;
    }
    [self coverCloseWithComplete:^{
        [self hideNavigationBar];
        VLOMapLog *mapLog = (VLOMapLog *)cell.log;
        VLOMapDetailViewController *detailView = [[VLOMapDetailViewController alloc] initWithMapLog:mapLog];
        detailView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailView];
        
        [self presentViewController:navigationController animated:YES completion:^{
        }];
    }];
}


#pragma mark - Cover view delegate

- (void)coverViewDidSelectBackButton:(VLOTimelineCoverView *)coverView
{
    [self backToTravelListAtTimeline:nil];
}

- (void)coverViewDidSelectMoreButton:(VLOTimelineCoverView *)coverView
{
    if (_isViewMode) {
        [self showShareActionSheet];
    } else {
        [self showStoryActionSheet];
    }
}

- (void)coverView:(VLOTimelineCoverView *)coverView didRecognizeLongPressGestureWithType:(VLOTimelineCoverPressedViewType)type
{
    if (!_isViewMode) {
        [self editCoverViewWithPressType:type isLongPress:YES];
    }
}

- (void)coverViewDidSelectFriendsDetailButton:(VLOTimelineCoverView *)coverView
{
    [self presentInviteFriendsView];
}

- (void)presentInviteFriendsView
{
    _isOpenView = YES;
    VLOFriendsListViewController *listController = [[VLOFriendsListViewController alloc] initWithTravel:_travel];
    listController.delegate = self;
    VLONavigationController *navigationViewController = [[VLONavigationController alloc] initWithRootViewController:listController];
    [navigationViewController setNavigationBarHidden:YES animated:NO];
    
    [self presentViewController:navigationViewController animated:YES completion:nil];
}


#pragma mark - Travel list add view controller delegate

- (void)travelListAddViewController:(VLOTravelListAddViewController *)controller didFinishModifyWithTravel:(VLOTravel *)travel
{
    [VLOAnalyticsManager reportGAScreenWithName:kVLOScreenNameTimeline];
    
    [_travel copyFromTravel:travel];
    
    _coverView.travel = _travel;
    
    [_travelListViewController modifiedTravel:_travel];
    [_tableViewController initTimeline];
}

- (void)travelListAddViewControllerDidCancel:(VLOTravelListAddViewController *)controller
{
    [VLOAnalyticsManager reportGAScreenWithName:kVLOScreenNameTimeline];
    
    [_tableViewController syncTimeline];
}

- (void)didDoneEditting:(NSNotification *)notification
{
    NSString *message = [notification.userInfo objectForKey:@"message"]; // for title editor
    if ([message  isEqual: @"editDone"]){
        if(_isHidden){
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            [self setNeedsStatusBarAppearanceUpdate];
            _isHidden = YES;
        }
    }
}

- (void)scrollStop:menu
{
    [_tableView setContentOffset:_tableView.contentOffset animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Search friends view controller delegate

- (void)searchFriendsViewController:(VLOSearchFriendsViewController *)controller didSelectUser:(VLOUser *)user
{
    [VLOLocalStorage setUser:user];
    [VLOLocalStorage updateTravel:_travel];
}


#pragma mark - gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark - table footer delegate

- (void)tableFooterSelectedTag:(NSString *)tag
{
    VLODiscoverTravelListViewController *travelListViewController = [[VLODiscoverTravelListViewController alloc] init];
    VLOInspiration *inspiration = [[VLOInspiration alloc] init];
    inspiration.tag = tag;
    inspiration.title = [NSString stringWithFormat:@"#%@", tag];
    travelListViewController.inspiration = inspiration;
    
    [self.navigationController pushViewController:travelListViewController animated:YES];
    _isOpenView = YES;
}

- (void)showTravelListWithUser:(VLOUser *)user
{
    if (_isOpenView) {
        return;
    }
    UIStoryboard *storyboard = [VLOUtilities mainStoryboard];
    VLOTravelListViewController *userHomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"root"];
    userHomeViewController.user = user;
    
    [self.navigationController pushViewController:userHomeViewController animated:YES];
    _isOpenView = YES;
}


#pragma mark - friends list view delegate

- (void)friendsListViewControllerDidClosed:(VLOFriendsListViewController *)viewController
{
    [self autoSync];
    [_travelListViewController travelListSync];
}

@end
