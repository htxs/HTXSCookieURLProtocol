//
//  AuthorityManager.m
//  Example
//
//  Created by jtian on 9/18/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import "AuthorityManager.h"
#import "CookiesManager.h"

NSString * const LOGIN_SUCCESS = @"LOGIN_SUCCESS";
NSString * const LOGOUT_SUCCESS = @"LOGOUT_SUCCESS";

@implementation AuthorityManager

- (void)loginWithAccount:(NSString *)account password:(NSString *)password completionBlock:(LoginCompletionBlock)completionBlock {
    NSAssert(account, @"account can not be nil");
    NSAssert(password, @"account can not be nil");
    NSString *requestString = [NSString stringWithFormat:@"u=%@&p=%@", account, password];
    NSURL *userLoginURL = [NSURL URLWithString:@"http://htxs.me/authority/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userLoginURL];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[NSData dataWithBytes:[requestString UTF8String] length:[requestString length]]];
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               BOOL success = NO;
                               NSString *errorMsg = nil;
                               if (connectionError) { //-- 记录请求错误
                                   NSLog(@"Error: %@", [connectionError localizedDescription]);
                                   success = NO;
                                   errorMsg = [connectionError localizedDescription];
                               }
                               else { //-- 请求成功，处理业务逻辑
                                   if (data) {
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                       success = [json[@"result"] integerValue] == 1;
                                       errorMsg = json[@"msg"] ?: @"Oppos";
                                       if ([json[@"result"] integerValue] == 1) { //-- 登录成功
                                           if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                               NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields]
                                                                                                         forURL:request.URL];
                                               //-- 保存Cookies
                                               [[CookiesManager sharedInstance] setCookies:cookies];
                                           }
                                       }
                                   }
                                   else {
                                       success = NO;
                                       errorMsg = @"接口返回数据格式错误";
                                   }
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (completionBlock) {
                                       completionBlock(success, errorMsg);
                                   }
                               });
                           }];
}

- (void)logoutWithCompletionBlock:(LogoutCompletionBlock)completionBlock {
    NSURL *userLoginURL = [NSURL URLWithString:@"http://htxs.me/authority/logout"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userLoginURL];
    [request setTimeoutInterval:30.0];
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               BOOL success = NO;
                               NSString *errorMsg = nil;
                               if (connectionError) { //-- 记录请求错误
                                   NSLog(@"Error: %@", [connectionError localizedDescription]);
                                   success = NO;
                                   errorMsg = [connectionError localizedDescription];
                               }
                               else { //-- 请求成功，处理业务逻辑
                                   if (data) {
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                       success = [json[@"result"] integerValue] == 1;
                                       errorMsg = json[@"msg"] ?: @"Oppos";
                                       if ([json[@"result"] integerValue] == 1) { //-- 登录成功
                                           //-- 清空本地Cookies
                                           [[CookiesManager sharedInstance] setCookies:nil];
                                       }
                                   }
                                   else {
                                       success = NO;
                                       errorMsg = @"接口返回数据格式错误";
                                   }
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (completionBlock) {
                                       completionBlock(success, errorMsg);
                                   }
                               });
                           }];
}

@end
