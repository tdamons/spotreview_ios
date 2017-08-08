//
//  ForgotPasswordViewController.m
//  SpotReview
//
//  Created by lion on 10/22/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIView *emailView;
    IBOutlet UITextField *emailTextField;
    IBOutlet UIView *secQuestionView;
    IBOutlet UITextField *secQuestionTextField;
    IBOutlet UIView *answerView;
    IBOutlet UITextField *answerTextField;
    
    IBOutlet UIButton *sendBtn;
    
    UIView *securityDropView;
    UITableView *securityTableView;
    NSArray *questionArray;
}

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self viewLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    securityDropView = [[UIView alloc] init];
    securityTableView = [[UITableView alloc] init];
    
    securityTableView.delegate = self;
    securityTableView.dataSource = self;
    questionArray =  @[@"Your pet's name?", @"Your mother's name?", @"Your favorite animal?", @"Your favorite food?", @"Your favorite car?"];
    [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y, secQuestionView.frame.size.width, 101)];
    [securityDropView setBackgroundColor:[UIColor whiteColor]];
    securityDropView.layer.borderWidth = 1;
    securityDropView.layer.borderColor = [[UIColor blackColor] CGColor];
    [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    [self.view addSubview:securityDropView];
    [securityDropView addSubview:securityTableView];
    [securityDropView setHidden:YES];
}

- (void)viewLayout {
    
    [[emailView layer] setBorderWidth:1.0f];
    [[emailView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[secQuestionView layer] setBorderWidth:1.0f];
    [[secQuestionView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[answerView layer] setBorderWidth:1.0f];
    [[answerView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[sendBtn layer] setBorderWidth:1.0f];
    [[sendBtn layer] setBorderColor:[UIColor blackColor].CGColor];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showQuestions:(UITextField *)textField {
    
    [securityDropView setHidden:NO];
    [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 35, secQuestionView.frame.size.width, 0)];
    [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 35, secQuestionView.frame.size.width, 101)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, securityDropView.frame.size.height)];
    } completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == emailTextField) {
        [secQuestionTextField becomeFirstResponder];
    } else if (textField == secQuestionTextField) {
        [answerTextField becomeFirstResponder];
    } else {
        [answerTextField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == secQuestionTextField) {
        [self.view endEditing:YES];
        [self showQuestions:textField];
        return NO;
    } else {
        return YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 36, secQuestionView.frame.size.width, 0)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    } completion:nil];
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
    
    secQuestionTextField.text = [questionArray objectAtIndex:indexPath.row];
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 36, secQuestionView.frame.size.width, 0)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)onSend:(id)sender {
    
}


@end
