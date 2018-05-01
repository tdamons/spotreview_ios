//
//  CommentViewController.m
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "CommentViewController.h"
#import "SessionManager.h"
#import "MBProgressHUD.h"
#import "APIService.h"

#import "AWSS3.h"

@interface CommentViewController () <UITextViewDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    IBOutlet UIView *commentView;
    IBOutlet UIView *titleView;
    IBOutlet UITextField *titleTextField;
    IBOutlet UITextView *commentTextView;
    IBOutlet UIImageView *logoImageView;
    
//    UIButton *shareBtn;
    UISwipeGestureRecognizer *swipeRecognizer;
}

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self viewLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"COMMENT";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [commentView addGestureRecognizer:swipeRecognizer];
}

- (void)viewLayout {
    [[titleView layer] setBorderWidth:1.0f];
    [[titleView layer] setBorderColor:[UIColor blackColor].CGColor];
    
    [[commentTextView layer] setBorderWidth:1.0f];
    [[commentTextView layer] setBorderColor:[UIColor blackColor].CGColor];
    
    if ([SessionManager currentSession].campaignMode == SRCampaign) {
        titleTextField.text = [SessionManager currentSession].campaignData.campaignName;
        [titleTextField setUserInteractionEnabled:NO];
    } else {
        titleTextField.placeholder = @"Add Company / Brand name here...";
        [titleTextField setUserInteractionEnabled:YES];
    }
    
    commentTextView.text = @"Add Comment here...";
    [commentTextView setTextAlignment:NSTextAlignmentCenter];
    [commentTextView setTextColor:[UIColor lightGrayColor]];
    
//    shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(280, 10, 60, 30)];
//    [shareBtn setTitle:@"Share" forState:UIControlStateNormal];
//    [shareBtn addTarget:self action:@selector(onShare:) forControlEvents:UIControlEventTouchUpInside];
//    [shareBtn setHidden:YES];
}

- (void)onShare:(id)sender {
    [self performSegueWithIdentifier:@"commentCheckIdentifier" sender:sender];
}

- (void)handleSwipeDown:(id)sendder {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.4 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    }];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (NSString *)savePhoto:(UIImage *)imgPhoto {
    if (imgPhoto == nil)
        return nil;
    
    NSData *imageData = UIImageJPEGRepresentation(imgPhoto, 0.8f);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"cover.jpg"];
    
    if (![imageData writeToFile:filePath atomically:NO])
        return nil;
    
    return filePath;
}

- (unsigned long long)getFileSize:(NSString *)filePath {
    NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if (fileAttr == nil)
        return (NSUInteger)0;
    
    return fileAttr.fileSize;
}

- (NSString*)getFileKey {
    NSString *timestamp = [NSString stringWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970] * 1000];
    return timestamp;
}

- (void)imageUpload {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Submitting...";
    NSString *strFilePath = [self savePhoto:[SessionManager currentSession].postData.postedImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        // Upload
        NSUInteger fileSize = (NSInteger)[self getFileSize:strFilePath];
        
        __block int64_t uploadedSize = 0;
        AWSNetworkingUploadProgressBlock progressProc = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadedSize += bytesSent;
                hud.progress = (CGFloat)uploadedSize / (CGFloat)fileSize;
            });
        };
        
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = kImageBucket;
        uploadRequest.key = [NSString stringWithFormat:@"%@.jpg", [self getFileKey]];
        uploadRequest.body = [NSURL fileURLWithPath:strFilePath];
        uploadRequest.contentType = @"image/jpg";
        uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
        uploadRequest.uploadProgress = progressProc;
        NSString *imageName = uploadRequest.key;
        [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
            // Do something with the response
            if (task.error != nil) {
                [transferManager cancelAll];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:task.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                    alertView = nil;
                });
            } else if (task.result != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self submitToWebService:imageName];
                });
            }
            return nil;
        }];
    });
}

- (void)submitToWebService:(NSString *)imageName {
    NSMutableDictionary *photoDic = [[NSMutableDictionary alloc] init];
    NSInteger userId = [SessionManager currentSession].userInfo.userId;
    NSString *photoTitle = [SessionManager currentSession].postData.postedTitle;
    NSString *photoContent = [SessionManager currentSession].postData.postedContent;
    NSString *photoName = [NSString stringWithFormat:@"%@%@", kS3ImagePath, imageName];
    SRPostStatus status = [SessionManager currentSession].postData.postStatus;
    
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [photoDic setObject:[NSString stringWithFormat:@"%ld", (long)userId] forKey:@"userId"];
    [photoDic setObject:photoTitle forKey:@"photoTitle"];
    [photoDic setObject:photoContent forKey:@"photoContent"];
    [photoDic setObject:photoName forKey:@"photoUrl"];
    [photoDic setObject:[NSString stringWithFormat:@"%ld", (long)status] forKey:@"status"];
    
    //    [photoDic setObject:[NSString stringWithFormat:@"%f", appDelegate.currentUserLocation.latitude] forKey:@"photo_lat"];
    //    [photoDic setObject:[NSString stringWithFormat:@"%f", appDelegate.currentUserLocation.longitude] forKey:@"photo_long"];
    
    [self postSpot:photoDic];
}

- (void)postSpot:(NSMutableDictionary *)postDic {
    [APIService makeApiCallWithMethodUrl:API_POST andRequestType:RequestTypePost andPathParams:nil andQueryParams:postDic resultCallback:^(NSObject *result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *dic = (NSDictionary *)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        if (resultFlag) {
            
            [[[UIAlertView alloc] initWithTitle:nil message:@"Successfully posted to SpotReview" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
//            [shareBtn setHidden:NO];
        } else {
            [SRConstant UIAlertViewShow:@"Can't post to server" withTitle:nil];
//            [shareBtn setHidden:YES];
        }
    } faultCallback:^(NSError *fault) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SRConstant UIAlertViewShow:@"Connection Error" withTitle:nil];
    }];
}

#pragma mark - ButtonEvents
- (IBAction)onComment:(id)sender {
    if ([titleTextField.text isEqualToString:@""]) {
        [SRConstant UIAlertViewShow:@"Please add company name" withTitle:nil];
    } else if ([commentTextView.text isEqualToString:@"Add Comment here..."] || [commentTextView.text isEqualToString:@""]) {
        [SRConstant UIAlertViewShow:@"Please add comment." withTitle:nil];
    } else {
        [SessionManager currentSession].postData.postedTitle = titleTextField.text;
        [SessionManager currentSession].postData.postedContent = commentTextView.text;
        [self imageUpload];
    }
}

#pragma mark - TextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [commentTextView setTextAlignment:NSTextAlignmentCenter];
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Add Comment here..."]) {
        textView.text = @"";
    }
    
    [textView setTextColor:[UIColor blackColor]];
    [commentTextView setTextAlignment:NSTextAlignmentCenter];
    
    [UIView animateWithDuration:0.4 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y - 90);
    } completion:^(BOOL finished) {
        NSLog(@"Comment Finished");
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    } completion:^(BOOL finished) {
        NSLog(@"Comment Finished");
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:@"commentCheckIdentifier" sender:nil];
}

@end
