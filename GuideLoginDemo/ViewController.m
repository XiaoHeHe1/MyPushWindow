//
//  ViewController.m
//  MyPushWindow
//
//  Created by YYY on 2020/9/22.
//

#import "ViewController.h"
#import "YYYOnlyWKWebViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"任何点击滑动跳到下一页";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    YYYOnlyWKWebViewController *webViewVC = [[YYYOnlyWKWebViewController alloc] init];
    [webViewVC loadLocalHtml:@"myPushWindow"];
    [self.navigationController pushViewController:webViewVC animated:YES];
}

@end
