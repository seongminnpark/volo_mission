//
//  VLOSummaryNavigationbar.m
//  Volo
//
//  Created by M on 2016. 8. 8..
//  Copyright © 2016년 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>

#import "VLOSummaryNavigationbar.h"
//#import "UIButton+VLOExtension.h"
#import "UIColor+VLOExtension.h"
#import "VLOUtilities.h"



@implementation VLOSummaryNavigationbar

-(id) initSummaryNavigationbar {
    self = [super init];
    
    if(self) {
        
        self.backgroundColor = [UIColor colorWithHexString:@"35babc"];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedString(@"showsummary_title", ).uppercaseString;
        _titleLabel.textColor = [UIColor whiteColor];
        
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"TimelineBackButton"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];



        _shareBtn = [[UIButton alloc] init];
        [_shareBtn setImage:[UIImage imageNamed:@"timelineCellShareButton"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(pressShare:) forControlEvents:UIControlEventTouchUpInside];


        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        
        [_contentView addSubview:_titleLabel];
        [_contentView addSubview:_backBtn];
        [_contentView addSubview:_shareBtn];
        
        [self addSubview:_contentView];
        
        [self makeAutoLayoutConstraints];
    }
    
    
    return self;
}

- (void)makeAutoLayoutConstraints
{
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(@.0f);
        make.height.equalTo(@44.0f);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_contentView);
    }];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@13.5f);
        make.bottom.equalTo(@(-1.5f));
        make.height.equalTo(@44.0f);
    }];

    
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13.5f));
        make.bottom.equalTo(@(-.5f));
        make.height.equalTo(@44.0f);
    }];
   
}
         

#pragma - events

-(void)pressBack:(id)sender {
    if([_delegate respondsToSelector:@selector(navigationbarDidSelectBackButton:)]) {
        [_delegate navigationbarDidSelectBackButton:self];
    }
}

-(void)pressShare:(id)sender {
    if([_delegate respondsToSelector:@selector(navigationbarDidSelectShareButton:)]) {
        [_delegate navigationbarDidSelectShareButton:self];
        
        NSLog(@"press share\n");
    }
}
@end