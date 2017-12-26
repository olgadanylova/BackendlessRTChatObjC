
#import "SplitViewController.h"
#import "ChatViewController.h"

@implementation SplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[ChatViewController class]]
        && ([(ChatViewController *)[(UINavigationController *)secondaryViewController topViewController] chat] == nil)) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
