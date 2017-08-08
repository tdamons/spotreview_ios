//
//  TopSpotsViewController.m
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "TopSpotsViewController.h"
#import "SpotDetailViewController.h"
#import "CompanyDetailsViewController.h"
#import "SpotTableViewCell.h"
#import "SRSpotObject.h"
#import "ASFSharedViewTransition.h"
#import "APIService.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface TopSpotsViewController () <UITableViewDataSource, UITableViewDelegate, ASFSharedViewTransitionDataSource> {
    
    NSInteger page;
    UIImage *selectedImage;
    NSMutableArray *spotsArray;
    IBOutlet UITableView *spotTableView;
}

@end

@implementation TopSpotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    spotsArray = [[NSMutableArray alloc] init];
    if (self.isFromReviewList) {
        self.navigationItem.title = @"MY REVIEWS";
        [spotsArray addObject:self.spotFromReview];
    } else if (self.isFromSearch) {
        self.navigationItem.title = @"SEARCH";
        [spotsArray addObject:self.spotFromReview];
    } else {
        page = 1;
        [self viewLayout];
        [self loadSpots:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewLayout {
    
    if (self.isTop) {
        self.navigationItem.title = @"TOP 5 HOT SPOTS";
    } else {
        self.navigationItem.title = @"TOP 5 COLD SPOTS";
    }
    
    [spotTableView addHeaderWithTarget:self action:@selector(loadFirstPage)];
    spotTableView.headerPullToRefreshText = @"Pull to refresh";
    spotTableView.headerReleaseToRefreshText = @"Release to refresh";
    spotTableView.headerRefreshingText = @"Loading...";
//    [spotTableView addFooterWithTarget:self action:@selector(loadNextPage)];
//    spotTableView.footerPullToRefreshText = @"Pull to load more";
//    spotTableView.footerReleaseToRefreshText = @"Release to load more";
//    spotTableView.footerRefreshingText = @"Loading...";
}

- (void)loadFirstPage {
    page = 1;
    [self loadSpots:YES];
}

- (void)loadNextPage {
    page ++;
    [self loadSpots:YES];
}

- (void)loadSpots:(BOOL)refreshFlag {
    if (!refreshFlag) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    NSMutableDictionary *photoDic = [[NSMutableDictionary alloc] init];
    
    [photoDic setObject:[NSString stringWithFormat:@"%ld", (long)page] forKey:@"page"];
    
    NSString *apiString;
    if (self.isTop) {
        apiString = API_GET_TOPSPOTS;
    } else {
        apiString = API_GET_BADSPOTS;
    }
    
    [APIService makeApiCallWithMethodUrl:apiString andRequestType:RequestTypePost andPathParams:nil andQueryParams:photoDic resultCallback:^(NSObject *result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (page == 1) {
            [spotsArray removeAllObjects];
        }
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            NSArray *spots = [[NSArray alloc] init];
            spots = [dic objectForKey:@"object"];
            for (int i = 0; i < spots.count; i ++) {
                NSDictionary *spotItemDic = [spots objectAtIndex:i];
                SRSpotObject *spotItem = [[SRSpotObject alloc] initWithDictionary:spotItemDic];
                if (self.isTop) {
                    if (spotItem.goodNumber >= spotItem.badNumber) {
                        [spotsArray addObject:spotItem];
                    }
                } else {
                    if (spotItem.goodNumber < spotItem.badNumber) {
                        [spotsArray addObject:spotItem];
                    }
                }
            }
            [spotTableView reloadData];
            [self endHeaderRefresh];
            [self endFooterRefresh];
            
        } else {
            [self endHeaderRefresh];
            [self endFooterRefresh];
            if (page == 1) {
                [SRConstant UIAlertViewShow:@"There are no spots." withTitle:nil];
            }
            if (page > 1)
                page --;
        }
        
    } faultCallback:^(NSError *fault) {
        //        [SVProgressHUD dismiss];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view endEditing:NO];
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (void)endHeaderRefresh {
    [spotTableView headerEndRefreshing];
    //    [SVProgressHUD dismiss];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)endFooterRefresh {
    [spotTableView footerEndRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return spotsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"spotCell";
    SpotTableViewCell *cell = (SpotTableViewCell *)[spotTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[SpotTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
    }
//    if (!cell.isAnimation) {
//        [cell.contentView setFrame:CGRectMake(-20, -20, cell.frame.size.width + 40, cell.frame.size.height + 40)];
//        [UIView animateWithDuration:0.5 animations:^{
//            [cell.contentView setFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//        }];
//    }
//    cell.isAnimation = NO;
  
    cell.cellIndex = indexPath.row;
    
    SRSpotObject *spotItem = [spotsArray objectAtIndex:indexPath.row];
    
//    NSURL *spotPhotoUrl = [NSURL URLWithString:spotItem.spotImageUrl];
//    UIActivityIndicatorView *cellIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    [cellIndicator setFrame:CGRectMake(cell.frame.size.width / 2 - 2, cell.frame.size.height / 2 - 2, 10, 10)];
    
//    [cell.contentView addSubview:cellIndicator];
//    [cell.spotImage setImageWithURLRequest:[NSURLRequest requestWithURL:spotPhotoUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        
//        [cellIndicator removeFromSuperview];
//
//        NSLog(@"Success image Download");
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        NSLog(@"%@", error);
//        [cellIndicator removeFromSuperview];
//    }];
    float goodRatio = (float)spotItem.goodNumber / (float)(spotItem.goodNumber + spotItem.badNumber) * 100;
    float badRatio = 100 - goodRatio;
    
    cell.spotCompanyName.text = spotItem.spotCompanyName;
    cell.spotHotRatio.text = [NSString stringWithFormat:@"%.0f%@", goodRatio, @"%"];
    cell.spotColdRation.text = [NSString stringWithFormat:@"%.0f%@", badRatio, @"%"];
    if (goodRatio > badRatio) {
        [cell.spotHotRatio setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
        [cell.spotColdRation setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    } else {
        [cell.spotHotRatio setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
        [cell.spotColdRation setFont:[UIFont fontWithName:@"Helvetica Neue" size:20.0]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCellIndex = indexPath.row;
    [self performSegueWithIdentifier:@"spotDetailIdentifier" sender:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ASFSharedViewTransitionDataSource
- (UIView *)sharedView {
    UIImageView *imageView;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedCellIndex inSection:0];
    SpotTableViewCell *tableCell = (SpotTableViewCell *)[spotTableView cellForRowAtIndexPath:indexPath];
    imageView = tableCell.spotImage;
    return imageView;
}

//#pragma mark - SpotCellDelegate
//- (void)didClickImage:(NSInteger)index {
//    self.selectedCellIndex = index;
//    UIImage *image;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedCellIndex inSection:0];
//    SpotTableViewCell *tableCell = (SpotTableViewCell *)[spotTableView cellForRowAtIndexPath:indexPath];
//    image = tableCell.spotImage.image;
//    if (image != nil && image != [UIImage imageNamed:@"placeholder"]) {
//        selectedImage = image;
//    }
//    [self performSegueWithIdentifier:@"spotDetailIdentifier" sender:nil];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"spotDetailIdentifier"]) {
        CompanyDetailsViewController *detailController = segue.destinationViewController;
//        if (selectedImage != nil) {
//            detailController.selectedImage = selectedImage;
//        }
//        detailController.isTop = self.isTop;
        detailController.spotItem = [spotsArray objectAtIndex:self.selectedCellIndex];
    }
}

@end
