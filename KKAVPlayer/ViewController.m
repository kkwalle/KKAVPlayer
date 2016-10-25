//
//  ViewController.m
//  KKAVPlayer
//
//  Created by kkwalle on 16/10/25.
//  Copyright © 2016年 kkwalle. All rights reserved.
//

#import "ViewController.h"
#import "KKAVPlayer.h"

@interface ViewController ()
@property (nonatomic, strong) KKAVPlayer *playerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerView = [[KKAVPlayer alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
    self.playerView.contentUrlString = @"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA";
    [self.view addSubview:self.playerView];
    
}


@end
