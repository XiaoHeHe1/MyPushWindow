
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface YYYOnlyWKWebViewController : UIViewController
@property(nonatomic,retain)WKWebView *myWKWebView;
- (void)loadLocalHtml:(NSString *)html;
@end
