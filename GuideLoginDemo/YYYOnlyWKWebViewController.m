

#import "YYYOnlyWKWebViewController.h"

@interface YYYOnlyWKWebViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic ,retain)NSString *urlStr;

@property (nonatomic ,retain)NSDictionary *currentPageDisplayDic;//当页需要展示的数据

@end

@implementation YYYOnlyWKWebViewController

 


- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        float webViewFrameY = 0;
        
        if (1) {
            //设置网页的配置文件
            WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
            //允许视频播放
            Configuration.allowsAirPlayForMediaPlayback = YES;
            // 允许在线播放
            Configuration.allowsInlineMediaPlayback = YES;
            // 允许可以与网页交互，选择视图
            Configuration.selectionGranularity = YES;
            // web内容处理池
            Configuration.processPool = [[WKProcessPool alloc] init];
            //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
            WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
            //添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
            [UserContentController addScriptMessageHandler:self name:@"MyPushWindowYYY"];
            [UserContentController addScriptMessageHandler:self name:@"getCurrentPageDisplayDic"];
            
            
            // 是否支持记忆读取
            Configuration.suppressesIncrementalRendering = NO;
            // 允许用户更改网页的设置
            Configuration.userContentController = UserContentController;
            
            _myWKWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, webViewFrameY, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) configuration:Configuration];
            [self.view addSubview:_myWKWebView];
            
            _myWKWebView.allowsBackForwardNavigationGestures = YES;
            _myWKWebView.UIDelegate = self;
            _myWKWebView.navigationDelegate = self;
            _myWKWebView.contentMode = UIViewContentModeScaleAspectFit;
            _myWKWebView.autoresizingMask=(UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth);
            
        }

    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor grayColor];
    
//    if(_urlStr.length > 0){
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr ]];
//        [_myWKWebView loadRequest:request];
//    }
    
}
- (void)loadLocalHtml:(NSString *)html{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:html ofType:@"html"];
    [_myWKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath isDirectory:NO]]];
}

#pragma mark wkwebview的Navigationdelegate

// 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;{
    
    //
    //适配直接去appstore
    //排除本地html 20200901
    //在收到响应后，决定是否跳转和发送请求之前那个允许配套使用
    NSURL *url = navigationAction.request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    if ((![urlString hasPrefix:@"file://"]) && ([urlString containsString:@"//itunes.apple.com/"] ||
        (![urlString hasPrefix:@"http"]))) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    
    _urlStr = [[webView URL] description];
    CFStringEncoding gbkEncoding =(unsigned int) CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

//
// 类似UIWebView的 -webViewDidStartLoad:
//
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;{
    
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString* titleStr, NSError * _Nullable error) {
        self.title = titleStr;
    }];
    
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if([error code] == NSURLErrorCancelled)
        
    {
        return;
        
    }
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    
    if([error code] == NSURLErrorCancelled){
        return;
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;{
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation;{
    
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;{
    // 当内容开始返回时调用
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler;{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark wkwebview的uidelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;{

    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
    
    // 接口的作用是打开新窗口委托
}

//- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0));{
//
//}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;{
    
    NSLog(@"点到了哪里%@",message);
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler;{
    //js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    completionHandler(1);
}
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    
    NSLog(@"%@",message.body);
    NSLog(@"%@",message.frameInfo);
    NSLog(@"%@",message.name);
    
    //将本vc的参数传给h5
    if([message.name isEqualToString:@"getCurrentPageDisplayDic"]){
        
        NSDictionary *dic = message.body;
        NSString *callBackName = dic[@"callBackName"];
        
        NSString *jsonStr = [self convertToJsonData:self.currentPageDisplayDic];
        [_myWKWebView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@);",callBackName,jsonStr ] completionHandler:^(NSString *str , NSError * _Nullable error) {
            NSLog(@"%@",error);
        }];
        

    }else if([message.name isEqualToString:@"MyPushWindowYYY"]){
        //原生实现h5跳页
        YYYOnlyWKWebViewController *webViewVC = [[YYYOnlyWKWebViewController alloc] init];
        webViewVC.currentPageDisplayDic = message.body;//下页需要展示的数据
        NSDictionary *dic = message.body;
        NSString *nextPageName = dic[@"nextPageName"];
        [webViewVC loadLocalHtml:nextPageName];
        [self.navigationController pushViewController:webViewVC animated:YES];

    }
    
    
}
-(NSString *)convertToJsonData:(NSDictionary *)dict

{

    NSError *error;

    if (dict == nil) {
        return @"";
    }

  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

  NSString *jsonString;

  if (!jsonData) {

    NSLog(@"%@",error);

  }else{

    jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

  }

  NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

  NSRange range = {0,jsonString.length};

  //去掉字符串中的空格

  [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

  NSRange range2 = {0,mutStr.length};

  //去掉字符串中的换行符

 [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

  return mutStr;

}


@end
