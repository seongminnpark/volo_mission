//
//  VLOTimelineCoverView.m
//  Volo
//
//  Created by 1001246 on 2014. 12. 30..
//  Copyright (c) 2014년 SK Planet. All rights reserved.
//

#import "VLOTimelineCoverView.h"
#import "VLOBlurredImageView.h"
#import "VLOProfileImageCell.h"
#import "VLOFriendsView.h"

#import "UIColor+VLOExtension.h"
#import "NSDate+VLOExtension.h"
#import "UIFont+VLOExtension.h"
#import "UIButton+VLOExtension.h"
#import "NSString+VLOExtension.h"
#import "VLOUtilities.h"

#import "VLOLocalStorage.h"

#import "VLOUser.h"
#import "VLOTravel.h"
#import "VLOPhoto.h"
#import "VLOTimezone.h"
#import "VLOTravelListCell.h"

#import <Masonry/Masonry.h>
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const VLOTimelineCoverToggleAnimationKey = @"ToggleButtonFlashAnimation";

@interface VLOTimelineCoverView () <VLOFriendsViewDelegate>

@property (strong, nonatomic) VLOFriendsView *friendsView;
@property (nonatomic) VLOFrinedsViewType type;

@property (nonatomic) CGFloat gestureMove;

@end

@implementation VLOTimelineCoverView

- (instancetype)initWithFrame:(CGRect)frame andIsViewMode:(BOOL)isViewMode
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _isViewMode = isViewMode;
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor whiteColor];
    // init friendsView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendsViewDidSelectFriendsDetailButton:)];
    _type = VLOFriendsViewTypeAddMoreButton;
    if (_isViewMode) {
        _type = VLOFriendsViewTypeCommon;
    }
    _friendsView = [[VLOFriendsView alloc] initWithFriends:_friends andType:_type];
    _friendsView.delegate = self;
    [_friendsView addGestureRecognizer:tap];
    
    _beginTime = [[NSDate date] timeIntervalSince1970];
    _isFirstOpen = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recognizedLogPressGesture:)];
    longPress.minimumPressDuration = .5f;
    [self addGestureRecognizer:longPress];
    
    _titleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 1)];
    _titleSeparator.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.7f];
    [self addSubview:_titleSeparator];
    if ([VLOUtilities isIphone4S]) {
        _titleSeparator.hidden = YES;
    }
    _titleTextView = [[UITextView alloc] init];
    _titleTextView.scrollEnabled = NO;
    _titleTextView.textAlignment = NSTextAlignmentCenter;
    _titleTextView.textColor = [UIColor whiteColor];
    _titleTextView.backgroundColor = [UIColor clearColor];
    _titleTextView.contentInset = UIEdgeInsetsZero;
    _titleTextView.textContainerInset = UIEdgeInsetsZero;
    _titleTextView.scrollEnabled = NO;
    _titleTextView.editable = NO;
    _titleTextView.selectable = NO;
    if ([VLOUtilities isIphone4S]) {
        _titleSeparator.hidden = YES;
        _titleTextView.font = [UIFont museoSans700WithSize:19.0f];
    } else {
        _titleTextView.font = [UIFont museoSans700WithSize:30.0f];
    }
    
    _topContainerView = [[UIView alloc] init];
    _topContainerView.backgroundColor = [UIColor clearColor];
    
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    _dateLabel.font = [UIFont museoSans500WithRatioSize:11.0f];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake(-PARALLAX_MAX/2.0f, -PARALLAX_MAX/2.0f, [VLOUtilities screenWidth] + PARALLAX_MAX, [VLOUtilities screenWidth] + PARALLAX_MAX);
    
    _overlay = [CAGradientLayer layer];
    _overlay.frame = CGRectMake(0, 0, [VLOUtilities screenWidth]*1.5f, [VLOUtilities screenHeight]);
    _overlay.colors = @[(id)[[UIColor colorWithHexString:@"#454545" alpha:0.5f] CGColor],
                        (id)[[UIColor colorWithHexString:@"#454545" alpha:0.5f] CGColor]];
    _imageView.backgroundColor = [UIColor clearColor];
    [_imageView.layer addSublayer:_overlay];
    _imageView.alpha = .3f;

    _backButton = [[UIButton alloc] init];
    [_backButton setImage:[UIImage imageNamed:@"TimelineCoverBackButton"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backToTravelListAtCoverView:) forControlEvents:UIControlEventTouchUpInside];
    _backButton.hitEdgeInsets = UIEdgeInsetsMake(-50, -50, -50, -50);
    
    _editButton = [[UIButton alloc] init];
    [_editButton setImage:[UIImage imageNamed:@"TimelineCoverMoreButton"] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    _editButton.hitEdgeInsets = UIEdgeInsetsMake(-50, -10, -50, -50);
    _editButton.hidden = _isViewMode;
    
    _shareButton = [[UIButton alloc] init];
    [_shareButton setImage:[[UIImage imageNamed:@"TimelineShareButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _shareButton.tintColor = [UIColor whiteColor];
    [_shareButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    _shareButton.hitEdgeInsets = UIEdgeInsetsMake(-50, -10, -50, -50);
    _shareButton.hidden = !_isViewMode;
    
    
    //add
    _summaryView = [[UIView alloc] init];
    //add
    
    [self addSubview:_topContainerView];
    [_topContainerView addSubview:_imageView];
    [_topContainerView addSubview:_dateLabel];
    [_topContainerView addSubview:_titleSeparator];
    [_topContainerView addSubview:_titleTextView];
    [self insertSubview:_backButton aboveSubview:_topContainerView];
    [self insertSubview:_editButton aboveSubview:_topContainerView];
    [self insertSubview:_shareButton aboveSubview:_topContainerView];
    [self addSubview:_friendsView];
    [self addSubview:_summaryView];
    [self makeAutoLayoutConstraints];
    
}

- (void)coverPageAppear
{
    _imageView.frame = CGRectMake(-PARALLAX_MAX/2.0f, -PARALLAX_MAX/2.0f, self.bounds.size.width + PARALLAX_MAX, self.bounds.size.height + PARALLAX_MAX);
}

- (double)checkTimeInCoverViewWithPresentTime:(CGFloat)presentTime andWhere:(NSString *)where
{
    _isFirstOpen = NO;
    double compare;
    
    compare = presentTime - _beginTime;
    
    return compare;
}

- (void)recognizedLogPressGesture:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIView *view = gesture.view;
        CGPoint loc = [gesture locationInView:view];
        UIView *subview = [view hitTest:loc withEvent:nil];
        
        VLOTimelineCoverPressedViewType type = VLOTimelineCoverPressedViewTypeDefault;
        if ([subview isEqual:_dateLabel]) {
            type = VLOTimelineCoverPressedViewTypeDate;
        } else if ([subview isEqual:_imageView]) {
            type = VLOTimelineCoverPressedViewTypeImageView;
        }
        
        if ([_delegate respondsToSelector:@selector(coverView:didRecognizeLongPressGestureWithType:)]) {
            [_delegate coverView:self didRecognizeLongPressGestureWithType:type];
        }
    }
}

- (void)backToTravelListAtCoverView:(UIButton *)backButton
{
    if(_isFirstOpen){
        [self checkTimeInCoverViewWithPresentTime:[[NSDate date] timeIntervalSince1970] andWhere:@"Back"];
        _isFirstOpen = NO;
    }
    if ([_delegate respondsToSelector:@selector(coverViewDidSelectBackButton:)]) {
        [_delegate coverViewDidSelectBackButton:self];
    }
}

- (void)more:(UIButton *)moreButton
{
    if(_isFirstOpen){
        [self checkTimeInCoverViewWithPresentTime:[[NSDate date] timeIntervalSince1970] andWhere:@"More"];
        _isFirstOpen = NO;
    }
    if ([_delegate respondsToSelector:@selector(coverViewDidSelectMoreButton:)]) {
        [_delegate coverViewDidSelectMoreButton:self];
    }
}

- (void)makeAutoLayoutConstraints
{
    [_topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0.0f);
        make.left.equalTo(@0.0f);
        make.right.equalTo(@0.0f);
        make.height.equalTo(_topContainerView.mas_width);
    }];
    
    if (_travel && !_travel.hasDate && ![_travel isWalkthrough]) {
        [_titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).with.offset(-_titleTextView.frame.size.height/2.0f);
            make.width.lessThanOrEqualTo(@(self.frame.size.width-30));
        }];
    }
    else {
        [_titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(_topContainerView).with.offset(-39.5 * [VLOUtilities screenRatio]);
            make.width.lessThanOrEqualTo(@(self.frame.size.width-30));
        }];
    }
    
    [_titleSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@20.0f);
        make.height.equalTo(@1.0f);
        make.top.equalTo(_titleTextView.mas_bottom).with.offset(13.5f);
    }];
    
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_titleTextView.mas_bottom).with.offset(31.5f);
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@13.0f);
        make.top.equalTo(@20.5f);
    }];
    
    [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13.0f));
        make.centerY.equalTo(_backButton);
    }];
    
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13.0f));
        make.centerY.equalTo(_backButton);
    }];
    
    NSInteger line = 1;
    
    CGFloat cellSizeRatio = 27.0f * [VLOUtilities screenRatio];
    [_friendsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-22.5f * [VLOUtilities screenRatio]);
        make.height.equalTo(@((_friends.count == 0) ? 0.0f : (cellSizeRatio * line + 7.5f * [VLOUtilities screenRatio] * (line-1))));
        make.width.equalTo(@(cellSizeRatio * MIN(_friends.count + _type, 5) + 7.5f * [VLOUtilities screenRatio] * (MIN(_friends.count + _type, 5)-1)));
        make.centerX.equalTo(self);
    }];
    
    _summaryView.backgroundColor = [UIColor redColor];
    // add
    [_summaryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleTextView.mas_left);
        make.right.equalTo(_titleTextView.mas_right);
        
        make.top.equalTo(_dateLabel.mas_bottom);
        make.bottom.equalTo(_friendsView.mas_top);
    }];
    // add
}

- (void)setTravel:(VLOTravel *)travel
{
    _travel = travel;
    _friends = _travel.users;
    [self reloadFaceViews];
    
    _titleTextView.text = _travel.title;
    
    NSTimeZone *travelTimezone = [_travel.timezone getNSTimezone];
    if (_travel.startDate && _travel.endDate) {
        // 시작하는 날과 끝나는 날의 차이를 dateComponents에 저장
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:_travel.startDate toDate:_travel.endDate options:0];
        
        if (![dateComponents day])  // 차이가 0이면
            _dateLabel.text = [_travel.startDate localeDateStringWithTimeZone:travelTimezone];
        else
            _dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [_travel.startDate localeDateStringWithTimeZone:travelTimezone], [_travel.endDate localeDateStringWithTimeZone:travelTimezone]];
    } else if (_travel.startDate)
        _dateLabel.text = [_travel.startDate localeDateStringWithTimeZone:travelTimezone];
    else if (_travel.endDate)
        _dateLabel.text = [NSString stringWithFormat:@"~ %@", [_travel.endDate localeDateStringWithTimeZone:travelTimezone]];
    else
        _dateLabel.text = @"";
    
    CGSize coverImageSize = CGSizeMake([VLOUtilities screenWidth] + PARALLAX_MAX, [VLOUtilities screenWidth] + PARALLAX_MAX);
    _overlay.hidden = NO;
    if ([_travel isWalkthrough]) {
        _imageView.alpha = 1.0f;
        _imageView.image = [UIImage imageNamed:@"TravelListWalkthroughCoverImage"];
        _overlay.hidden = YES;
        _dateLabel.hidden = NO;
        _dateLabel.text = @"by VOLO";
        _titleTextView.text = @"WALKTHROUGH";
    }
    else if (_travel.coverImage.imagePath) {
        _imageView.alpha = 1.0f;
        if ([_travel.coverImage isCachedThumbnailImageWithSize:coverImageSize]) {
            _imageView.image = [_travel.coverImage thumbnailImageWithSize:coverImageSize andUseCache:YES cacheLevel:VLO_PHOTO_CACHELEVEL_HIGH];
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [_travel.coverImage thumbnailImageWithSize:coverImageSize andUseCache:YES cacheLevel:VLO_PHOTO_CACHELEVEL_HIGH];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imageView.image = image;
                });
            });
        }
    }
    else if (_travel.coverImage.serverId){
        NSString *serverUrlString = [[NSString stringWithFormat:@"%@/%@", _travel.coverImage.serverUrl, _travel.coverImage.serverPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (_travel.isViewMode) {
            serverUrlString = [serverUrlString imageURLWithBounds:_imageView.bounds];
        }
        NSURL *serverUrl = [NSURL URLWithString:serverUrlString];
        [[SDWebImageManager sharedManager] downloadImageWithURL:serverUrl options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!error) {
                [_travel.coverImage savePhoto:image isViewMode:_travel.isViewMode isAsync:YES success:^{
                    if (!_travel.isViewMode) {
                        [VLOLocalStorage updatePhoto:_travel.coverImage];
                        [VLOLocalStorage updateTravel:_travel];
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *image = [_travel.coverImage thumbnailImageWithSize:coverImageSize andUseCache:YES cacheLevel:VLO_PHOTO_CACHELEVEL_HIGH];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIView animateWithDuration:.3f animations:^{
                                _imageView.alpha = 1.0f;
                            }];
                            _imageView.image = image;
                        });
                    });
                    
                } failure:^{
                }];
            }
            
        }];
    }
    else {
        _imageView.image = nil;
    }
    
    [_titleTextView sizeToFit];
    
    if (!_travel.hasDate && ![_travel isWalkthrough]) {
        _titleSeparator.hidden = YES;
        _dateLabel.hidden = YES;
    }
    else {
        _titleSeparator.hidden = NO;
        _dateLabel.hidden = NO;
    }
    
    if (_travel.privacyType == VLOTravelPrivacyPrivateType) {
        [_backButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@30.5f);
        }];
    } else {
        [_backButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@20.5f);
        }];
    }
}

- (void)updateConstraints
{
    _titleTextView.text = _travel.title;
    
    if ([_travel isWalkthrough]) {
        _titleTextView.text = @"WALKTHROUGH";
    }
    
    [self resizeTextViewHeight];
    
    
    [_topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0.0f);
        make.left.equalTo(@0.0f);
        make.right.equalTo(@0.0f);
        make.height.equalTo(_topContainerView.mas_width);
    }];
    
    if (!_travel.hasDate && ![_travel isWalkthrough]) {
        [_titleTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).with.offset(-_titleTextView.frame.size.height/2.0f);
            make.width.lessThanOrEqualTo(@(self.frame.size.width-30));
        }];
    }
    else {
        [_titleTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(_topContainerView).with.offset(-39.5 * [VLOUtilities screenRatio]);
            make.width.lessThanOrEqualTo(@(self.frame.size.width-30));
        }];
    }
    
    [_titleSeparator mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@20.0f);
        make.height.equalTo(@1.0f);
        make.top.equalTo(_titleTextView.mas_bottom).with.offset(13.5f * [VLOUtilities screenRatio]);
    }];
    
    [_dateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_titleTextView.mas_bottom).with.offset(31.5f * [VLOUtilities screenRatio]);
    }];
    
    [super updateConstraints];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self resizeTextViewHeight];
}

- (void)resizeTextViewHeight
{
    int pre_defined_font_size = 30;
    _titleTextView.font = [UIFont museoSans700WithSize:30.0f];
    
    CGSize titleSize = [_titleTextView sizeThatFits:CGSizeMake(self.frame.size.width-30.0f, CGFLOAT_MAX)];
    if ([_titleTextView sizeThatFits:CGSizeMake(self.frame.size.width-30.0f, CGFLOAT_MAX)].height > 72.0f) {
        int adjust_font_size = 1;
        while ([_titleTextView sizeThatFits:CGSizeMake(self.frame.size.width-30.0f, CGFLOAT_MAX)].height > 72.0f) {
            _titleTextView.font = [UIFont ralewayExtraBoldWithSize:pre_defined_font_size-adjust_font_size];
            adjust_font_size++;
        }
    }
    _titleTextView.frame = CGRectMake(_titleTextView.frame.origin.x, _titleTextView.frame.origin.y, titleSize.width, titleSize.height);
}

- (void)reloadFaceViews
{
    if ([_travel isWalkthrough]) {
        return;
    }
    
    [_friendsView.collectionView reloadData];
    _friendsView.friends = _friends;
    NSInteger line = [_friendsView calculateLineWithFriends:_friends];
    
    CGFloat cellSize = 27.0f * [VLOUtilities screenRatio];
    [_friendsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-22.5f * [VLOUtilities screenRatio]);
        make.height.equalTo(@((_friends.count == 0) ? 0.0f : (cellSize * line + 7.5f * [VLOUtilities screenRatio] * (line-1))));
        make.width.equalTo(@(cellSize * MIN(_friends.count + _type, 5) + 7.5f * [VLOUtilities screenRatio] * ( MIN(_friends.count + _type, 5) -1 ) ));
        make.centerX.equalTo(self);
    }];
}


#pragma mark - FriendsViewDelegate

- (void)friendsViewDidSelectFriendsDetailButton:(VLOFriendsView *)friendsView
{
    if ([_delegate respondsToSelector:@selector(coverViewDidSelectFriendsDetailButton:)]) {
        [_delegate coverViewDidSelectFriendsDetailButton:self];
    }
}

#pragma mark - gesture interaction

- (void)coverPageInteractionWithGetureYMove:(CGFloat)yMove
{
    _gestureMove += yMove;
    if (_gestureMove < 0) {
        _gestureMove = 0;
    }
    
    CGFloat sizeMagnification = sqrt(_gestureMove/2)/60+1;
    CGFloat originSize = self.frame.size.width + PARALLAX_MAX;
    _imageView.frame = CGRectMake(-(originSize*sizeMagnification-self.frame.size.width)/2.0f, -(originSize*sizeMagnification-self.frame.size.width)/2.0f, originSize*sizeMagnification, originSize*sizeMagnification);
    
    CGFloat viewAlpha = 1.0f-(_gestureMove/300.0f);
    _backButton.alpha = viewAlpha;
    _editButton.alpha = viewAlpha;
    _titleTextView.alpha = viewAlpha;
    _titleSeparator.alpha = viewAlpha;
    _dateLabel.alpha = viewAlpha;
    _friendsView.alpha = viewAlpha;
    _summaryView.alpha = viewAlpha;
}

- (void)coverPageInteractionEnd
{
    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        _imageView.frame = CGRectMake(-PARALLAX_MAX/2.0f, -PARALLAX_MAX/2.0f, self.bounds.size.width + PARALLAX_MAX, self.bounds.size.height + PARALLAX_MAX);
        _backButton.alpha = 1.0f;
        _editButton.alpha = 1.0f;
        _titleTextView.alpha = 1.0f;
        _titleSeparator.alpha = 1.0f;
        _dateLabel.alpha = 1.0f;
        _friendsView.alpha = 1.0f;
        _summaryView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        _gestureMove = 0.0f;
    }];
}

- (BOOL)isCoverPageInteractedForClose
{
    if (_gestureMove > 300) {
        return YES;
    }
    return NO;
}

@end
