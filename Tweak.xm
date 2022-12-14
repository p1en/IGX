#import "Tweak.h"

%group IGX

// Photos (include Stories)
%hook IGImageView
    - (id)initWithFrame:(CGRect)arg1 shouldUseProgressiveJPEG:(BOOL)arg2 placeholderProvider:(id)arg3 {
        self = %orig;
        [self longPressGesture];
        return self;
    }

    %new
    - (void)longPressGesture {
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:recognizer];
    }

    %new
    - (void)handleLongPressGesture:(UILongPressGestureRecognizer*)sender {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"IGX" message:@"Select an option" preferredStyle:UIAlertControllerStyleActionSheet];
        alertController.popoverPresentationController.sourceView = self;
        alertController.popoverPresentationController.sourceRect = CGRectMake(100.0, 100.0, 20.0, 20.0);

        [alertController addAction:[UIAlertAction actionWithTitle:@"Save photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.viewController showIndicatorAlert:@"Saving..." isLoading:YES];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                NSData *imgData = [NSData dataWithContentsOfURL:self.imageSpecifier.url];
                UIImage *img = [UIImage imageWithData:imgData];
                UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.viewController dismissViewControllerAnimated:true completion:nil];
                    [self.viewController showIndicatorAlert:@"Saved" isLoading:NO];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 2.0), dispatch_get_main_queue(), ^{
                        [self.viewController dismissViewControllerAnimated:true completion:nil];
                    });
                });
            });
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }

    %new
    - (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {}
%end

// Reels + Stories videos
%hook IGFNFVideoView
    - (id)initWithFrame:(CGRect)arg1 {
        self = %orig;
        [self longPressGesture];
        return self;
    }

    %new
    - (void)longPressGesture {
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:recognizer];
    }

    %new
    - (void)handleLongPressGesture:(UILongPressGestureRecognizer*)sender {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"IGX" message:@"Select an option" preferredStyle:UIAlertControllerStyleActionSheet];
        alertController.popoverPresentationController.sourceView = self;
        alertController.popoverPresentationController.sourceRect = CGRectMake(100.0, 100.0, 20.0, 20.0);

        [alertController addAction:[UIAlertAction actionWithTitle:@"Save video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.viewController showIndicatorAlert:@"Saving..." isLoading:YES];

            IGFNFVideoPlayer *_videoPlayer = [self.superview valueForKey:@"_videoPlayer"];
            IGVideo *_video = [_videoPlayer valueForKey:@"_video"];
            NSURL *videoUrl = [[_video.allVideoURLs allObjects] objectAtIndex:0];

            NSURLSessionTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:videoUrl completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                NSURL *documentsUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                NSURL *tmpUrl = [documentsUrl URLByAppendingPathComponent:[videoUrl lastPathComponent]];
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:tmpUrl error:nil];

                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tmpUrl];
                } completionHandler:^(BOOL success, NSError *error) {
                    [[NSFileManager defaultManager] removeItemAtURL:tmpUrl error:nil];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self.viewController dismissViewControllerAnimated:true completion:nil];
                        [self.viewController showIndicatorAlert:@"Saved" isLoading:NO];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 2.0), dispatch_get_main_queue(), ^{
                            [self.viewController dismissViewControllerAnimated:true completion:nil];
                        });
                    });
                }];
            }];
            [downloadTask resume];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }
%end

%end

%ctor {
    %init(IGX);
}
