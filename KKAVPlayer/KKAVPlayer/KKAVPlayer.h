//
//  KKAVPlayer.h
//  KKAVPlayer
//
//  Created by kkwalle on 16/10/25.
//  Copyright © 2016年 kkwalle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKAVPlayer : UIView
@property (nonatomic, weak) UIView *containerView;
- (instancetype)initWithContainerView:(UIView *)containerView autoPlay:(BOOL)autoPlay contentUrl:(NSString *)urlString;
- (void)play;
- (void)pause;
@end
