//
//  UIScrollView+MJRefresh.m
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014 itcast. All rights reserved.
//

#import "UIScrollView+MJRefresh.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import <objc/runtime.h>

@interface UIScrollView()
@property (weak, nonatomic) MJRefreshHeaderView *header;
@property (weak, nonatomic) MJRefreshFooterView *footer;
@end


@implementation UIScrollView (MJRefresh)

static char MJRefreshHeaderViewKey;
static char MJRefreshFooterViewKey;

- (void)setHeader:(MJRefreshHeaderView *)header {
    [self willChangeValueForKey:@"MJRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &MJRefreshHeaderViewKey,
                             header,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"MJRefreshHeaderViewKey"];
}

- (MJRefreshHeaderView *)header {
    return objc_getAssociatedObject(self, &MJRefreshHeaderViewKey);
}

- (void)setFooter:(MJRefreshFooterView *)footer {
    [self willChangeValueForKey:@"MJRefreshFooterViewKey"];
    objc_setAssociatedObject(self, &MJRefreshFooterViewKey,
                             footer,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"MJRefreshFooterViewKey"];
}

- (MJRefreshFooterView *)footer {
    return objc_getAssociatedObject(self, &MJRefreshFooterViewKey);
}


- (void)addHeaderWithCallback:(void (^)())callback
{
    //1.header
    if (!self.header) {
        MJRefreshHeaderView *header = [MJRefreshHeaderView header];
        [self addSubview:header];
        self.header = header;
    }
    
    // 2.block
    self.header.beginRefreshingCallback = callback;
}

- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
    // 1.header
    if (!self.header) {
        MJRefreshHeaderView *header = [MJRefreshHeaderView header];
        [self addSubview:header];
        self.header = header;
    }
    
    // 2.
    self.header.beginRefreshingTaget = target;
    self.header.beginRefreshingAction = action;
}

- (void)removeHeader
{
    [self.header removeFromSuperview];
    self.header = nil;
}

- (void)headerBeginRefreshing
{
    [self.header beginRefreshing];
}

- (void)headerEndRefreshing
{
    [self.header endRefreshing];
}

- (void)setHeaderHidden:(BOOL)hidden
{
    self.header.hidden = hidden;
}

- (BOOL)isHeaderHidden
{
    return self.header.isHidden;
}

- (BOOL)isHeaderRefreshing
{
    return self.header.state == MJRefreshStateRefreshing;
}

#pragma mark -
- (void)addFooterWithCallback:(void (^)())callback
{
    // 1.footer
    if (!self.footer) {
        MJRefreshFooterView *footer = [MJRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }
    
    // 2.
    self.footer.beginRefreshingCallback = callback;
}

- (void)addFooterWithTarget:(id)target action:(SEL)action
{
    // 1.footer
    if (!self.footer) {
        MJRefreshFooterView *footer = [MJRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }
    
    // 2.
    self.footer.beginRefreshingTaget = target;
    self.footer.beginRefreshingAction = action;
}

- (void)removeFooter
{
    [self.footer removeFromSuperview];
    self.footer = nil;
}

- (void)footerBeginRefreshing
{
    [self.footer beginRefreshing];
}

- (void)footerEndRefreshing
{
    [self.footer endRefreshing];
}

- (void)setFooterHidden:(BOOL)hidden
{
    self.footer.hidden = hidden;
}

- (BOOL)isFooterHidden
{
    return self.footer.isHidden;
}

- (BOOL)isFooterRefreshing
{
    return self.footer.state == MJRefreshStateRefreshing;
}

- (void)setFooterPullToRefreshText:(NSString *)footerPullToRefreshText
{
    self.footer.pullToRefreshText = footerPullToRefreshText;
}

- (NSString *)footerPullToRefreshText
{
    return self.footer.pullToRefreshText;
}

- (void)setFooterReleaseToRefreshText:(NSString *)footerReleaseToRefreshText
{
    self.footer.releaseToRefreshText = footerReleaseToRefreshText;
}

- (NSString *)footerReleaseToRefreshText
{
    return self.footer.releaseToRefreshText;
}

- (void)setFooterRefreshingText:(NSString *)footerRefreshingText
{
    self.footer.refreshingText = footerRefreshingText;
}

- (NSString *)footerRefreshingText
{
    return self.footer.refreshingText;
}

- (void)setHeaderPullToRefreshText:(NSString *)headerPullToRefreshText
{
    self.header.pullToRefreshText = headerPullToRefreshText;
}

- (NSString *)headerPullToRefreshText
{
    return self.header.pullToRefreshText;
}

- (void)setHeaderReleaseToRefreshText:(NSString *)headerReleaseToRefreshText
{
    self.header.releaseToRefreshText = headerReleaseToRefreshText;
}

- (NSString *)headerReleaseToRefreshText
{
    return self.header.releaseToRefreshText;
}

- (void)setHeaderRefreshingText:(NSString *)headerRefreshingText
{
    self.header.refreshingText = headerRefreshingText;
}

- (NSString *)headerRefreshingText
{
    return self.header.refreshingText;
}
@end
