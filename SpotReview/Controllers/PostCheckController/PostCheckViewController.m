//
//  PostCheckViewController.m
//  SpotReview
//
//  Created by lion on 10/22/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "PostCheckViewController.h"
#import "SessionManager.h"
#import "ImageCheckViewController.h"
#import "SRPostData.h"

@interface PostCheckViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIImage *postedImage;
}

@end

@implementation PostCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"TAKE PICTURE";
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

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    postedImage = info[UIImagePickerControllerOriginalImage];
    
//    ImageCheckViewController *imageCheckController = [self.storyboard instantiateViewControllerWithIdentifier:@"imageCheckController"];
//    imageCheckController.checkImage = postedImage;
//    [picker pushViewController:imageCheckController animated:YES];
    
    if ([SessionManager currentSession].postData == nil) {
        SRPostData *postedData = [[SRPostData alloc] init];
        [SessionManager currentSession].postData = postedData;
    } else {
        [[SessionManager currentSession] initPostedData];
    }
    
    [SessionManager currentSession].postData.postedImage = postedImage;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"rateIdentifier" sender:nil];
    }];
}

#pragma ButtonEvents
- (IBAction)onTakePicture:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
