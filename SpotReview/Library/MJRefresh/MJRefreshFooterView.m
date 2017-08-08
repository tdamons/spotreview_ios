//
//  MJRefreshFooterView.m
//  MJRefresh
//
//  Created by mj on 13-2-26.
//  Copyright (c) 2013 itcast. All rights reserved.

#import "MJRefreshFooterView.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"

@interface MJRefreshFooterView()
@property (assign, nonatomic) int lastRefreshCount;
@end

@implementation MJRefreshFooterView

+ (instancetype)footer
{
    return [[MJRefreshFooterView alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.pullToRefreshText = MJRefreshFooterPullToRefresh;
        self.releaseToRefreshText = MJRefreshFooterReleaseToRefresh;
        self.refreshingText = MJRefreshFooterRefreshing;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.statusLabel.frame = self.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    
    [self.superview removeObserver:self forKeyPath:MJRefreshContentSize context:nil];
    
    if (newSuperview) {
        
        [newSuperview addObserver:self forKeyPath:MJRefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
        
        [self adjustFrameWithContentSize];
    }
}

#pragma mark frame
- (void)adjustFrameWithContentSize
{
    CGFloat contentHeight = self.scrollView.mj_contentSizeHeight;
    
    CGFloat scrollHeight = self.scrollView.mj_height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom;
    
    self.mj_y = MAX(contentHeight, scrollHeight);
}

#pragma mark UIScrollView Property
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    if ([MJRefreshContentSize isEqualToString:keyPath]) {
        [self adjustFrameWithContentSize];
    } else if ([MJRefreshContentOffset isEqualToString:keyPath]) {
        
        if (self.state == MJRefreshStateRefreshing) return;
        [self adjustStateWithContentOffset];
    }
}

- (void)adjustStateWithContentOffset
{
    // contentOffset
    CGFloat currentOffsetY = self.scrollView.mj_contentOffsetY;
    // offsetY
    CGFloat happenOffsetY = [self happenOffsetY];
    
    if (currentOffsetY <= happenOffsetY) return;
    
    if (self.scrollView.isDragging) {
        
        CGFloat normal2pullingOffsetY = happenOffsetY + self.mj_height;
        
        if (self.state == MJRefreshStateNormal && currentOffsetY > normal2pullingOffsetY) {
            
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && currentOffsetY <= normal2pullingOffsetY) {
            
            self.state = MJRefreshStateNormal;
        }
    } else if (self.state == MJRefreshStatePulling) {
        self.state = MJRefreshStateRefreshing;
    }
}

#pragma mark -
#pragma mark
- (void)setState:(MJRefreshState)state
{
    if (self.state == state) return;
    
    MJRefreshState oldState = self.state;
    
    [super setState:state];    
    
	switch (state)
    {
		case MJRefreshStateNormal:
        {
            if (MJRefreshStateRefreshing == oldState) {
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                    self.scrollView.mj_contentInsetBottom = self.scrollViewOriginalInset.bottom;
                }];
            } else {
                [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                }];
            }
            
            CGFloat deltaH = [self heightForContentBreakView];
            int currentCount = [self totalDataCountInScrollView];
            
            if (MJRefreshStateRefreshing == oldState && deltaH > 0 && currentCount != self.lastRefreshCount) {
                self.scrollView.mj_contentOffsetY = self.scrollView.mj_contentOffsetY;
            }
			break;
        }
            
		case MJRefreshStatePulling:
        {
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowImage.transform = CGAffineTransformIdentity;
            }];
			break;
        }
            
        case MJRefreshStateRefreshing:
        {
            self.lastRefreshCount = [self totalDataCountInScrollView];
            
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                CGFloat bottom = self.mj_height + self.scrollViewOriginalInset.bottom;
                CGFloat deltaH = [self heightForContentBreakView];
                if (deltaH < 0) {
                    bottom -= deltaH;
                }
                self.scrollView.mj_contentInsetBottom = bottom;
            }];
			break;
        }
            
        default:
            break;
	}
}

- (int)totalDataCountInScrollView
{
    int totalCount = 0;
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        
        for (int section = 0; section<tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        
        for (int section = 0; section<collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

#pragma mark scrollView view
- (CGFloat)heightForContentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    return self.scrollView.contentSize.height - h;
}

#pragma mark -

- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top;
    } else {
        return - self.scrollViewOriginalInset.top;
    }
}
@end