//
//  SearchViewController.m
//  SpotReview
//
//  Created by lion on 11/20/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "SearchViewController.h"
#import "TopSpotsViewController.h"
#import "SpotDetailViewController.h"
#import "CompanyDetailsViewController.h"
#import "ASFSharedViewTransition.h"
#import "SRSpotObject.h"
#import "SearchTableViewCell.h"
#import "TopSpotsViewController.h"
#import "MBProgressHUD.h"
#import "REFrostedViewController.h"
#import "APIService.h"
#import "MJRefresh.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *brandsTableView;
    
    NSMutableArray *brandsArray;
    NSMutableArray *searchBrandsArray;
    NSInteger page;
    
    SRSpotObject *spotSelectedItem;
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    brandsArray = [[NSMutableArray alloc] init];
    searchBrandsArray = [[NSMutableArray alloc] init];
    page = 1;
    [self viewLayout];
//    [self loadBrands:NO];
    
//    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.title = @"SEARCH";
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_menuwhite.png"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0xBF0302), NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];    
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    [self.frostedViewController panGestureRecognized:sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void)viewLayout {
    
    [brandsTableView addHeaderWithTarget:self action:@selector(loadFirstPage)];
    brandsTableView.headerPullToRefreshText = @"Pull to refresh";
    brandsTableView.headerReleaseToRefreshText = @"Release to refresh";
    brandsTableView.headerRefreshingText = @"Loading...";
    [brandsTableView addFooterWithTarget:self action:@selector(loadNextPage)];
    brandsTableView.footerPullToRefreshText = @"Pull to load more";
    brandsTableView.footerReleaseToRefreshText = @"Release to load more";
    brandsTableView.footerRefreshingText = @"Loading...";
}

- (void)loadFirstPage {
    page = 1;
    [self loadBrands:YES];
}

- (void)loadNextPage {
    page ++;
    [self loadBrands:YES];
}

- (void)endHeaderRefresh {
    [brandsTableView headerEndRefreshing];
}

- (void)endFooterRefresh {
    [brandsTableView footerEndRefreshing];
}

- (void)loadBrands:(BOOL)refreshFlag {
    if (!refreshFlag) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    
    [infoDic setObject:[NSString stringWithFormat:@"%ld", (long)page] forKey:@"page"];
    
    [APIService makeApiCallWithMethodUrl:API_GET_BRANDS andRequestType:RequestTypePost andPathParams:nil andQueryParams:infoDic resultCallback:^(NSObject *result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (page == 1) {
            [brandsArray removeAllObjects];
        }
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            NSArray *spots = [[NSArray alloc] init];
            spots = [dic objectForKey:@"object"];
            
            for (int i = 0; i < spots.count; i ++) {
                NSDictionary *spotItemDic = [spots objectAtIndex:i];
                SRSpotObject *spotItem = [[SRSpotObject alloc] initWithDictionary:spotItemDic];
                [brandsArray addObject:spotItem];
            }
            
            [brandsTableView reloadData];
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

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"topSpotsFromSearchIdentifier"]) {
        CompanyDetailsViewController *detailController = segue.destinationViewController;
        detailController.isFromReview = NO;
        detailController.spotItem = spotSelectedItem;
    }
}

- (void)searchResult:(NSString *)searchString {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    
    [infoDic setObject:searchString forKey:@"search_string"];
    
    [APIService makeApiCallWithMethodUrl:API_GET_SEARCHBRANDS andRequestType:RequestTypePost andPathParams:nil andQueryParams:infoDic resultCallback:^(NSObject *result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        [searchBrandsArray removeAllObjects];
        if (resultFlag) {
            NSArray *spots = [[NSArray alloc] init];
            spots = [dic objectForKey:@"object"];
            
            for (int i = 0; i < spots.count; i ++) {
                NSDictionary *spotItemDic = [spots objectAtIndex:i];
                SRSpotObject *spotItem = [[SRSpotObject alloc] initWithDictionary:spotItemDic];
                [searchBrandsArray addObject:spotItem];
                
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
            
        } else {
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        
    } faultCallback:^(NSError *fault) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view endEditing:NO];
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];      
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        numberOfRows = searchBrandsArray.count;
    } else {
        numberOfRows = brandsArray.count;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 93;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"searchCell";
    SearchTableViewCell *cell = (SearchTableViewCell *)[brandsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Display brands in the table cell
    SRSpotObject *spotItem = [[SRSpotObject alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        spotItem = [searchBrandsArray objectAtIndex:indexPath.row];
    } else {
        spotItem = [brandsArray objectAtIndex:indexPath.row];
    }
    
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
    if (self.searchDisplayController.active) {
        spotSelectedItem = [searchBrandsArray objectAtIndex:indexPath.row];
    } else {
        spotSelectedItem = [brandsArray objectAtIndex:indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"topSpotsFromSearchIdentifier" sender:nil];
}

#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self searchResult:searchString];
    
    return YES;
}

@end
