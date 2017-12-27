
#import <UIKit/UIKit.h>
#import "Chat.h"
#import "Backendless.h"

@interface ChatViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic) Channel *channel;
@property (strong, nonatomic) UITextView *inputField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leaveChatButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *detailsButton;
@property (weak, nonatomic) IBOutlet UITextView *chatField;
@property (weak, nonatomic) IBOutlet UILabel *userTypingLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *textButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

- (IBAction)pressedSend:(id)sender;
- (IBAction)pressedDetails:(id)sender;

@end
