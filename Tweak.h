#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface IGImageSpecifier : NSObject
@property(nonatomic) NSURL *url;
@end

@interface IGImageView : UIImageView
@property(nonatomic) UIViewController *viewController;
@property(nonatomic) IGImageSpecifier *imageSpecifier;
- (void)longPressGesture;
- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)sender;
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo;
- (void)showIndicatorAlert:(NSString*)text isLoading:(BOOL)isLoading;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end

@interface IGVideo : NSObject
@property(nonatomic) NSSet *allVideoURLs;
@end

@interface IGFNFVideoPlayer : NSObject
@property(nonatomic) IGVideo *_video;
@end

@interface IGFNFVideoView : UIView
@property(nonatomic) UIViewController *viewController;
@property(nonatomic) UIView *superview;
- (void)longPressGesture;
- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)sender;
@end

@implementation UIViewController (Alert)
- (void)showIndicatorAlert:(NSString*)text isLoading:(BOOL)isLoading {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:text preferredStyle:UIAlertControllerStyleAlert];
    if (isLoading) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        view.center = CGPointMake(60, 30);
        [alertController.view addSubview:view];
        [view startAnimating];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
