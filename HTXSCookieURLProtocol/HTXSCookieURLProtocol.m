//
//  HTXSCookieURLProtocol.m
//  htxs.me
//
//  Created by jtian on 9/8/15.
//  Copyright (c) 2015 htxs.me. All rights reserved.
//

#import "HTXSCookieURLProtocol.h"

static NSString *HTXSCookieHeader = @"X-HTXSCookie";

#pragma mark - HTXSCookieConfiguration Interface
@interface HTXSCookieConfiguration : NSObject <HTXSCookieConfiguration>

- (NSString *)cookieHeaderForHostName:(NSString *)hostName;

@end

#pragma mark - HTXSCookieURLProtocol Interface
@interface HTXSCookieURLProtocol () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

#pragma mark - HTXSCookieURLProtocol Implementation
@implementation HTXSCookieURLProtocol

+ (HTXSCookieConfiguration *)sharedConfiguration {
    
    static HTXSCookieConfiguration * _sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[HTXSCookieConfiguration alloc] init];
    });
    
    return _sharedConfiguration;
}

+ (void)configureCookieWithBlock:(void (^)(id <HTXSCookieConfiguration> configuration))block {
    if (block) {
        block([self sharedConfiguration]);
    }
}

#pragma mark - NSURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    BOOL httpScheme = [[[request URL] scheme] caseInsensitiveCompare:@"http"] == NSOrderedSame;
    BOOL httpsScheme = [[[request URL] scheme] caseInsensitiveCompare:@"https"] == NSOrderedSame;
    BOOL seeCookieHeaderFlag = [request valueForHTTPHeaderField:HTXSCookieHeader] == nil;
    if ((httpScheme || httpsScheme) && seeCookieHeaderFlag) {
        return [[[self class] sharedConfiguration] cookieHeaderForHostName:[[request URL] host]] != nil;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    [mutableRequest setValue:@"YES" forHTTPHeaderField:HTXSCookieHeader];
    NSString *cookieHeader = [[[self class] sharedConfiguration] cookieHeaderForHostName:[[mutableRequest URL] host]];
    if (cookieHeader) {
        [mutableRequest setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:mutableRequest delegate:self startImmediately:YES];
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    
    if (response != nil) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
        [redirectableRequest setValue:nil forHTTPHeaderField:HTXSCookieHeader];
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        return redirectableRequest;
    }
    else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:(NSURLCacheStoragePolicy)[[self request] cachePolicy]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

@end

#pragma mark - HTXSCookieConfiguration Interface
@interface HTXSCookieConfiguration ()

@property (nonatomic, strong) NSMutableArray *mutableCookies;
@property (nonatomic) dispatch_queue_t concurrentQueue;

@end

#pragma mark - HTXSCookieConfiguration Implementation
@implementation HTXSCookieConfiguration

- (instancetype)init {
    
    if (self = [super init]) {
        self.mutableCookies = [NSMutableArray array];
        self.concurrentQueue = dispatch_queue_create("me.htxs.cookieconfiguration.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (NSString *)cookieHeaderForHostName:(NSString *)hostName {
    
    if (!hostName || hostName.length == 0) {
        return nil;
    }
    
    NSString *cookieHeader = nil;
    NSArray *cookies = [self cookies];
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain rangeOfString:hostName].location != NSNotFound ||
            [hostName rangeOfString:cookie.domain].location != NSNotFound) {
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

#pragma mark - HTXSCookieConfiguration Protocol
- (NSArray *)cookies {
    
    __block NSArray *cookies = nil;
    dispatch_sync(self.concurrentQueue, ^{
        cookies = [self.mutableCookies copy];
    });
    
    return cookies;
}

- (void)setCookies:(NSArray *)cookies {
    
    dispatch_barrier_sync(self.concurrentQueue, ^{
        if (!cookies || ![cookies isKindOfClass:[NSArray class]] || cookies.count == 0) {
            [self.mutableCookies removeAllObjects];
        }
        else {
            self.mutableCookies = [NSMutableArray arrayWithArray:cookies];
        }
    });
}

@end
