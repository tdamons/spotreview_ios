//
//  EnterCampaignViewController.m
//  SpotReview
//
//  Created by lion on 11/23/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "EnterCampaignViewController.h"
#import "CampaignBrandingViewController.h"
#import "SRCampaignObject.h"
#import "SessionManager.h"
#import "SearchTableViewCell.h"
#import "REFrostedViewController.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "APIService.h"

@interface EnterCampaignViewController () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *campaignTableView;
    
    NSMutableArray *campaignsArray;
    NSMutableArray *searchCampaignsArray;
    NSInteger page;
}

@end

@implementation EnterCampaignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    campaignsArray = [[NSMutableArray alloc] init];
    searchCampaignsArray = [[NSMutableArray alloc] init];
    page = 1;
    [self viewLayout];
    [self loadCampaignCodes:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"CAMPAIGN MODE";
    [self.navigationController.navigationBar setBarTintColor:APP_MAIN_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_menuwhite.png"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)viewLayout {
    [campaignTableView addHeaderWithTarget:self action:@selector(loadFirstPage)];
    campaignTableView.headerPullToRefreshText = @"Pull to refresh";
    campaignTableView.headerReleaseToRefreshText = @"Release to refresh";
    campaignTableView.headerRefreshingText = @"Loading...";
    [campaignTableView addFooterWithTarget:self action:@selector(loadNextPage)];
    campaignTableView.footerPullToRefreshText = @"Pull to load more";
    campaignTableView.footerReleaseToRefreshText = @"Release to load more";
    campaignTableView.footerRefreshingText = @"Loading...";
}

- (void)loadFirstPage {
    page = 1;
    [self loadCampaignCodes:YES];
}

- (void)loadNextPage {
    page ++;
    [self loadCampaignCodes:YES];
}

- (void)endHeaderRefresh {
    [campaignTableView headerEndRefreshing];
}

- (void)endFooterRefresh {
    [campaignTableView footerEndRefreshing];
}

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void)loadCampaignCodes:(BOOL)refreshFlag {
    if (!refreshFlag) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    
    [infoDic setObject:[NSString stringWithFormat:@"%ld", (long)page] forKey:@"page"];
    
    [APIService makeApiCallWithMethodUrl:API_GET_CAMPAIGNCODES andRequestType:RequestTypePost andPathParams:nil andQueryParams:infoDic resultCallback:^(NSObject *result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (page == 1) {
            [campaignsArray removeAllObjects];
        }
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            NSArray *campaigns = [[NSArray alloc] init];
            campaigns = [dic objectForKey:@"object"];
            
            for (int i = 0; i < campaigns.count; i ++) {
                NSDictionary *campaignItemDic = [campaigns objectAtIndex:i];
                SRCampaignObject *campaignItem = [[SRCampaignObject alloc] initWithDictionary:campaignItemDic];
                [campaignsArray addObject:campaignItem];
                
            }
            [campaignTableView reloadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"campaignBrandingIdentifier"]) {
        NSIndexPath *indexPath;
        SRCampaignObject *campaignSelectedItem = [[SRCampaignObject alloc] init];
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            campaignSelectedItem = [searchCampaignsArray objectAtIndex:indexPath.row];
        } else {
            indexPath = [campaignTableView indexPathForSelectedRow];
            campaignSelectedItem = [campaignsArray objectAtIndex:indexPath.row];
        }
        
        [SessionManager currentSession].campaignData = campaignSelectedItem;
    }
}

- (void)searchResult:(NSString *)searchString {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    
    [infoDic setObject:searchString forKey:@"search_string"];
    
    [APIService makeApiCallWithMethodUrl:API_GET_SEARCHCAMPAIGNS andRequestType:RequestTypePost andPathParams:nil andQueryParams:infoDic resultCallback:^(NSObject *result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        [searchCampaignsArray removeAllObjects];
        if (resultFlag) {
            NSArray *campaigns = [[NSArray alloc] init];
            campaigns = [dic objectForKey:@"object"];
            
            for (int i = 0; i < campaigns.count; i ++) {
                NSDictionary *campaignItemDic = [campaigns objectAtIndex:i];
                SRCampaignObject *campaignItem = [[SRCampaignObject alloc] initWithDictionary:campaignItemDic];
                [searchCampaignsArray addObject:campaignItem];
                
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
        numberOfRows = searchCampaignsArray.count;
    } else {
        numberOfRows = campaignsArray.count;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"searchCell";
    SearchTableViewCell *cell = (SearchTableViewCell *)[campaignTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Display brands in the table cell
    SRCampaignObject *campaignItem = [[SRCampaignObject alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        campaignItem = [searchCampaignsArray objectAtIndex:indexPath.row];
    } else {
        campaignItem = [campaignsArray objectAtIndex:indexPath.row];
    }
    
    cell.brandNameLabel.text = campaignItem.campaignCode;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"campaignBrandingIdentifier" sender:nil];
}

#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self searchResult:searchString];
    
    return YES;
}

@end
