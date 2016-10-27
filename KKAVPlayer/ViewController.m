//
//  ViewController.m
//  KKAVPlayer
//
//  Created by kkwalle on 16/10/25.
//  Copyright © 2016年 kkwalle. All rights reserved.
//

#import "ViewController.h"
#import "KKAVPlayer.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, KKAVPlayerDelegate>
@property (nonatomic, strong) KKAVPlayer *playerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) UIView *headerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    self.headerView = headerView;
    
    self.playerView = [[KKAVPlayer alloc] initWithFrame:headerView.bounds];
    self.playerView.delegate = self;
    self.playerView.contentUrlString = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";
    [self.headerView addSubview:self.playerView];
    self.tableView.tableHeaderView = self.headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"= = = %ld =",indexPath.row];
    return cell;
}

#pragma mark - //
- (void)kkAVPlayerShouldFullScreen:(BOOL)shouldFullScreen {
    if (shouldFullScreen) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.playerView setTransform:CGAffineTransformIdentity];
            self.playerView.frame = self.originFrame;
            [self.headerView addSubview:self.playerView];
        } completion:^(BOOL finished) {
            self.playerView.isFullscreenMode = NO;
        }];
    } else {
        self.originFrame = self.playerView.frame;
        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
        [UIView animateWithDuration:0.3f animations:^{
            self.playerView.frame = frame;
            [self.playerView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            [[UIApplication sharedApplication].keyWindow addSubview:self.playerView];
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.playerView];
        } completion:^(BOOL finished) {
            self.playerView.isFullscreenMode = YES;
        }];
    }
}

@end
