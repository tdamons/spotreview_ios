//
//  MenuTableViewController.m
//  SpotReview
//
//  Created by lion on 10/28/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "MenuTableViewController.h"
#import "MainViewController.h"
#import "CheckTopViewController.h"
#import "PostCheckViewController.h"
#import "SessionManager.h"
#import "FHSTwitterEngine.h"
#import "UIImageView+AFNetworking.h"
#import "ProfileViewController.h"
#import "ProfileEditViewController.h"
#import "ReviewListViewController.h"
#import "SearchViewController.h"
#import "EnterCampaignViewController.h"
#import "AboutUsViewController.h"
#import "CampaignModeViewController.h"
#import "ContactUsViewController.h"
#import "BuyServiceViewController.h"

#import <MessageUI/MessageUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface MenuTableViewController () <ProfileEditViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    NSArray *titles;
    UIImageView *imageView;
}

@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    titles = @[@"Home", @"My Profile", @"My Reviews", @"Top Spots",@"Search", @"Campaign Mode", @"About Us", @"Contact Us", @"Our Services", @"Logout"];
    
    [self.tableView setContentSize:self.view.frame.size];
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 164.0f)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, 61, 61)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self showUserProfileImage];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2 + 1;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 1.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 125, 0, 24)];
        label.text = [SessionManager currentSession].userInfo.userName;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
    
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
}

- (void)showUserProfileImage {
    NSURL *imageUrl= [NSURL URLWithString:[SessionManager currentSession].userInfo.userAvatarPath];  
    
    [imageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"avatar_temp"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeCurrentUser {
    [SessionManager currentSession].userInfo = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USEREMAIL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SR_CURRENT_USER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    
    [[FHSTwitterEngine sharedEngine] clearAccessToken];
}

#pragma mark - MessageUI
- (void)showSMS {
    
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"support@spotreview.com"];
    NSArray *recipents = @[message];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    
    if (indexPath.row == 0) {
        [SessionManager currentSession].campaignMode = SRNormal;
        MainViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:HOME_STORYID];
        [navigationController setViewControllers:@[homeViewController] animated:YES];
        
    } else if (indexPath.row == 1) {
        if ([SessionManager currentSession].userInfo.userType == SRUserEmail) {
            
        } else if ([SessionManager currentSession].userInfo.userType == SRUserFacebook) {
            
        } else {
            
        }
        ProfileViewController *profileController = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_STORYID];
        [navigationController setViewControllers:@[profileController] animated:YES];
        
    } else if (indexPath.row == 2) {
        ReviewListViewController *listController = [self.storyboard instantiateViewControllerWithIdentifier:REVIEWLIST_STORYID];
        [navigationController setViewControllers:@[listController] animated:YES];
        
    } else if (indexPath.row == 3) {
        CheckTopViewController *topSpotController = [self.storyboard instantiateViewControllerWithIdentifier:CHECKTOP_STORYID];
        [navigationController setViewControllers:@[topSpotController] animated:YES];
        
    } else if (indexPath.row == 4) {
        SearchViewController *searchController = [self.storyboard instantiateViewControllerWithIdentifier:SEARCH_STORYID];
        [navigationController setViewControllers:@[searchController] animated:YES];
        
    } else if (indexPath.row == 5) {
        [SessionManager currentSession].campaignMode = SRCampaign;

        CampaignModeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:CAMPAIGNMODE_STORYID];
        [navigationController setViewControllers:@[controller] animated:YES];
    } else if (indexPath.row == 6) {
        AboutUsViewController *aboutController = [self.storyboard instantiateViewControllerWithIdentifier:ABOUT_STORYID];
        [navigationController setViewControllers:@[aboutController] animated:YES];
    } else if (indexPath.row == 7) {
//        [self showSMS];
        ContactUsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:CONTACTUS_STORYID];
        controller.isFromBuy = NO;
        [navigationController setViewControllers:@[controller] animated:YES];
    } else if (indexPath.row == 8) {
        BuyServiceViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:BUYSERVICE_STORYID];
        [navigationController setViewControllers:@[controller] animated:YES];
    } else if (indexPath.row == 9) {
        [self removeCurrentUser];
        [self.frostedViewController.menuViewController.navigationController popViewControllerAnimated:NO];
    }
    
    [self.frostedViewController hideMenuViewController];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = titles[indexPath.row];
    
    return cell;
}

#pragma mark - ProfileEditViewControllerDelegate
- (void)imageUpdated {
    [self showUserProfileImage];
}

@end
