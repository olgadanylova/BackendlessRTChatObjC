
#import <UIKit/UIKit.h>
#import "Chat.h"
#import "Backendless.h"

@interface ChatDetailsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) Chat *chat;
@property (strong, nonatomic) Channel *channel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *chatNameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *membersButton;

- (IBAction)pressedSave:(id)sender;
- (IBAction)pressedDelete:(id)sender;
- (IBAction)pressedMembers:(id)sender;

@end
