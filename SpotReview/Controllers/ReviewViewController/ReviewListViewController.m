//
//  ReviewListViewController.m
//  SpotReview
//
//  Created by lion on 11/19/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "ReviewListViewController.h"
#import "REFrostedViewController.h"
#import "TopSpotsViewController.h"
#import "ASFSharedViewTransition.h"
#import "TopSpotsViewController.h"
#import "SpotDetailViewController.h"
#import "CompanyDetailsViewController.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "SessionManager.h"
#import "SearchTableViewCell.h"
#import "SRSpotObject.h"
#import "APIService.h"

@interface ReviewListViewController () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *reviewListTableView;
    
    NSMutableArray *reviewListArray;
    NSInteger page;
    SRSpotObject *selectedSpotItem;
}

@end

@implementation ReviewListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    page = 1;
    [self viewLayout];
    [self loadReviewList:NO];
//    
//    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.title = @"MY REVIEWS";
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_menuwhite.png"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    [self.frostedViewController panGestureRecognized:sender];
}

- (void)viewLayout {
    
    reviewListArray = [[NSMutableArray alloc] init];
    selectedSpotItem = [[SRSpotObject alloc] init];
    
    [reviewListTableView addHeaderWithTarget:self action:@selector(loadFirstPage)];
    reviewListTableView.headerPullToRefreshText = @"Pull to refresh";
    reviewListTableView.headerReleaseToRefreshText = @"Release to refresh";
    reviewListTableView.headerRefreshingText = @"Loading...";
    [reviewListTableView addFooterWithTarget:self action:@selector(loadNextPage)];
    reviewListTableView.footerPullToRefreshText = @"Pull to load more";
    reviewListTableView.footerReleaseToRefreshText = @"Release to load more";
    reviewListTableView.footerRefreshingText = @"Loading...";
}

- (void)loadFirstPage {
    page = 1;
    [self loadReviewList:YES];
}

- (void)loadNextPage {
    page ++;
    [self loadReviewList:YES];
}

- (void)endHeaderRefresh {
    [reviewListTableView headerEndRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)endFooterRefresh {
    [reviewListTableView footerEndRefreshing];
}

- (void)loadReviewList:(BOOL)refreshFlag {
    if (!refreshFlag) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:[NSString stringWithFormat:@"%ld", (long)[SessionManager currentSession].userInfo.userId] forKey:@"user_id"];
    [requestDic setObject:[NSString stringWithFormat:@"%ld", (long)page] forKey:@"page"];
    
    [APIService makeApiCallWithMethodUrl:API_GET_SPOTSBYUSERID andRequestType:RequestTypePost andPathParams:nil andQueryParams:requestDic resultCallback:^(NSObject *result) {
        
        if (!refreshFlag) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        if (page == 1) {
            [reviewListArray removeAllObjects];
        }
        
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag =
        [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            NSArray *spots = [[NSArray alloc] init];
            spots = [dic objectForKey:@"object"];
            for (int i = 0; i < spots.count; i ++) {
                NSDictionary *spotItemDic = [spots objectAtIndex:i];
                SRSpotObject *spotItem = [[SRSpotObject alloc] initWithDictionary:spotItemDic];
                [reviewListArray addObject:spotItem];
            }
            [reviewListTableView reloadData];
            [self endHeaderRefresh];
            [self endFooterRefresh];
            
        } else {
            [self endHeaderRefresh];
            [self endFooterRefresh];
            if (page == 1) {
                [SRConstant UIAlertViewShow:@"There are no reviews." withTitle:nil];
            }
            if (page > 1)
                page --;
        }
        
    } faultCallback:^(NSError *fault) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view endEditing:NO];
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return reviewListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"reviewListCell";
    SearchTableViewCell *cell = (SearchTableViewCell *)[reviewListTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    SRSpotObject *spotItem = [reviewListArray objectAtIndex:indexPath.row];
    
    float goodRatio = (float)spotItem.goodNumber / (float)(spotItem.goodNumber + spotItem.badNumber) * 100;
    float badRatio = 100 - goodRatio;
    
    cell.brandNameLabel.text = spotItem.spotCompanyName;
    cell.brandGoodRation.text = [NSString stringWithFormat:@"%.0f%@", goodRatio, @"%"];
    cell.brandColdRation.text = [NSString stringWithFormat:@"%.0f%@", badRatio, @"%"];
    if (goodRatio > badRatio) {
        [cell.brandGoodRation setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
        [cell.brandColdRation setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    } else {
        [cell.brandGoodRation setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
        [cell.brandColdRation setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedSpotItem = [reviewListArray objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"spotDetailIdentifier" sender:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"spotDetailIdentifier"]) {
        CompanyDetailsViewController *detailController = segue.destinationViewController;
        //        if (selectedImage != nil) {
        //            detailController.selectedImage = selectedImage;
        //        }
        //        detailController.isTop = self.isTop;
        detailController.isFromReview = YES;
        detailController.spotItem = selectedSpotItem;
    }
}


@end
