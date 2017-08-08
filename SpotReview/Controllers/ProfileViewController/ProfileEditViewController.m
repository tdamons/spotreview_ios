//
//  ProfileEditViewController.m
//  SpotReview
//
//  Created by lion on 11/17/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "SessionManager.h"
#import "MBProgressHUD.h"
#import "APIService.h"
#import "UIImageView+AFNetworking.h"
#import "SRConstant.h"

#import <AWSS3.h>

@interface ProfileEditViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
    UIView *securityDropView;
    UITableView *securityTableView;
    NSArray *questionArray;
    UISwipeGestureRecognizer *swipeRecognizer;

    IBOutlet UIView *commentView;
    IBOutlet UIImageView *userAvatarImageView;
    IBOutlet UITextField *userNameTextField;
    IBOutlet UITextField *userEmailTextField;
    IBOutlet UITextField *userTelNumberTextField;
    IBOutlet UITextField *userSecQuestionTextField;
    IBOutlet UITextField *userAnswerTextField;
    IBOutlet UITextField *userNewPasswordTextField;
    IBOutlet UITextField *userConfirmPasswordTextField;
    IBOutlet UIView *securityView;
    
    IBOutlet UIButton *saveChangeBtn;
}

@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Update Profile";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    userAvatarImageView.layer.masksToBounds = YES;
    userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2 + 1;
    userAvatarImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    userAvatarImageView.layer.borderWidth = 1.0f;
    userAvatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    userAvatarImageView.layer.shouldRasterize = YES;
    userAvatarImageView.clipsToBounds = YES;
    
    saveChangeBtn.layer.borderColor = UIColorFromRGB(0xBF0302).CGColor;
    saveChangeBtn.layer.borderWidth = 1.0f;
    saveChangeBtn.layer.masksToBounds = YES;
    saveChangeBtn.layer.cornerRadius = 5.0;
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipDown:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [commentView addGestureRecognizer:swipeRecognizer];
    
    securityDropView = [[UIView alloc] init];
    securityTableView = [[UITableView alloc] init];
    
    securityTableView.delegate = self;
    securityTableView.dataSource = self;
    questionArray =  @[@"Your pet's name?", @"Your mother's name?", @"Your favorite animal?", @"Your favorite food?", @"Your favorite car?"];
    [securityDropView setFrame:CGRectMake(userSecQuestionTextField.frame.origin.x, userSecQuestionTextField.frame.origin.y, userSecQuestionTextField.frame.size.width, 101)];
    [securityDropView setBackgroundColor:[UIColor whiteColor]];
    securityDropView.layer.borderWidth = 1.0f;
    securityDropView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    [commentView addSubview:securityDropView];
    [securityDropView addSubview:securityTableView];
    [securityDropView setHidden:YES];
}

- (void)viewLayout {
    NSURL *avatarUrl = [NSURL URLWithString:[SessionManager currentSession].userInfo.userAvatarPath];
    
    [userAvatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar_temp"]];
    
    userNameTextField.text = [SessionManager currentSession].userInfo.userName;
    userEmailTextField.text = [SessionManager currentSession].userInfo.email;
    userTelNumberTextField.text = [SessionManager currentSession].userInfo.userTelNumber;
    userSecQuestionTextField.text = [SessionManager currentSession].userInfo.userSecQuestion;
    userAnswerTextField.text = [SessionManager currentSession].userInfo.userAnswer;
    
    if ([userEmailTextField.text isEqualToString:@""]) {
        userEmailTextField.placeholder = @"email";
    }
    if ([userTelNumberTextField.text isEqualToString:@""]) {
        userTelNumberTextField.placeholder = @"TelNumber";
    }
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showQuestions:(UITextField *)textField {
    
    [securityDropView setHidden:NO];
    [securityDropView setFrame:CGRectMake(textField.frame.origin.x - 10, textField.frame.origin.y + 21, textField.frame.size.width + 20, 0)];
    [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(textField.frame.origin.x - 10, textField.frame.origin.y + 21, textField.frame.size.width + 20, 101)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, securityDropView.frame.size.height)];
        
    } completion:nil];
}

- (void)handleSwipDown:(id)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.4 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    }];
}

- (void)submitToWebService:(NSString *)imageName {
    NSMutableDictionary *photoDic = [[NSMutableDictionary alloc] init];
    NSInteger userId = [SessionManager currentSession].userInfo.userId;
    NSString *photoName = [NSString stringWithFormat:@"%@%@", kS3AvatarImagePath, imageName];
    
    [photoDic setObject:[NSString stringWithFormat:@"%ld", (long)userId] forKey:@"user_id"];
    [photoDic setObject:photoName forKey:@"user_avatarpath"];
    
    [self updateUser:photoDic];
}

- (void)updateUser:(NSMutableDictionary *)userDic {
    [APIService makeApiCallWithMethodUrl:API_UPDATE_USER andRequestType:RequestTypePost andPathParams:nil andQueryParams:userDic resultCallback:^(NSObject *result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *dic = (NSDictionary *)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            NSDictionary *userInfoDic = [dic objectForKey:@"object"];
            SRUser *userInfo = [[SRUser alloc] initWithDictionary:userInfoDic];
            [SessionManager currentSession].userInfo = userInfo;
            [self.delegate imageUpdated];
            [self viewLayout];
        } else {
            [SRConstant UIAlertViewShow:@"Server Error" withTitle:nil];
        }
    } faultCallback:^(NSError *fault) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [SRConstant UIAlertViewShow:@"Connection Error" withTitle:nil];
    }];
}

- (NSString *)savePhoto:(UIImage *)imgPhoto {
    if (imgPhoto == nil)
        return nil;
    
    NSData *imageData = UIImageJPEGRepresentation(imgPhoto, 0.8f);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"avatar.jpg"];
    
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

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Uploading...";
    
    UIImage *avatarImage = info[UIImagePickerControllerEditedImage];
    NSString *strFilePath = [self savePhoto:avatarImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        // Upload
        NSUInteger fileSize = (NSUInteger)[self getFileSize:strFilePath];
        __block int64_t uploadedSize = 0;
        AWSNetworkingUploadProgressBlock progressProc = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadedSize += bytesSent;
                hud.progress = (CGFloat)uploadedSize / (CGFloat)fileSize;
            });
        };
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = kAvatarImageBucket;
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
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:task.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                    alertView = nil;
                    [picker dismissViewControllerAnimated:YES completion:nil];
                });
            } else if (task.result != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self submitToWebService:imageName];
                    [picker dismissViewControllerAnimated:YES completion:nil];
                });
            }
            return nil;
        }];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideSecurityDropView {
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(userSecQuestionTextField.frame.origin.x - 10, userSecQuestionTextField.frame.origin.y + 21, userSecQuestionTextField.frame.size.width + 20, 0)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
        [self.view endEditing:YES];
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == userSecQuestionTextField) {
        [self.view endEditing:YES];
        [self showQuestions:textField];
        return NO;
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == userNewPasswordTextField || textField == userConfirmPasswordTextField) {
        [UIView animateWithDuration:0.4 animations:^{
            commentView.center = CGPointMake(self.view.center.x, self.view.center.y - 150);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == userNewPasswordTextField) {
        [userConfirmPasswordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideSecurityDropView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideSecurityDropView];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return questionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"QuestionCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [questionArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    userSecQuestionTextField.text = [questionArray objectAtIndex:indexPath.row];
    [self hideSecurityDropView];
}

#pragma mark - UIButtonEvents
- (IBAction)onSaveChangeProfile:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self hideSecurityDropView];
    
    NSInteger userId = [SessionManager currentSession].userInfo.userId;
    NSString *userName = userNameTextField.text;
    NSString *userEmail = userEmailTextField.text;
    NSString *userNewPassword = userNewPasswordTextField.text;
    NSString *userMobileNumber = userTelNumberTextField.text;
    NSString *userSecQuestion = userSecQuestionTextField.text;
    NSString *userAnswer = userAnswerTextField.text;
    
    NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
    [userDic setObject:[NSString stringWithFormat:@"%ld", (long)userId] forKey:@"user_id"];
    
    if (userName.length) {
        [userDic setObject:userName forKey:@"user_name"];
    }
    if (userEmail.length && [SRConstant NSStringIsValidEmail:userEmail]) {
        [userDic setObject:userEmailTextField.text forKey:@"user_email"];
    }
    if (userNewPassword.length && [userNewPassword isEqualToString:userConfirmPasswordTextField.text]) {
        [userDic setObject:userNewPassword forKey:@"user_password"];
    }
    if (userMobileNumber.length && [SRConstant validatePhone:userMobileNumber]) {
        [userDic setObject:userMobileNumber forKey:@"user_mobilenumber"];
    }
    if (userSecQuestion.length) {
        [userDic setObject:userSecQuestion forKey:@"user_secquestion"];
    }
    if (userAnswer.length) {
        [userDic setObject:userAnswer forKey:@"user_answer"];
    }
    
    [self updateUser:userDic];
}

- (IBAction)onUserImageBtn:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}


@end
