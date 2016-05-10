//
//  ViewController.m
//  WKWebview
//
//  Created by JianRongCao on 5/9/16.
//  Copyright © 2016 JianRongCao. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
{
    WKWebView *web;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 13.0;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    /*! 需要先注册一下这个JS的方法名称。 否则无法响应，  同时实现WKScriptMessageHandler代理*/
    [userController addScriptMessageHandler:self name:@"OOXX"];
    config.userContentController = userController;
    config.allowsPictureInPictureMediaPlayback = YES;  //是否支持视频以画中画的格式播放
    config.allowsInlineMediaPlayback = YES;   //是否支持在线录像播放
    
    web = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:config];
    web.navigationDelegate = self;
    web.UIDelegate = self;
    NSURL *url = [NSURL URLWithString:@"http://www.suning.com"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [web loadRequest:request];
    //打开左划回退功能
    web.allowsBackForwardNavigationGestures = YES;
    
    [self runPluginJS:@[@"Console",@"Base",@"Accelerometer"]];
    
    [self.view addSubview:web];
}

- (void)runPluginJS:(NSArray *)plugins
{
    for (NSString *jsPtah in plugins) {
        NSString *path = [[NSBundle mainBundle] pathForResource:jsPtah ofType:@"js"];
        NSString *js = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [web evaluateJavaScript:js completionHandler:nil];
    }
}

#pragma mark WKScriptMessageHandler
/**
 *  通过这个方法可以直接进行JS向原生传值以及调用原生的类和方法。
 *
 *  @param userContentController 用户的文本控制器
 *  @param message               通过JS传递过来的内容
 */
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    Console *console = [[Console alloc] init];
    
    NSLog(@"%@",message.name);
    NSLog(@"%@",[message.body description]);

    NSDictionary *obj = message.body;
    NSLog(@"%@",obj);
    
    console.wkView = web;
    console.message = [obj valueForKey:@"data"];
    console.taskId = [[obj valueForKey:@"taskId"] integerValue];
    
    NSString *className = [obj valueForKey:@"className"];
    NSString *selectName = [obj valueForKey:@"functionName"];

    SEL select = NSSelectorFromString(selectName);
    id cls = [[NSClassFromString(className) alloc] init];
    
    if (!cls) {
        NSLog(@"Class couldn't find");
        return;
    }
    
    if ([console respondsToSelector:select]) {   //找到方法
        [console performSelector:select];
    } else {  //方法未找到
        NSLog(@"function couldn't find");
    }
    
//    WebView 调用JS方法的一种方式
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [web evaluateJavaScript:@"hello('sss')" completionHandler:nil];
//    });
}

#pragma mark WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"StartProvisional %f",web.estimatedProgress);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"%f",web.estimatedProgress);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    //加载完成
    NSLog(@"%@",@"加载完成");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error
{
    //加载失败
    NSLog(@"didFailNavigation    %@",@"加载失败");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"didFailProvisionalNavigation   %@",[error debugDescription]);
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"%@",webView.title);
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"%@",webView.title);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //取消跳转
//    decisionHandler(WKNavigationActionPolicyCancel);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"%@",[webView.URL absoluteString]);
}

#pragma mark WKUIDelegate
/**
 *  web界面中有弹出警告框时调用,当网页调用Alert方法时，需要实现此方法，否则页面的Alert不会调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param frame             主窗口
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
        NSLog(@"输出Alert 点击");
    }];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*! 确认框,同上面的Alert一样的处理方法*/
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    
}

/*! 输入框,同上面的Alert一样的处理方法*/
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    
}

//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
//{
//    // 接口的作用是打开新窗口委托
//    [self createNewWebViewWithURL:webView.URL.absoluteString config:configuration];
//
//    return currentSubView.webView;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
