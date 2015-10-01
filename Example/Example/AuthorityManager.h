//
//  AuthorityManager.h
//  Example
//
//  Created by jtian on 9/18/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import <Foundation/Foundation.h>

//-- 登录完成回调Block
typedef void (^LoginCompletionBlock)(BOOL success, NSString *errorMsg);
//-- 登出完成回调Block
typedef void (^LogoutCompletionBlock)(BOOL success, NSString *errorMsg);

extern NSString * const LOGIN_SUCCESS;
extern NSString * const LOGOUT_SUCCESS;

@interface AuthorityManager : NSObject

- (void)loginWithAccount:(NSString *)account password:(NSString *)password completionBlock:(LoginCompletionBlock)completionBlock;

- (void)logoutWithCompletionBlock:(LogoutCompletionBlock)completionBlock;

@end
