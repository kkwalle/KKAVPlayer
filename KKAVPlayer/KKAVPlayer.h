//
//  KKAVPlayer.h
//  KKAVPlayer
//
//  Created by kkwalle on 16/10/25.
//  Copyright © 2016年 kkwalle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKAVPlayerDelegate <NSObject>
- (void)kkAVPlayerShouldFullScreen:(BOOL)shouldFullScreen;
@end

@interface KKAVPlayer : UIView
@property (nonatomic, copy) NSString *contentUrlString;
@property (nonatomic, assign) id<KKAVPlayerDelegate> delegate;
@property (nonatomic, assign) BOOL isFullscreenMode;
@end
