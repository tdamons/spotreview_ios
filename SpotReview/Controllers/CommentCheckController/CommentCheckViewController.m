//
//  CommentCheckViewController.m
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "CommentCheckViewController.h"

@interface CommentCheckViewController () {
    IBOutlet UIButton *shareToSocialBtn;
    IBOutlet UITextView *textView;
}

@end

@implementation CommentCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"THANK YOU";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    NSString *multilineString = [NSString stringWithFormat:@"%@ \n%@ \n%@ \n\n%@ \n%@ \n%@ \n\n%@ \n%@", @"We aim to make the world a", @"better place for YOU, the", @"Consumer.", @"So remember, if you paid for", @"it and have something to say", @"Good or Bad", @"Tell the world with", @"SpotReview"];
    textView.text = multilineString;
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onShare:(id)sender {
    [self performSegueWithIdentifier:@"shareIdentifier" sender:sender];
}

- (IBAction)onExit:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    
    [NSThread sleepForTimeInterval:2.0];
    
    exit(0);
}

@end

