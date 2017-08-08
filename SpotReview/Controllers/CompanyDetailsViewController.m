//
//  CompanyDetailsViewController.m
//  SpotReview
//
//  Created by lion on 11/26/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "CompanyDetailsViewController.h"
#import "CompanyDetailTableViewCell.h"
#import "SRSpotDetailObject.h"

#import "APIService.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "SessionManager.h"

@interface CompanyDetailsViewController () <UITableViewDataSource, UITableViewDelegate, CompanyDetailTableViewCellDelegate> {
    IBOutlet UITableView *detailTableView;
    IBOutlet UIScrollView *imageScrollView;
    IBOutlet UIImageView *scaledImageView;
    
    NSMutableArray *spotDetailsArray;
    UIImage *selectedImage;
}

@end

@implementation CompanyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    spotDetailsArray = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *scaledImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onScaledScroll)];
    [scaledImageGesture setNumberOfTouchesRequired:1];
    [imageScrollView addGestureRecognizer:scaledImageGesture];
    
    float minScale = imageScrollView.frame.size.width / scaledImageView.frame.size.width;
    [imageScrollView setZoomScale:minScale animated:YES];
    imageScrollView.minimumZoomScale = 1.0;
    imageScrollView.maximumZoomScale = 6.0;
    
    [imageScrollView setScrollEnabled:YES];
    [imageScrollView layoutIfNeeded];
    [imageScrollView setHidden:YES];
    
    [self loadDatas];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = self.spotItem.spotCompanyName;
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadDatas {
    
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    [infoDic setObject:self.spotItem.spotCompanyName forKey:@"company_name"];
    
    NSString *url;
    if (self.isFromReview) {
        url = API_GET_COMPANYDETAILS_FORUSER;
        [infoDic setObject:[NSString stringWithFormat:@"%ld", [SessionManager currentSession].userInfo.userId] forKey:@"user_id"];
    } else {
        url = API_GET_COMPANYDETAILS;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APIService makeApiCallWithMethodUrl:url andRequestType:RequestTypePost andPathParams:nil andQueryParams:infoDic resultCallback:^(NSObject *result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            NSArray *details = [[NSArray alloc] init];
            details = [dic objectForKey:@"object"];
            
            for (int i = 0; i < details.count; i ++) {
                NSDictionary *detailItemDic = [details objectAtIndex:i];
                SRSpotDetailObject *detailItem = [[SRSpotDetailObject alloc] initWithDictionary:detailItemDic];
                [spotDetailsArray addObject:detailItem];
            }
            
            [detailTableView reloadData];
            
        } else {
            
            [SRConstant UIAlertViewShow:@"There are no spots." withTitle:nil];
        }
        
    } faultCallback:^(NSError *fault) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view endEditing:NO];
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SRSpotDetailObject *detailItem = [spotDetailsArray objectAtIndex:indexPath.row];
    NSString *textViewString = detailItem.spotDescription;
    CGFloat textViewWidth = 300.0f;
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
    
    CGSize textViewSize = CGSizeMake(textViewWidth, 10000);
    textViewSize.height = [textViewString sizeWithFont:font constrainedToSize:textViewSize lineBreakMode:UILineBreakModeWordWrap].height;
    
    return 320 + textViewSize.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return spotDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"companyDetailIdentifier";
    CompanyDetailTableViewCell *cell = (CompanyDetailTableViewCell *)[detailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[CompanyDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    
    SRSpotDetailObject *detailItem = [spotDetailsArray objectAtIndex:indexPath.row];
    NSURL *avatarUrl = [NSURL URLWithString:detailItem.userAvatarPath];
    [cell.userAvatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar_temp"]];
    cell.userNameLabel.text = detailItem.userName;
//    
//    NSString *timeLabel = [detailItem.spotCreatedDate substringWithRange:NSMakeRange(5, 5)];
//    timeLabel = [timeLabel stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
//    cell.timeLabel.text = timeLabel;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [[NSDate alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    date = [dateFormatter dateFromString:detailItem.spotCreatedDate];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    
    if (detailItem.postStatus == SRGoodStatus) {
        cell.ratingLabel.text = @"GOOD";
        cell.ratingLabel.textColor = UIColorFromRGB(0x008000);
    } else {
        cell.ratingLabel.text = @"BAD";
        cell.ratingLabel.textColor = UIColorFromRGB(0xBF0302);
    }
    
    [cell.companyImageView setImageWithURL:[NSURL URLWithString:detailItem.companyImagePath] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.commentTextView.text = detailItem.spotDescription;
    
    NSString *textViewString = detailItem.spotDescription;
    CGFloat textViewWidth = 300.0f;
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14.0f];
    
    CGSize textViewSize = CGSizeMake(textViewWidth, 10000);
    [cell.commentTextView setFrame:CGRectMake(10, 288, 300, [textViewString sizeWithFont:font constrainedToSize:textViewSize lineBreakMode:UILineBreakModeCharacterWrap].height + 30)];
    NSLog(@"TEXTVIEW HEIGHT  %f", cell.commentTextView.frame.size.height);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CompanyDetailTableViewCellDelegate
- (void)didClickImage:(NSInteger)index {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [imageScrollView setHidden:NO];
    
    UIImage *image;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    CompanyDetailTableViewCell *tableCell = (CompanyDetailTableViewCell *)[detailTableView cellForRowAtIndexPath:indexPath];
    image = tableCell.companyImageView.image;
    NSData *imageData1 = UIImagePNGRepresentation(image);
    NSData *imageData2 = UIImagePNGRepresentation([UIImage imageNamed:@"placeholder"]);
    
    if (imageData1.length == imageData2.length) {
        NSLog(@"Image PlaceHolder");
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2, 20, 20)];
        [indicator setTintColor:[UIColor whiteColor]];
        [imageScrollView addSubview:indicator];
        [indicator startAnimating];
        
        SRSpotDetailObject *detailItem = [spotDetailsArray objectAtIndex:indexPath.row];
        NSURL *companyImageUrl = [NSURL URLWithString:detailItem.companyImagePath];
        
        [scaledImageView setImageWithURLRequest:[NSURLRequest requestWithURL:companyImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [indicator stopAnimating];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [indicator stopAnimating];
        }];
    } else {
        NSLog(@"Image Not PlaceHolder");
        [scaledImageView setImage:image];
    }
    
    
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scaledImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect cFrame = scaledImageView.frame;
    
    cFrame.origin = CGPointZero;
    scaledImageView.frame = cFrame;
    
    [imageScrollView setContentSize:CGSizeMake(scaledImageView.frame.size.width, scaledImageView.frame.size.height)];
}

- (void)onScaledScroll {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [imageScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [scaledImageView setFrame:CGRectMake(0, 0, imageScrollView.contentSize.width, imageScrollView.contentSize.height)];
    [UIView animateWithDuration:0.3 animations:^{
        [imageScrollView setHidden:YES];
    }];
}

@end
