//
//  CookiesManager.m
//  Example
//
//  Created by jtian on 9/9/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import "CookiesManager.h"
#import "HTXSCookieURLProtocol.h"

NSString * const HTXS_TOKEN = @"HTXS_TOKEN";
NSString * const USERDEFAULTSCOOKIE = @"USERDEFAULTSCOOKIE";

@implementation CookiesManager

+ (instancetype)sharedInstance {
    static CookiesManager *_sharedInstance;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[CookiesManager alloc] init];
    });
    return _sharedInstance;
}

- (NSArray *)getCookies {
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTSCOOKIE];
    if (cookiesData) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        return [cookies isKindOfClass:[NSArray class]] ? cookies : nil;
    }
    return nil;
}

- (NSString *)cookieHeaderForHostName:(NSString *)hostName {
    if (!hostName || hostName.length == 0) {
        return nil;
    }
    NSString *cookieHeader = nil;
    NSArray *cookies = [self getCookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([hostName rangeOfString:cookie.domain].location != NSNotFound) {
            NSTimeInterval expiresDate = [cookie.expiresDate timeIntervalSince1970];
            NSString *expires = [@(expiresDate * 1000) stringValue];
            if (!cookieHeader) {
                cookieHeader = [NSString stringWithFormat:@"%@=%@;expires=%@", [cookie name], [cookie value], expires];
            }
            else {
                cookieHeader = [NSString stringWithFormat:@"%@; %@=%@;expires=%@", cookieHeader, [cookie name], [cookie value], expires];
            }
        }
    }
    return cookieHeader;
}

- (void)setCookies:(NSArray *)cookies {
    if (cookies && [cookies isKindOfClass:[NSArray class]]) {
        NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
        if (cookieData) {
            [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:USERDEFAULTSCOOKIE];
        }
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTSCOOKIE];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // HTXSCookieURLProtocol 也需要同步设置Cookie
    [HTXSCookieURLProtocol configureCookieWithBlock:^(id<HTXSCookieConfiguration> configuration) {
        [configuration setCookies:cookies];
    }];
}

@end
