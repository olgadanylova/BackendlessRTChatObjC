
#import "LoginViewController.h"

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)pressedLogin:(id)sender {
    [self performSegueWithIdentifier:@"ShowChats" sender:sender];
}

- (IBAction)pressedSignUp:(id)sender {
}

-(IBAction)prepareForUnwindToLoginVC:(UIStoryboardSegue *)segue {
}

@end
