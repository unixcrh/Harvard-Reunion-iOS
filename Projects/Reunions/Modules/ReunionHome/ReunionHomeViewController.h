#import "KGOPortletHomeViewController.h"

@class ReunionHomeModule;

@interface ReunionHomeViewController : KGOPortletHomeViewController {

    NSArray *_subclassPrimaryModules;
    NSArray *_subclassSecondaryModules;
}

@property(nonatomic, assign) ReunionHomeModule *homeModule;

@end
