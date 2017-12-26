
#import "ChatViewController.h"
#import "ChatDetailsViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowChatDetails"]) {
        ChatDetailsViewController *chatDetailsVC = segue.destinationViewController;
        chatDetailsVC.navigationItem.title = @"TEEEST";
    }
}

- (IBAction)showChatDetails:(id)sender {
    [self performSegueWithIdentifier:@"ShowChatDetails" sender:sender];
}

@end
