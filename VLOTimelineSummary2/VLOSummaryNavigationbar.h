//
//  VLOSummaryNavigationbar.h
//  Volo
//
//  Created by M on 2016. 8. 8..
//  Copyright © 2016년 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VLOSummaryNavigationbar;

@protocol VLOSummaryNavigationbarDelegate <NSObject>

-(void)navigationbarDidSelectBackButton:(VLOSummaryNavigationbar *)bar;
-(void)navigationbarDidSelectShareButton:(VLOSummaryNavigationbar *)bar;

@end

@interface VLOSummaryNavigationbar : UIView

@property (strong,nonatomic) UIButton *backBtn;
@property (strong,nonatomic) UIButton *shareBtn;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UIView *contentView;
@property (weak, nonatomic) id<VLOSummaryNavigationbarDelegate> delegate;

-(id)initSummaryNavigationbar;

@end