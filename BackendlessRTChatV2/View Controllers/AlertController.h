
#import <UIKit/UIKit.h>
#import "Responder.h"

@interface AlertController : UIViewController

+(void)showErrorAlert:(Fault *)fault target:(UIViewController *)target;
+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message target:(UIViewController *)target handler:(void(^)(UIAlertAction *))actionHandler;

@end
