<p>
    <a href="http://cocoadocs.org/docsets/HTXSCookieURLProtocol"><img src="https://img.shields.io/cocoapods/v/HTXSCookieURLProtocol.svg?style=flat"></a> 
</p>

# HTXSCookieURLProtocol

## 使用场景：

客户端与 UIWebView 中的 HTML 页面需要同步登录态时，如果客户端登录后，进入 HTML 页面则不用重新登录。该项目适用于登录态采用 Cookies 机制。

## 实现原理

引用的一段来自 [http://www.raywenderlich.com/](http://www.raywenderlich.com/59982/nsurlprotocol-tutorial) 教程中的话：

```html
NSURLProtocol is like a magic key to the URL. It lets you redefine how Apple’s URL Loading System operates, by defining custom URL schemes and redefining the behavior of existing URL schemes.
```

该项目通过子类 NSURLProtocol 实现 URL 加载时，向符合条件的 URL 注入本地已保存的 Cookies 已达到同步登录态的作用。
另外一篇是 [Mattt 大神关于 NSURLProtocol 的文章](http://nshipster.com/nsurlprotocol/)。


## Example

```objective-c
#import "HTXSCookieURLProtocol.h"
```

尽早地在 AppDelegate 注册 NSURLProtocol 子类。

```objective-c
// Register NSURLProtocol
[NSURLProtocol registerClass:[HTXSCookieURLProtocol class]];
[HTXSCookieURLProtocol configureCookieWithBlock:^(id<HTXSCookieConfiguration> configuration) {
        // Init Config Cookies
        [configuration setCookies:[[CookiesManager sharedInstance] getCookies]];
    }];
```

## Nginx + PHP

示例项目中包括 `Authority.php` 和 `index.html` 文件用于测试客户端与 UIWebView 中同步登录态。需要搭建 Nginx 和 PHP 环境，我也是通过 [这篇教程](http://segmentfault.com/a/1190000000606752) 从 0 到 1 搭建的环境。最后使用了 [CodeIgniter](http://codeigniter.org.cn/user_guide/) 配置了 RESTful 接口用于测试。

## Installation

Feel free to drag `HTXSCookieURLProtocol.h` and `HTXSCookieURLProtocol.m` to your iOS Project. But it's recommended to use CocoaPods.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ [sudo] gem install cocoapods
```

To integrate HTXSCookieURLProtocol into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

pod 'HTXSCookieURLProtocol', '~> 0.0.1'
```

Then, run the following command:

```bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).

## License

HTXSCookieURLProtocol is available under the MIT license. See the LICENSE file for more info.
