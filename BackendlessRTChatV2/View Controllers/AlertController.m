
#import "AlertController.h"

@implementation AlertController

- (void)viewDidLoad {
    [super viewDidLoad];
}

+(void)createNewChatAlert:(id)target action:(void(^)(UIAlertAction *))saveAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New chat" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter chat name here";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:saveAction];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [target presentViewController:alertController animated:YES completion:nil];
}

@end
