//
//  VLOTimelineTableView.h
//  Volo
//
//  Created by bamsae on 2014. 12. 31..
//  Copyright (c) 2014년 SK Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VLOTimelineTableView;

@protocol VLOTimelineTableViewDelegate <NSObject>

@required
- (void)tableView:(VLOTimelineTableView *)tableView didScrollOnTopWithY:(CGFloat)y;
- (void)tableViewDidEndScrollOnTop:(VLOTimelineTableView *)tableView;
- (void)tableView:(VLOTimelineTableView *)tableView didScrolledY:(CGFloat)y;
- (void)tableViewDidScroll:(VLOTimelineTableView *)tableView;

@end

@interface VLOTimelineTableView : UITableView

@property (nonatomic, weak) id <VLOTimelineTableViewDelegate> scrollTopDelegate;
@property (nonatomic) BOOL isScrollOnTop;
@property (nonatomic, strong) UIView *summaryView;

@end