//
//  VLOTimelineTableView.m
//  Volo
//
//  Created by bamsae on 2014. 12. 31..
//  Copyright (c) 2014년 SK Planet. All rights reserved.
//

#import "VLOTimelineTableView.h"
#import "VLOTableViewRouteCell.h"
#import "VLOTimelineSummary.h"
#import "VLOUtilities.h"

@interface VLOTimelineTableView () <UIGestureRecognizerDelegate>
{
    CGFloat lastY;
}
@end

@implementation VLOTimelineTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isScrollOnTop = YES;
        UIPanGestureRecognizer *tableGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tableGestureAction:)];
        [tableGesture setCancelsTouchesInView:NO];
        tableGesture.delegate = self;
        
        [self addGestureRecognizer:tableGesture];
        
        self.canCancelContentTouches = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
        
        _summaryView = [[UIView alloc] initWithFrame:CGRectMake(0, -SUMMARY_HEIGHT, [VLOUtilities screenWidth], SUMMARY_HEIGHT)];
        [self addSubview:_summaryView];
        
        [self registerNibs];
    }
    
    return self;
}

- (void)registerNibs
{
    [self registerClass:[VLOTableViewRouteCell class] forCellReuseIdentifier:@"routeCell"];
    [self registerNib:[UINib nibWithNibName:@"VLOTableViewDayCell" bundle:nil] forCellReuseIdentifier:@"dayCell"];
    [self registerNib:[UINib nibWithNibName:@"VLOTableViewQuoteCell" bundle:nil] forCellReuseIdentifier:@"quoteCell"];
    [self registerNib:[UINib nibWithNibName:@"VLOTableViewTextCell" bundle:nil] forCellReuseIdentifier:@"textCell"];
    [self registerNib:[UINib nibWithNibName:@"VLOTableViewMapCell" bundle:nil] forCellReuseIdentifier:@"mapCell"];
    [self registerNib:[UINib nibWithNibName:@"VLOTableViewPhotoCell" bundle:nil] forCellReuseIdentifier:@"photoCell"];
    
    // register photo cells by for-loop
    for (NSInteger i = 1; i < 11; i ++) {
        NSString *tableCellName = [NSString stringWithFormat:@"VLOTableViewPhoto%ldCell", i];
        NSString *cellIdentifierName = [NSString stringWithFormat:@"photo%ldCell", i];
        [self registerNib:[UINib nibWithNibName:tableCellName bundle:nil] forCellReuseIdentifier:cellIdentifierName];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)tableGestureAction:(UIPanGestureRecognizer *)gesture
{
    CGFloat yPoint = [gesture locationInView:self.superview].y;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.contentOffset.y <= -self.contentInset.top) {
            _isScrollOnTop = YES;
        }
        else {
            _isScrollOnTop = NO;
        }
        lastY = yPoint;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged && _isScrollOnTop) {
        if ([self.scrollTopDelegate respondsToSelector:@selector(tableView:didScrollOnTopWithY:)]) {
            [self.scrollTopDelegate tableView:self didScrollOnTopWithY:yPoint - lastY];
        }
        if ([self.scrollTopDelegate respondsToSelector:@selector(tableView:didScrolledY:)]) {
            [self.scrollTopDelegate tableView:self didScrolledY:yPoint - lastY];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        if ([self.scrollTopDelegate respondsToSelector:@selector(tableView:didScrolledY:)]) {
            [self.scrollTopDelegate tableView:self didScrolledY:yPoint - lastY];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded && _isScrollOnTop) {
        if ([self.scrollTopDelegate respondsToSelector:@selector(tableViewDidEndScrollOnTop:)]) {
            [self.scrollTopDelegate tableViewDidEndScrollOnTop:self];
        }
        [self.scrollTopDelegate tableView:self didScrolledY:yPoint - lastY];
    }
    lastY = yPoint;
}


#pragma mark - gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isMemberOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
