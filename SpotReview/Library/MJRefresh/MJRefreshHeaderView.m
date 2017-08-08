//
//  MJRefreshHeaderView.m
//  MJRefresh
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013 itcast. All rights reserved.

#import "MJRefreshConst.h"
#import "MJRefreshHeaderView.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"

@interface MJRefreshHeaderView()

@property (nonatomic, strong) NSDate *lastUpdateTime;
@end

@implementation MJRefreshHeaderView
#pragma mark -

+ (instancetype)header
{
    return [[MJRefreshHeaderView alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = MJRefreshHeaderPullToRefresh;
        self.releaseToRefreshText = MJRefreshHeaderReleaseToRefresh;
        self.refreshingText = MJRefreshHeaderRefreshing;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat statusX = 0;
    CGFloat statusY = 0;
    CGFloat statusHeight = self.mj_height;
    CGFloat statusWidth = self.mj_width;
   
    self.statusLabel.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
   
    self.mj_y = - self.mj_height;
}

#pragma mark -
#pragma mark
- (void)setLastUpdateTime:(NSDate *)lastUpdateTime
{
    _lastUpdateTime = lastUpdateTime;
    
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:MJRefreshHeaderTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIScrollViewcontentOffset
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    if (self.state == MJRefreshStateRefreshing) return;

    if ([MJRefreshContentOffset isEqualToString:keyPath]) {
        [self adjustStateWithContentOffset];
    }
}

- (void)adjustStateWithContentOffset
{
    // contentOffset
    CGFloat currentOffsetY = self.scrollView.mj_contentOffsetY;
    // offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    //
    if (currentOffsetY >= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        //
        CGFloat normal2pullingOffsetY = happenOffsetY - self.mj_height;
        
        if (self.state == MJRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            //
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            //
            self.state = MJRefreshStateNormal;
        }
    } else if (self.state == MJRefreshStatePulling) {
        //
        self.state = MJRefreshStateRefreshing;
    }
}

#pragma mark
- (void)setState:(MJRefreshState)state
{
    
    if (self.state == state) return;
    
    MJRefreshState oldState = self.state;
    
    [super setState:state];
    
	switch (state) {
		case MJRefreshStateNormal:
        {
            if (MJRefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformIdentity;
                
                self.lastUpdateTime = [NSDate date];
                
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{

                    self.scrollView.mj_contentInsetTop -= self.mj_height;
                }];
            } else {
                [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformIdentity;
                }];
            }
			break;
        }
            
		case MJRefreshStatePulling:
        {
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
			break;
        }
            
		case MJRefreshStateRefreshing:
        {
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                
                CGFloat top = self.scrollViewOriginalInset.top + self.mj_height;
                self.scrollView.mj_contentInsetTop = top;                
                
                self.scrollView.mj_contentOffsetY = - top;
            }];
			break;
        }
            
        default:
            break;
	}
}
@end