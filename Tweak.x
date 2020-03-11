#import "MediaRemote.h"

@interface CALayer (Private)
@property (atomic, assign, readwrite) BOOL continuousCorners;
@end

@interface CCUIContentModuleContentContainerView : UIView
@property (assign,nonatomic) double compactContinuousCornerRadius;
@end

@interface CCUIContentModuleContainerViewController : UIViewController
@property (nonatomic,retain) UIViewController* contentViewController;
@property (nonatomic,readonly) CCUIContentModuleContentContainerView * moduleContentView;
@property (nonatomic,copy) NSString * moduleIdentifier;
-(BOOL)isExpanded;
-(void)updateExpanded;
-(void)updateImage:(NSNotification *)notification;
@end

NSNotificationCenter *notificationCenter;
UIImageView *imageView;

%hook CCUIContentModuleContainerViewController

-(void)viewWillAppear:(BOOL)appear {
    %orig;
    if ([self.moduleIdentifier isEqualToString:@"com.apple.mediaremote.controlcenter.nowplaying"]) {
        notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(updateImage:) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
        [notificationCenter postNotificationName:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
        if (imageView == nil) {
            imageView = [[UIImageView alloc] initWithFrame:self.contentViewController.view.bounds];
            imageView.layer.cornerRadius = self.moduleContentView.compactContinuousCornerRadius;
            imageView.layer.continuousCorners = YES;
            imageView.layer.masksToBounds = YES;
            if (@available(iOS 11, *)) {
                imageView.layer.maskedCorners = self.contentViewController.view.layer.maskedCorners;

            }
            [self.contentViewController.view addSubview:imageView];
            [self.contentViewController.view sendSubviewToBack:imageView];
        }
    }
}

-(void)viewWillLayoutSubviews {
    %orig;
    if ([self.moduleIdentifier isEqualToString:@"com.apple.mediaremote.controlcenter.nowplaying"]) {
        [self updateExpanded];
    }
}

%new
-(void)updateExpanded {
    BOOL expanded = [self isExpanded];
    if (!expanded) {
        imageView.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            imageView.alpha = 1.0;
        }];
        [imageView setHidden:NO];
    } else {
        [imageView setHidden:YES];
    }
}

%new
-(void)updateImage:(NSNotification *)notification {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
      if(result) {
        NSDictionary *dict = (__bridge NSDictionary *)result;
        NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
        if (artworkData != nil) {
          UIImage *image = [UIImage imageWithData:artworkData];
          imageView.image = image;
          [imageView setNeedsDisplay];
          [self.contentViewController.view setNeedsDisplay];
        }
      }
  });
}

-(void)viewWillDisappear:(BOOL)disappear {
    %orig;
    [notificationCenter removeObserver:self name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
}

%end
