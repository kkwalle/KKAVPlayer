//
//  ViewController.m
//  KKAVPlayer
//
//  Created by kkwalle on 16/10/25.
//  Copyright © 2016年 kkwalle. All rights reserved.
//

#import "ViewController.h"
#import "KKAVPlayer.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KKAVPlayer *playerView;
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
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    self.tableView.tableHeaderView = self.headerView;
    
    self.playerView = [[KKAVPlayer alloc] initWithContainerView:self.headerView autoPlay:YES contentUrl:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"= = = %ld =",indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect screenRect = [self.playerView.containerView convertRect:self.playerView.containerView.bounds toView:[UIApplication sharedApplication].keyWindow];
    NSLog(@"%@==", NSStringFromCGRect(screenRect));
    if (screenRect.origin.y <= -screenRect.size.height) {
        [self.playerView pause];
    }
}

@end
