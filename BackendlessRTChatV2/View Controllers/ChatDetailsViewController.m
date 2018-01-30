
#import "ChatDetailsViewController.h"
#import "AlertController.h"
#import "MembersViewController.h"

@interface ChatDetailsViewController() {
    UITextField *activeField;
}
@end

@implementation ChatDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatNameField.delegate = self;
    self.chatNameField.tag = 0;
    [self.chatNameField addTarget:self action:@selector(chatNameFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.navigationItem.title = [self.chat.name stringByAppendingString:@" Details"];
    self.chatNameField.text = self.chat.name;
    self.chatNameField.returnKeyType = UIReturnKeyDone;
    
    [self.saveButton setEnabled:NO];
    [self.deleteButton setEnabled:NO];
    [self.chatNameField setEnabled:NO];
    
    if ([self.chat.ownerId isEqualToString:backendless.userService.currentUser.objectId]) {
        [self.saveButton setEnabled:YES];
        [self.deleteButton setEnabled:YES];
        [self.chatNameField setEnabled:YES];
    }
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.enabled = YES;
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)chatNameFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        if (![textField.text isEqualToString:self.chat.name]) {
            [self.saveButton setEnabled:YES];
        }
        else {
            [self.saveButton setEnabled:NO];
        }
    }
    else {
        [self.saveButton setEnabled:NO];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)gesture {
    [self.view endEditing:YES];
}

-(void)keyboardDidShow:(NSNotification *)notification {
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height -= keyboardRect.size.height;
    if (!CGRectContainsPoint(viewFrame, activeField.frame.origin)) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)saveChat {
    if (self.chatNameField.text.length > 0) {
        if (![self.chatNameField.text isEqualToString:self.chat.name]) {
            self.chat.name = self.chatNameField.text;
            [[backendless.data of:[Chat class]]
             save:self.chat
             response:^(Chat *updatedChat) {
                 [AlertController showAlertWithTitle:@"Chat updated"
                                             message:[NSString stringWithFormat:@"'%@' successfully updated", updatedChat.name]
                                              target:self
                                             handler:^(UIAlertAction *alertAction) {
                                                 [self performSegueWithIdentifier:@"UnwindToChatAfterSave" sender:nil];
                                             }];
             }
             error:^(Fault *fault) {
                 [AlertController showErrorAlert:fault target:self];
             }];
        }
        else if ([self.chatNameField.text isEqualToString:self.chat.name]) {
            [AlertController showAlertWithTitle:@"Update failed" message:@"Please change the chat before saving" target:self handler:nil];
        }
        else if (self.chatNameField.text.length == 0) {
            [AlertController showAlertWithTitle:@"Update failed" message:@"Please enter the correct chat name" target:self handler:nil];
        }
    }
}

-(void)deleteChat {
    NSString *name = self.chat.name;
    [[backendless.data of:[Chat class]]
     remove:self.chat
     response:^(NSNumber *deletedChat) {
         [AlertController showAlertWithTitle:@"Chat deleted"
                                     message:[NSString stringWithFormat:@"'%@' successfully deleted", name]
                                      target:self
                                     handler:^(UIAlertAction *alertAction) {
                                         [self.channel removeAllListeners];
                                         [self performSegueWithIdentifier:@"UnwindToChatAfterDelete" sender:nil];
                                     }];
     } error:^(Fault *fault) {
         [AlertController showErrorAlert:fault target:self];
     }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowMembers"]) {
        MembersViewController *membersVC = [segue destinationViewController];
        membersVC.channel = self.channel;
    }
}

- (IBAction)pressedSave:(id)sender {
    [self.view endEditing:YES];
    [self saveChat];
}

- (IBAction)pressedDelete:(id)sender {
    [self.view endEditing:YES];
    [self deleteChat];
}

- (IBAction)pressedMembers:(id)sender {
    [self performSegueWithIdentifier:@"ShowMembers" sender:sender];
}

@end
