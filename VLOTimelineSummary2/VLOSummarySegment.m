//
//  VLOSummarySegment.m
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummarySegment.h"

@interface VLOSummarySegment ()

@property (nonatomic, strong) UIImageView *segmentImageView;
@property (nonatomic, strong) UIImageView *contentImageView;

@end

@implementation VLOSummarySegment

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker {
    self = [super init];
    _fromMarker = fromMarker;
    _toMarker = toMarker;
    _curved = NO;
    _leftToRight = YES;
    _hasLineContent = NO;
    return self;
}

- (void) setSegmentImage:(NSString *)segmentImageName {
    CGFloat segmentHeight = 10;
    CGFloat segmentLeft = _fromMarker.x;
    CGFloat segmentTop = _fromMarker.y + segmentHeight/2;
    CGFloat segmentLength = fabs(_toMarker.x - _fromMarker.x);
    
    UIImage *segmentImage= [UIImage imageNamed:segmentImageName ];
    _segmentImageView = [[UIImageView alloc] initWithImage:segmentImage];
    _segmentImageView.frame = CGRectMake(segmentLeft, segmentTop, segmentLength, segmentHeight);
    
}

- (void) setSegmentContentImage:(NSString *)contentImageName {
    _hasLineContent = YES;
    
    CGFloat contentSize = 30;
    CGFloat contentLeft = (_fromMarker.x + _toMarker.x)/2 - contentSize/2;
    CGFloat contentTop = _fromMarker.y - contentSize/2;
    
    UIImage *contentImage = [UIImage imageNamed:contentImageName];
    _contentImageView = [[UIImageView alloc] initWithImage:contentImage];
    _contentImageView.frame = CGRectMake(contentLeft, contentTop, contentSize, contentSize);
    
}

- (UIView *) getDrawableView {

    CGFloat drawableTop, drawableHeight;
    CGFloat drawableLength = fabs(_toMarker.x - _fromMarker.x);
    
    if (_hasLineContent) {
        drawableTop = MAX(_segmentImageView.frame.origin.y, _contentImageView.frame.origin.y);
        drawableHeight = MAX(_segmentImageView.frame.size.height, _contentImageView.frame.size.height);
    } else {
        drawableTop = _segmentImageView.frame.origin.y;
        drawableHeight = _segmentImageView.frame.size.height;
    }
    
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_fromMarker.x, drawableTop, drawableLength, drawableHeight)];
    [drawableView addSubview:_segmentImageView];
    [drawableView addSubview:_contentImageView];
    
    return drawableView;
}

@end
