//
//  CookiesManager.h
//  Example
//
//  Created by jtian on 9/9/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HTXS_TOKEN;
extern NSString * const USERDEFAULTSCOOKIE;

@interface CookiesManager : NSObject

+ (instancetype)sharedInstance;

- (NSString *)cookieHeaderForHostName:(NSString *)hostName;

- (NSArray *)getCookies;

- (void)setCookies:(NSArray *)cookies;

@end
