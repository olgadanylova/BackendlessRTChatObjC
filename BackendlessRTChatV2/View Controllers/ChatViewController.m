
#import "ChatViewController.h"
#import "AlertController.h"
#import "ChatDetailsViewController.h"

@interface ChatViewController() {
    NSMutableSet *usersTyping;
}
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    usersTyping = [NSMutableSet new];
    self.navigationItem.title = self.chat.name;
    self.userTypingLabel.hidden = YES;
    [self.leaveChatButton setEnabled:NO];
    [self.detailsButton setEnabled:NO];
    [self.textButton setEnabled:NO];
    [self.sendButton setEnabled:NO];
    [self setupToolbarItems];
    if (self.chat.name) {
        [self.leaveChatButton setEnabled:YES];
        [self.detailsButton setEnabled:YES];
        [self.textButton setEnabled:YES];
        self.channel = [backendless.messaging subscribe:self.chat.objectId];
        if (!self.channel.isConnected) {
            [self.channel connect];
        }
        [self addRTListeners];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem.backBarButtonItem setEnabled:NO];
    self.navigationItem.hidesBackButton = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidLayoutSubviews {
    self.inputField.frame = CGRectMake(0, 0, self.toolbar.frame.size.width * 0.75, self.toolbar.frame.size.height * 0.75);
}

- (void)setupToolbarItems {
    self.inputField = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.toolbar.frame.size.width * 0.75, self.toolbar.frame.size.height * 0.75)];
    self.inputField.delegate = self;
    self.inputField.font = [UIFont systemFontOfSize:15];
    self.inputField.layer.cornerRadius = 5.0;
    self.inputField.clipsToBounds = YES;
    self.inputField.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.textButton setCustomView:self.inputField];
}

- (void)addRTListeners {
    __weak ChatViewController *weakSelf = self;
    __weak NSMutableSet *weakUsersTyping = usersTyping;
    
    [self.channel addMessageListener:^(Message *message) {
        NSString *userIdentity = [message.headers valueForKey:@"publisherEmail"];
        NSString *messageText = [message.headers valueForKey:@"messageText"];
        [weakSelf putFormattedMessageIntoChatViewFromUser:userIdentity messageText:messageText];
    }];
    
    [self.channel addCommandListener:^(CommandObject *typing) {
        if ([typing.type isEqualToString:@"USER_TYPING"]) {
            BackendlessUser *user = [backendless.userService findById:typing.userId];
            [weakUsersTyping addObject:user.email];
            weakSelf.userTypingLabel.hidden = NO;
            NSString *usersTypingString = @"";
            for(NSString *userTyping in weakUsersTyping) {
                usersTypingString = [usersTypingString stringByAppendingString:userTyping];
                if (userTyping != [usersTyping allObjects].lastObject) {
                    usersTypingString = [usersTypingString stringByAppendingString:@", "];
                }
            }
            weakSelf.userTypingLabel.text = [NSString stringWithFormat:@"%@ typing...", usersTypingString];
        }
        else if ([typing.type isEqualToString:@"USER_STOP_TYPING"]) {
            BackendlessUser *user = [backendless.userService findById:typing.userId];
            [weakUsersTyping removeObject:user.email];
            if ([weakUsersTyping count] == 0) {
                weakSelf.userTypingLabel.hidden = YES;
            }
            else {
                NSString *usersTypingString = @"";
                for(NSString *userTyping in weakUsersTyping) {
                    usersTypingString = [usersTypingString stringByAppendingString:userTyping];
                    if (userTyping != [usersTyping allObjects].lastObject) {
                        usersTypingString = [usersTypingString stringByAppendingString:@", "];
                    }
                }
                weakSelf.userTypingLabel.text = [NSString stringWithFormat:@"%@ typing...", usersTypingString];
            }
        }
    }];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (void)putFormattedMessageIntoChatViewFromUser:(NSString *)userIdentity messageText:(NSString *)messageText {
    NSMutableAttributedString *user = [[NSMutableAttributedString alloc] initWithString:userIdentity];
    [user addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0, user.length)];
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n\n", messageText]];
    [message addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, message.length)];
    [user appendAttributedString:message];
    
    NSMutableAttributedString *textViewString = (NSMutableAttributedString *)[self.chatField.attributedText mutableCopy];
    [textViewString appendAttributedString:user];
    
    self.chatField.attributedText = textViewString;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getHintsFromTextView:) object:textView];
    [self performSelector:@selector(getHintsFromTextView:) withObject:textView afterDelay:0.5];
    return YES;
}

- (void)getHintsFromTextView:(UITextView *)textView {
    if (textView.text.length > 0) {
        [backendless.messaging sendCommand:@"USER_TYPING"
                               channelName:self.channel.channelName
                                      data:nil
                                 onSuccess:^(id result) {
                                 } onError:^(Fault *fault) {
                                     [AlertController showErrorAlert:fault target:self];
                                 }];
    }
}

- (void)sendUserStopTyping {
    [backendless.messaging sendCommand:@"USER_STOP_TYPING"
                           channelName:self.channel.channelName
                                  data:nil
                             onSuccess:^(id result) {
                             } onError:^(Fault *fault) {
                                 [AlertController showErrorAlert:fault target:self];
                             }];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        [self.sendButton setEnabled:NO];
        [self sendUserStopTyping];
    }
    else {
        [self.sendButton setEnabled:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowChatDetails"]) {
        ChatDetailsViewController *chatDetailsVC = (ChatDetailsViewController *)[segue destinationViewController];
        chatDetailsVC.chat = self.chat;
        chatDetailsVC.channel = self.channel;
        chatDetailsVC.editing = YES;
        [self.view endEditing:YES];
    }
}

- (IBAction)prepareForUnwindToChatVCAfterDelete:(UIStoryboardSegue *)segue {
    self.chat = nil;
    self.navigationItem.title = nil;
    self.chatField.text = @"";
    self.userTypingLabel.hidden = YES;
    [self.leaveChatButton setEnabled:NO];
    [self.detailsButton setEnabled:NO];
    [self.textButton setEnabled:NO];
}

- (IBAction)prepareForUnwindToChatVCAfterSave:(UIStoryboardSegue *)segue {
    ChatDetailsViewController *chatDetailsVC = (ChatDetailsViewController *)segue.sourceViewController;
    self.chat = chatDetailsVC.chat;
    self.navigationItem.title = self.chat.name;
    self.userTypingLabel.hidden = YES;
    [self.leaveChatButton setEnabled:YES];
    [self.detailsButton setEnabled:YES];
    [self.textButton setEnabled:YES];
}

- (IBAction)pressedSend:(id)sender {
    Message *message = [Message new];
    
    PublishOptions *publishOptions = [PublishOptions new];
    [publishOptions addHeader:@"publisherEmail" value:backendless.userService.currentUser.email];
    [publishOptions addHeader:@"messageText" value:self.inputField.text];
    
    [backendless.messaging publish:self.channel.channelName
                           message:message
                    publishOptions:publishOptions
                          response:^(MessageStatus *status) {
                              self.inputField.text = @"";
                              [self.sendButton setEnabled:NO];
                              [self.view endEditing:YES];
                              [self sendUserStopTyping];
                          } error:^(Fault *fault) {
                              [AlertController showErrorAlert:fault target:self];
                          }];
}

- (IBAction)pressedDetails:(id)sender {
    [self performSegueWithIdentifier:@"ShowChatDetails" sender:sender];
}

@end
