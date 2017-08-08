
#import "UIScrollView+MJRefresh.h"

/**  
 1. //header control
 [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
 [self.tableView addHeaderWithCallback:^{ }];
 
 2. //bottom
 [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
  [self.tableView addFooterWithCallback:^{ }];
 
 3. MJRefreshConst.h, JRefreshConst.m  //self definition
 
    [self.tableView headerBeginRefreshing];
    [self.tableView footerBeginRefreshing];
 
    [self.tableView headerEndRefreshing];
    [self.tableView footerEndRefreshing];
*/