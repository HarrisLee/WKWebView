//
//  ViewController.m
//  WebSSLDemo
//
//  Created by JianRongCao on 6/2/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "ViewController.h"

static NSString *mallURL = @"http://salepre.cnsuning.com/znjj/sns/1/sns.html?env=PRE";


@interface ViewController ()<UIWebViewDelegate,NSURLConnectionDelegate,UIScrollViewDelegate>
{
    NSMutableDictionary *navigationControl;   //存储是否需要展示导航栏，标题的属性。
}

@property(strong,nonatomic) NSString * htmlPath;
@property(strong,nonatomic) NSURLRequest *request;
@property(strong,nonatomic) NSURLConnection * urlConnection;
@property(assign,nonatomic) BOOL isAuthenticated;


@property (strong,nonatomic) UIProgressView *progressView;

@property (strong,nonatomic) UIWebView *wbview;



@end

@implementation ViewController

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.wbview reload];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    navigationControl = [[NSMutableDictionary alloc] init];

    [self.progressView setHidden:NO];
    [self.view addSubview:self.wbview];
    
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.progressView setHidden:NO];
    [self.progressView setProgress:0];
    
    [UIView animateWithDuration:1.5 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.progressView setProgress:0.9 animated:YES];
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@ \n %@",[webView.request.URL absoluteString],[request.URL absoluteString]);
    NSString *absoultUrl = [request.URL absoluteString];

    
    

    if (!self.isAuthenticated)
    {
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        [self.urlConnection start];
        [webView stopLoading];
        return NO;
    }

    
//    //若请求的网址是禁止的网址，则不请求。
//    if ([absoultUrl hasPrefix:kForbidenURL] || [absoultUrl hasPrefix:kForbidenURL1]) {
//        return NO;
//    }
    
    //若用户退出，则清除所有的Cookie
    if ([absoultUrl hasPrefix:@"https://passport.suning.com/ids/logout"]) {
        
    }
    
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //加载完成
    NSLog(@"%@",@"加载完成");
    [self.progressView setProgress:1.0 animated:YES];
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
    } completion:^(BOOL finished) {
        [self.progressView setProgress:0.0f animated:NO];
        [self.progressView setHidden:YES];
    }];
    
    NSString *absoultString = [webView.request.URL absoluteString];
    
    //当前的URL为商城首页时，且是从其他页面返回回来的时候，触发webView向上移动0.5的距离，使专题推荐动画效果展示
    if([[webView.request.URL absoluteString] isEqualToString:mallURL]){
        if (webView.canGoForward && webView.scrollView.contentOffset.y > 0.5) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [webView.scrollView setContentOffset:CGPointMake(webView.scrollView.contentOffset.x,
                                                                 webView.scrollView.contentOffset.y - 0.5)];
            });
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailProvisionalNavigation   %@",[error debugDescription]);
    
    for (NSString *key in [[error userInfo] allKeys]) {
        NSLog(@"%@",[[error userInfo] valueForKey:key]);
    }
    //对跳转苏宁易购App进行处理，当跳转失败时不展示网络异常界面
    if ([[[error userInfo] valueForKey:NSURLErrorFailingURLStringErrorKey] hasPrefix:@"com.suning.suningebuy"]
        || [[[error userInfo] valueForKey:NSURLErrorFailingURLStringErrorKey] hasPrefix:@"jsbridge"]
        || [[[error userInfo] valueForKey:NSURLErrorFailingURLStringErrorKey] hasPrefix:@"https://passportpre.cnsuning.com/ids/login"]
        || [[[error userInfo] valueForKey:NSURLErrorFailingURLStringErrorKey] hasPrefix:@"about:blank"]) {
        return ;
    }
}

- (void)goBackView
{
    if ([self.wbview canGoBack]) {
        [self.wbview stopLoading];
        [self.wbview goBack];
    }
}


#pragma mark - NURLConnection delegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0)
    {
        self.isAuthenticated = YES;
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    NSLog(@"WebController received response via NSURLConnection");
    
    // remake a webview call now that authentication has passed ok.
    self.isAuthenticated = YES;
    [self loadWebPageWithUrl:self.htmlPath];
    
    // Cancel the URL connection otherwise we double up (webview + url connection, same url = no good!)
    [self.urlConnection cancel];
    self.request = nil;
    self.urlConnection = nil;
}

// We use this method is to accept an untrusted site which unfortunately we need to do, as our PVM servers are self signed.
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)loadWebPageWithUrl:(NSString*)stringURL
{
    NSString * path = [NSString stringWithFormat:@"%@",stringURL];

    NSString* webStringURL = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [NSURLRequest  allowsAnyHTTPSCertificateForHost:webStringURL];

    NSURL * url = [NSURL URLWithString:webStringURL];

    self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.f];

    [self.wbview loadRequest:self.request];
}


/**
 *  WKWebView的非受信证书的的请求方式
 *
 *  @param webView           请求的webView
 *  @param challenge         证书确认
 *  @param completionHandler 处理结果
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    
    NSURLCredential* cred = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
}



- (UIWebView *)wbview
{
    if (!_wbview) {
        _wbview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 375, 667 - 49)];
        _wbview.backgroundColor = [UIColor whiteColor];
        _wbview.dataDetectorTypes = UIDataDetectorTypeNone;
        _wbview.scrollView.backgroundColor = [UIColor whiteColor];
        //设置代理事件以及隐藏滚动条
        _wbview.delegate = self;
        _wbview.scrollView.delegate = self;
        _wbview.scrollView.showsVerticalScrollIndicator = NO;
        //加载商城首页URL
        self.htmlPath = mallURL;
        self.isAuthenticated = NO;
        [self loadWebPageWithUrl:self.htmlPath];
    }
    return _wbview;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 375, 5.0)];
        _progressView.backgroundColor = [UIColor lightGrayColor];
        [self.wbview addSubview:_progressView];
    }
    return _progressView;
}












@end
