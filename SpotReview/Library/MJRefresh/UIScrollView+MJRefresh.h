//
//  UIScrollView+MJRefresh.h
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (MJRefresh)
#pragma mark -
- (void)addHeaderWithCallback:(void (^)())callback;

- (void)addHeaderWithTarget:(id)target action:(SEL)action;

- (void)removeHeader;

- (void)headerBeginRefreshing;

- (void)headerEndRefreshing;

@property (nonatomic, assign, getter = isHeaderHidden) BOOL headerHidden;

@property (nonatomic, assign, readonly, getter = isHeaderRefreshing) BOOL headerRefreshing;

#pragma mark -
- (void)addFooterWithCallback:(void (^)())callback;

- (void)addFooterWithTarget:(id)target action:(SEL)action;

- (void)removeFooter;

- (void)footerBeginRefreshing;

- (void)footerEndRefreshing;

@property (nonatomic, assign, getter = isFooterHidden) BOOL footerHidden;

@property (nonatomic, assign, readonly, getter = isFooterRefreshing) BOOL footerRefreshing;

@property (copy, nonatomic) NSString *footerPullToRefreshText;
@property (copy, nonatomic) NSString *footerReleaseToRefreshText;
@property (copy, nonatomic) NSString *footerRefreshingText;

@property (copy, nonatomic) NSString *headerPullToRefreshText;
@property (copy, nonatomic) NSString *headerReleaseToRefreshText;
@property (copy, nonatomic) NSString *headerRefreshingText;

@end
