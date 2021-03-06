
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import "VideosModule.h"
#import "FacebookVideosViewController.h"
#import "FacebookVideoDetailViewController.h"
#import "KGOSocialMediaController.h"
#import "KGOHomeScreenWidget.h"
#import "KGOTheme.h"
#import "FacebookVideo.h"

@implementation VideosModule

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params {
    NSString *homeNibName;
    NSString *detailNibName;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        homeNibName = @"FacebookMediaViewController";
        detailNibName = @"FacebookMediaDetailViewController";
    } else {
        homeNibName = @"FacebookMediaViewController-iPad";
        detailNibName = @"FacebookMediaDetailViewController-iPad";
    }
    
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        vc = [[[FacebookVideosViewController alloc] initWithNibName:homeNibName bundle:nil] autorelease];
    } else if ([pageName isEqualToString:LocalPathPageNameDetail]) {
        FacebookVideo *video = [params objectForKey:@"video"];

        vc = [[[FacebookVideoDetailViewController alloc] initWithNibName:detailNibName bundle:nil] autorelease];
        NSArray *videos = [params objectForKey:@"videos"];
        NSInteger videoIndex = [videos indexOfObject:video];
        [(FacebookVideoDetailViewController *)vc setPosts:videos];
        [(FacebookVideoDetailViewController *)vc setInitialIndex:videoIndex];
        
        UIImage *curtainImage = [params objectForKey:@"loadingCurtainImage"];
        [(FacebookVideoDetailViewController *)vc 
         setLoadingCurtainImage:curtainImage];
    }
    return vc;
}

- (void)launch {
    [super launch];
    [[KGOSocialMediaController facebookService] startup];
}

- (void)terminate {
    [super terminate];
    [[KGOSocialMediaController facebookService] shutdown];
}

#pragma mark Social media controller

- (NSSet *)socialMediaTypes {
    return [NSSet setWithObject:KGOSocialMediaTypeFacebook];
}

- (NSDictionary *)userInfoForSocialMediaType:(NSString *)mediaType {
    if ([mediaType isEqualToString:KGOSocialMediaTypeFacebook]) {
        return [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
                                                   @"read_stream",
                                                   //@"offline_access",
                                                   @"user_groups",
                                                   @"user_videos",
                                                   @"publish_stream",
                                                   nil]
                                           forKey:@"permissions"];
    }
    return nil;
}

@end
