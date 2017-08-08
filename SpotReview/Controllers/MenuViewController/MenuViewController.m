//
//  MenuViewController.m
//  SpotReview
//
//  Created by lion on 10/22/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "UIViewController+JDSideMenu.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureTableView {
    self.tableView = ({
//        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 2) / 2.0f, self.view.frame.size.width, 54 * 6) style:UITableViewStylePlain];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 103, self.view.frame.size.width - 70, 407) style:UITableViewStyleGrouped];
//        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
//        tableView.backgroundView = nil;
//        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        tableView.bounces = NO;
//        tableView.scrollsToTop = NO;
        tableView;
    });
    
    [self.view setBackgroundColor:[UIColor colorWithRed:44.0/255.0 green:119.0/255.0 blue:155.0/255.0 alpha:1.0f]];
    [self.view addSubview:self.tableView];
}

#pragma mark - TableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:44.0/255.0 green:119.0/255.0 blue:155.0/255.0 alpha:1.0f];
        cell.textLabel.font = [UIFont fontWithName:@"Papyrus" size:19];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSArray *titles = @[@"Home", @"About", @"Top Spots", @"Post Review", @"Contact", @"Logout"];
    cell.textLabel.text = titles[indexPath.row];
    
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            UIViewController *homeNavController = [self.storyboard instantiateViewControllerWithIdentifier:HOMENAV_STORYID];
//            UIViewController *contentController = [[UINavigationController alloc]
//                                                   initWithRootViewController:homeController];
            [self.sideMenuController setContentController:homeNavController animated:YES];
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
//            UIViewController *topSpotsController = [self.storyboard instantiateViewControllerWithIdentifier:CHECKTOP_STORYID];
//            UIViewController *topNavController = [[UINavigationController alloc] initWithRootViewController:topSpotsController];
//            [self.sideMenuController setContentController:topNavController animated:YES];
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            
            [[self sideMenuController] hideMenuAnimated:NO];            
            [[self sideMenuController].navigationController popToRootViewControllerAnimated:YES];
//            [[self sideMenuController].navigationController popViewControllerAnimated:YES];
        }
            break;
        
        default:
            break;
    }
}

@end
