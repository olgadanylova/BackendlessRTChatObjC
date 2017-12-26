
#import <UIKit/UIKit.h>
#import "Chat.h"

@interface ChatViewController : UIViewController

@property (strong, nonatomic) Chat *chat;

- (IBAction)showChatDetails:(id)sender;

@end
