//
//  MJRefreshBaseView.m
//  MJRefresh
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"
#import <objc/message.h>

@interface  MJRefreshBaseView()
{
    __weak UILabel *_statusLabel;
    __weak UIImageView *_arrowImage;
    __weak UIActivityIndicatorView *_activityView;
}
@end

@implementation MJRefreshBaseView
#pragma mark -

- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.font = [UIFont boldSystemFontOfSize:13];
        statusLabel.textColor = MJRefreshLabelTextColor;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_statusLabel = statusLabel];
    }
    return _statusLabel;
}

- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:MJRefreshSrcName(@"arrow.png")]];
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage = arrowImage];
    }
    return _arrowImage;
}

- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = self.arrowImage.bounds;
        activityView.autoresizingMask = self.arrowImage.autoresizingMask;
        [self addSubview:_activityView = activityView];
    }
    return _activityView;
}

#pragma mark -
- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = MJRefreshViewHeight;
    if (self = [super initWithFrame:frame]) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        self.state = MJRefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat arrowX = self.mj_width * 0.5 - 100;
    self.arrowImage.center = CGPointMake(arrowX, self.mj_height * 0.5);
    
    self.activityView.center = self.arrowImage.center;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
   
    [self.superview removeObserver:self forKeyPath:MJRefreshContentOffset context:nil];
    
    if (newSuperview) {
        [newSuperview addObserver:self forKeyPath:MJRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        
        self.mj_width = newSuperview.mj_width;
        
        self.mj_x = 0;
        
        _scrollView = (UIScrollView *)newSuperview;
        
        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark -
- (void)drawRect:(CGRect)rect
{
    if (self.state == MJRefreshStateWillRefreshing) {
        self.state = MJRefreshStateRefreshing;
    }
}

#pragma mark -
#pragma mark
- (BOOL)isRefreshing
{
    return MJRefreshStateRefreshing == self.state;
}

#pragma mark
typedef void (*send_type)(void *, SEL, UIView *);
- (void)beginRefreshing
{
    if (self.state == MJRefreshStateRefreshing) {
        
        if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
            msgSend((__bridge void *)(self.beginRefreshingTaget), self.beginRefreshingAction, self);
        }
        
        if (self.beginRefreshingCallback) {
            self.beginRefreshingCallback();
        }
    } else {
        if (self.window) {
            self.state = MJRefreshStateRefreshing;
        } else {
            _state = MJRefreshStateWillRefreshing;
            [super setNeedsDisplay];
        }
    }
}

#pragma mark
- (void)endRefreshing
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = MJRefreshStateNormal;
    });
}

#pragma mark -
- (void)setPullToRefreshText:(NSString *)pullToRefreshText
{
    _pullToRefreshText = [pullToRefreshText copy];
    [self settingLabelText];
}
- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText
{
    _releaseToRefreshText = [releaseToRefreshText copy];
    [self settingLabelText];
}
- (void)setRefreshingText:(NSString *)refreshingText
{
    _refreshingText = [refreshingText copy];
    [self settingLabelText];
}
- (void)settingLabelText
{
	switch (self.state) {
		case MJRefreshStateNormal:
            
            self.statusLabel.text = self.pullToRefreshText;
			break;
		case MJRefreshStatePulling:
            
            self.statusLabel.text = self.releaseToRefreshText;
			break;
        case MJRefreshStateRefreshing:
            
            self.statusLabel.text = self.refreshingText;
			break;
        default:
            break;
	}
}

- (void)setState:(MJRefreshState)state
{
    
    if (self.state != MJRefreshStateRefreshing) {
        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
   
    if (self.state == state) return;
    
    switch (state) {
		case MJRefreshStateNormal:
        {
            if (self.state == MJRefreshStateRefreshing) {
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration * 0.6 animations:^{
                    self.activityView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    
                    [self.activityView stopAnimating];
                    
                    self.activityView.alpha = 1.0;
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJRefreshSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    _state = MJRefreshStatePulling;
                    self.state = MJRefreshStateNormal;
                });
                
                return;
            } else {
                self.arrowImage.hidden = NO;
                [self.activityView stopAnimating];
            }
			break;
        }
            
        case MJRefreshStatePulling:
            break;
            
		case MJRefreshStateRefreshing:
        {
            
			[self.activityView startAnimating];
			self.arrowImage.hidden = YES;
            
            if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
                [self.beginRefreshingTaget performSelector:self.beginRefreshingAction withObject:nil afterDelay:0.1];
//                objc_msgSend(self.beginRefreshingTaget, self.beginRefreshingAction, self);
            }
            
            if (self.beginRefreshingCallback) {
                self.beginRefreshingCallback();
            }
			break;
        }
        default:
            break;
	}
    
    _state = state;
    
    [self settingLabelText];
}
@end