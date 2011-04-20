#import "AttendeesModule.h"
#import "AttendeesTableViewController.h"
#import "ReunionHomeModule.h"
#import "KGOAppDelegate+ModuleAdditions.h"

@implementation AttendeesModule

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params {
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        
        AttendeesTableViewController *attendeesVC = [[[AttendeesTableViewController alloc] init] autorelease];

        ReunionHomeModule *homeModule = (ReunionHomeModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
        attendeesVC.eventTitle = [homeModule reunionName];
        
        vc = attendeesVC;
    }
    return vc;
}

@end
