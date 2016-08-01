//
//  ViewController.m
//  SummaryTest
//
//  Created by Seongmin on 8/1/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UIView *summaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:summaryView];
    
    VLOTimelineSummary *summary =
        [[VLOTimelineSummary alloc] initWithLogs:[NSArray array] andView:summaryView];
    
    [summary drawSummary];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
