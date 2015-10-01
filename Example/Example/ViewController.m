//
//  ViewController.m
//  Example
//
//  Created by jtian on 9/8/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import "ViewController.h"
#import "CookiesManager.h"
#import "AuthorityManager.h"
#import "NSString+HTXS.h"

NSString * const URL_SCHEME = @"htxs://";

#pragma mark - ViewController Interface
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, copy) NSString *callback;

@end

#pragma mark - ViewController Implementation
@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //-- 注册登录通知，刷新页面
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusNotification:)
                                                 name:LOGIN_SUCCESS
                                               object:nil];
    //-- 注册退出通知，刷新页面
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStatusNotification:)
                                                 name:LOGOUT_SUCCESS
                                               object:nil];
    
    //-- 加载本地静态服务中的网页
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://htxs.me/pages/view/index.html"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - NSNotification 
- (void)loginStatusNotification:(NSNotification *)notification {
    //-- 登录成功，如果有带callback参数，则执行callback；未带callback参数，则刷新网页
    if (self.callback) {
        [self evaluatCallback];
    }
    else {
        [self.webView reload];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *openURL = [request URL];
    //-- 优先处理请求中的callback，有该参数则保存到callback属性
    NSString *url = openURL.absoluteString; //-- URL请求地址
    if ([url hasPrefix:URL_SCHEME]) { //-- 处理客户端协议
        if ([url hasPrefix:[NSString stringWithFormat:@"%@userLogin", URL_SCHEME]]) { //-- 登录、注销协议
            NSDictionary *queryParameters = [openURL.query htxs_URLParameterDictionary]; //-- 请求参数
            if (queryParameters[@"callback"]) {
                self.callback = queryParameters[@"callback"];
            }
            else {
                self.callback = nil;
            }
            
            //-- 拉起登录页
            [self performSegueWithIdentifier:@"LoginViewControllerSegue" sender:self];
            
            return NO;
        }
        else if ([url hasPrefix:[NSString stringWithFormat:@"%@userLogout", URL_SCHEME]]) { //-- 注销协议
            NSDictionary *queryParameters = [openURL.query htxs_URLParameterDictionary]; //-- 请求参数
            if (queryParameters[@"callback"]) {
                self.callback = queryParameters[@"callback"];
            }
            else {
                self.callback = nil;
            }
            
            [[AuthorityManager alloc] logoutWithCompletionBlock:^(BOOL success, NSString *errorMsg) {
                if (success) {
                    [[[UIAlertView alloc] initWithTitle:@"退出通知"
                                                message:errorMsg
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil] show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_SUCCESS object:nil];
                }
            }];
        }
    }
    else {
        self.callback = nil;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *documentTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = documentTitle;
}

#pragma mark - Private Methods
- (void)evaluatCallback {
    if (self.callback) {
        NSString *session = [[CookiesManager sharedInstance] cookieHeaderForHostName:self.webView.request.URL.host];
        NSString *callbackFunction = [NSString stringWithFormat:@"%@('%@');", self.callback, session];
        [self.webView stringByEvaluatingJavaScriptFromString:callbackFunction];
    }
}

@end
