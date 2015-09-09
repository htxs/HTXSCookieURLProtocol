//
//  HTXSCookieURLProtocol.h
//  htxs.me
//
//  Created by jtian on 9/8/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTXSCookieConfiguration;

#pragma mark - HTXSCookieURLProtocol Interface
@interface HTXSCookieURLProtocol : NSURLProtocol

+ (void)configureCookieWithBlock:(void (^)(id <HTXSCookieConfiguration> configuration))block;

@end


#pragma mark - HTXSCookieConfiguration Protocol
@protocol HTXSCookieConfiguration <NSObject>

- (void)setCookies:(NSArray *)cookies;

@end
