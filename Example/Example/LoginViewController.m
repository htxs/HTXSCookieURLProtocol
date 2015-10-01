//
//  LoginViewController.m
//  Example
//
//  Created by jtian on 9/9/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import "LoginViewController.h"
#import "CookiesManager.h"
#import "AuthorityManager.h"
#import "NSString+HTXS.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UITextField *accountTextField;
@property (nonatomic, weak) IBOutlet UITextField *passportTextField;
@property (nonatomic, weak) IBOutlet UILabel *tipLabel;

@end

@implementation LoginViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipLabel.alpha = 0.0;
    self.accountTextField.tintColor = [UIColor colorWithRed:240.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1];
    self.passportTextField.tintColor = [UIColor colorWithRed:240.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Actions
- (IBAction)dismissLoginViewController:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginAction:(id)sender {
    NSString *account = self.accountTextField.text;
    NSString *password = self.passportTextField.text;
    if (account.length == 0) {
        [self showErrorWithTip:@"请输入帐号"];
        return;
    }
    if (password.length == 0) {
        [self showErrorWithTip:@"请输入密码"];
        return;
    }
    
    [[AuthorityManager alloc] loginWithAccount:account password:password completionBlock:^(BOOL success, NSString *errorMsg) {
        [self showErrorWithTip:errorMsg];
        if (success) {
            [self.view endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
            }];
        }
    }];
}

#pragma mark - Private Methods
- (void)showErrorWithTip:(NSString *)tip {
    self.tipLabel.text = tip;
    [UIView animateWithDuration:0.25 animations:^{
        self.tipLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:3 options:UIViewAnimationOptionTransitionNone animations:^{
            self.tipLabel.alpha = 0.0;
        } completion:nil];
    }];
}

@end
