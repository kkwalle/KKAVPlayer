//
//  KKAVPlayer.h
//  KKAVPlayer
//
//  Created by kkwalle on 16/10/25.
//  Copyright © 2016年 kkwalle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKAVPlayer : UIView
- (instancetype)initWithContainerView:(UIView *)containerView autoPlay:(BOOL)autoPlay contentUrl:(NSString *)urlString;
//containerView 的父容器为 scrollView 类型, 此设置有效
@property (nonatomic, assign) BOOL shouldPauseWhenOutOfScreen;
@end
