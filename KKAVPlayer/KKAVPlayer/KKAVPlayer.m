//
//  KKAVPlayer.m
//  KKAVPlayer
//
//  Created by kkwalle on 16/10/25.
//  Copyright © 2016年 kkwalle. All rights reserved.
//

#import "KKAVPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPlayerViewController.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>

@interface KKAVPlayer()
//@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerViewController *playerC;
@property (nonatomic, strong) AVPlayerItem *playerItem;
//自定义 UI 控件
@property (nonatomic, strong) UIView *bottomBar;
//playButton
@property (nonatomic, strong) UIButton *stateButton;
@property (nonatomic, strong) UILabel *progressTimeLabel;
//videoProgressView
@property (nonatomic, strong) UIProgressView *videoProgress;
//slider
@property (nonatomic, strong) UISlider *videoSlider;
//timeLabel
@property (nonatomic, strong) UILabel *totalTimeLabel;
//fullScreenButton
@property (nonatomic, strong) UIButton *fullScreenButton;

//控制变量
@property (nonatomic, copy) NSString *totalTime;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic ,strong) id playbackTimeObserver;
@property (nonatomic, assign) BOOL played;
@property (nonatomic, assign) BOOL showBottomBar;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) BOOL isFullscreenMode;

//容器,url,
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, copy) NSString *contentUrlString;
@property (nonatomic, assign) BOOL shouldAutoPlay;
@end

@implementation KKAVPlayer
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

/////////////////// 初始化, 自定义 UI ///////////////////////

- (instancetype)initWithContainerView:(UIView *)containerView autoPlay:(BOOL)autoPlay contentUrl:(NSString *)urlString {
    self = [super initWithFrame:containerView.bounds];
    if (self) {
        //initSubViews
        [self initSubViews];
        //设置容器, url
        self.containerView = containerView;
        [self.containerView addSubview:self];
        self.shouldAutoPlay = autoPlay;
        self.contentUrlString = urlString;
    }
    return self;
}

//添加子控件
- (void)initSubViews {
    //base
    self.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self addGestureRecognizer:tap];
    self.isFullscreenMode = NO;
    //bottomBar
    self.bottomBar = [[UIView alloc] init];
    [self addSubview:self.bottomBar];
    self.showBottomBar = YES;
    //playButton
    self.stateButton = [[UIButton alloc] init];
    [self.stateButton setImage:[UIImage imageNamed:@"kk_play_small"] forState:UIControlStateNormal];
    [self.stateButton setImage:[UIImage imageNamed:@"kk_pause_small"] forState:UIControlStateSelected];
    self.stateButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.stateButton addTarget:self action:@selector(stateButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.stateButton.enabled = NO;
    [self.bottomBar addSubview:self.stateButton];
    //progressTimeLabel
    self.progressTimeLabel = [[UILabel alloc] init];
    self.progressTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.progressTimeLabel.font = [UIFont systemFontOfSize:12];
    self.progressTimeLabel.textColor = [UIColor whiteColor];
    self.progressTimeLabel.text = @"00:00";
    [self.bottomBar addSubview:self.progressTimeLabel];
    //progerssView
    self.videoProgress = [[UIProgressView alloc] init];
    self.videoProgress.progressTintColor = [UIColor colorWithRed:221/255.0 green:21/255.0 blue:105/255.0 alpha:1.0];
    [self.bottomBar addSubview:self.videoProgress];
    //slider
    self.videoSlider = [[UISlider alloc] init];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"kk_slider_small"] forState:UIControlStateNormal];
    self.videoSlider.userInteractionEnabled = YES;
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueEnd:) forControlEvents:UIControlEventValueChanged];
    [self.bottomBar addSubview:self.videoSlider];
    //totalTimeLabel
    self.totalTimeLabel = [[UILabel alloc] init];
    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.totalTimeLabel.font = [UIFont systemFontOfSize:12];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.text = @"00:00";
    [self.bottomBar addSubview:self.totalTimeLabel];
    //fullScreenButton
    self.fullScreenButton = [[UIButton alloc] init];
    [self.fullScreenButton setImage:[UIImage imageNamed:@"kk_full_screen"] forState:UIControlStateNormal];
    [self.fullScreenButton addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.fullScreenButton];
}


- (void)setContentUrlString:(NSString *)contentUrlString {
    // playerItem, 播放资源
//    NSURL *videoUrl = [NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"];
    NSURL *videoUrl = [NSURL URLWithString:contentUrlString];
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    //player, 播放器
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    //添加到 view 上
    self.stateButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}
//播放完毕
- (void)moviePlayDidEnd:(AVPlayerItem *)playerItem {
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.videoSlider setValue:0.0 animated:YES];
        weakSelf.stateButton.selected = NO;
        _played = NO;
        //展示重新播放按钮
        UIButton *rePlayButton = [[UIButton alloc] initWithFrame:self.bounds];
        UIImage *image;
        if (self.isFullscreenMode) {
            image = [UIImage imageNamed:@"kk_replay_big"];
        } else {
            image = [UIImage imageNamed:@"kk_replay_small"];
        }
        [rePlayButton setImage:image forState:UIControlStateNormal];
        [rePlayButton addTarget:self action:@selector(rePlay:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rePlayButton];
    }];
}

- (void)rePlay:(UIButton *)button {
    [button removeFromSuperview];
    [self stateButtonTouched:self.stateButton];
}

- (void)videoSlierChangeValueEnd:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        [weakSelf.player play];
        self.stateButton.selected = YES;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat buttonWidth = 40;
    CGFloat timeLabelWidth = 50;
    self.bottomBar.frame = CGRectMake(0, self.bounds.size.height-buttonWidth, self.bounds.size.width, buttonWidth);
    self.stateButton.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
    self.progressTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.stateButton.frame), CGRectGetMinY(self.stateButton.frame), timeLabelWidth, CGRectGetHeight(self.stateButton.frame));
    self.videoProgress.frame = CGRectMake(CGRectGetMaxX(self.progressTimeLabel.frame), CGRectGetMidY(self.progressTimeLabel.frame)-2, self.bounds.size.width-CGRectGetMaxX(self.progressTimeLabel.frame)*2, 4);
    self.videoSlider.frame = CGRectMake(CGRectGetMinX(self.videoProgress.frame), 0, CGRectGetWidth(self.videoProgress.frame), CGRectGetHeight(self.bottomBar.frame));
    self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.videoProgress.frame), CGRectGetMinY(self.progressTimeLabel.frame), timeLabelWidth, CGRectGetHeight(self.progressTimeLabel.frame));
    self.fullScreenButton.frame = CGRectMake(CGRectGetMaxX(self.totalTimeLabel.frame), CGRectGetMinY(self.stateButton.frame), buttonWidth, buttonWidth);
}

// KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            self.stateButton.enabled = YES;
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            [self customVideoSlider:duration];// 自定义UISlider外观
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
            //自动播放
            if (self.shouldAutoPlay) {
                [self stateButtonTouched:self.stateButton];
            }
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}
//转换时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [[self dateFormatter] stringFromDate:d];
    return showtimeNew;
}
//自定义 slider
- (void)customVideoSlider:(CMTime)duration {
    self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}
//监听播放状态
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        [weakSelf.videoSlider setValue:currentSecond animated:YES];
        NSString *timeString = [weakSelf convertTime:currentSecond];
        weakSelf.progressTimeLabel.text = timeString;
        weakSelf.totalTimeLabel.text = weakSelf.totalTime;
    }];
}
//缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

//播放
- (void)stateButtonTouched:(id)sender {
    if (!_played) {
        [self.player play];
        self.stateButton.selected = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.0 animations:^{
                self.bottomBar.alpha = 0.0;
                self.showBottomBar = NO;
            }];
        });
    } else {
        [self.player pause];
        self.stateButton.selected = NO;
    }
    _played = !_played;
}
//全屏
- (void)fullScreen {
    if (self.isFullscreenMode) {
        [UIView animateWithDuration:0.3f animations:^{
            [self setTransform:CGAffineTransformIdentity];
            self.frame = self.originFrame;
            [self.containerView addSubview:self];
        } completion:^(BOOL finished) {
            self.isFullscreenMode = NO;
        }];
    } else {
        self.originFrame = self.frame;
        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
        [UIView animateWithDuration:0.3f animations:^{
            self.frame = frame;
            [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
        } completion:^(BOOL finished) {
            self.isFullscreenMode = YES;
        }];
    }
}

//点击屏幕 显示/隐藏 bottomBar
- (void)tapView {
    if (self.showBottomBar) {
        if (self.played) {
            [UIView animateWithDuration:0.3 animations:^{
                self.bottomBar.alpha = 0.0;
                self.showBottomBar = NO;
            }];
        }
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomBar.alpha = 1.0;
            self.showBottomBar = YES;
            if (self.played) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.0 animations:^{
                        self.bottomBar.alpha = 0.0;
                        self.showBottomBar = NO;
                    }];
                });
            }
        }];
    }
}

//销毁处理
- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.player removeTimeObserver:self.playbackTimeObserver];
}

@end
