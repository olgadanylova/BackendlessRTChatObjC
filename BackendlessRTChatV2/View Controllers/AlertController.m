
#import "AlertController.h"

@implementation AlertController

- (void)viewDidLoad {
    [super viewDidLoad];
}

+(void)showErrorAlert:(Fault *)fault target:(UIViewController *)target {
    NSString *errorTitle = @"Error";
    if (fault.faultCode) {
        errorTitle = [NSString stringWithFormat:@"Error %@", fault.faultCode];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:errorTitle message:fault.message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:dismissAction];
    [target presentViewController:alert animated:YES completion:nil];
}

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message target:(UIViewController *)target handler:(void(^)(UIAlertAction *))actionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *chatsAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:actionHandler];
    [alert addAction:chatsAction];
    [target presentViewController:alert animated:YES completion:nil];
}

@end
