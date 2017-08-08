//
//  MJRefreshBaseView.h
//  MJRefresh

#import <UIKit/UIKit.h>

@class MJRefreshBaseView;

#pragma mark -
typedef enum {
	MJRefreshStatePulling = 1,
	MJRefreshStateNormal = 2,
	MJRefreshStateRefreshing = 3,
    MJRefreshStateWillRefreshing = 4
} MJRefreshState;

#pragma mark -
typedef enum {
    MJRefreshViewTypeHeader = -1,
    MJRefreshViewTypeFooter = 1
} MJRefreshViewType;

@interface MJRefreshBaseView : UIView
#pragma mark -
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;

#pragma mark -
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UIImageView *arrowImage;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityView;

#pragma mark -

@property (weak, nonatomic) id beginRefreshingTaget;

@property (assign, nonatomic) SEL beginRefreshingAction;

@property (nonatomic, copy) void (^beginRefreshingCallback)();

#pragma mark -

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (void)beginRefreshing;

- (void)endRefreshing;

#pragma mark -
@property (assign, nonatomic) MJRefreshState state;

@property (copy, nonatomic) NSString *pullToRefreshText;
@property (copy, nonatomic) NSString *releaseToRefreshText;
@property (copy, nonatomic) NSString *refreshingText;
@end