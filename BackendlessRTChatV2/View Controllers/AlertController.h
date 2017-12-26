
#import <UIKit/UIKit.h>

@interface AlertController : UIViewController

+(void)createNewChatAlert:(id)target action:(void(^)(UIAlertAction *))saveAction;

@end
