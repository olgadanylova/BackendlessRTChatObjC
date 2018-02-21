
#import "LoginViewController.h"
#import "AlertController.h"
#import "Backendless.h"

#define HOST_URL @"http://apitest.backendless.com"
#define APP_ID @"A81AB58A-FC85-EF00-FFE4-1A1C0FEADB00"
#define API_KEY @"FE202648-517E-B0A5-FF89-CBA9D7DFDD00"

@interface LoginViewController() {
    NSTimer *timer;
    UITextField *activeField;
    void(^onError)(Fault *);
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    backendless.hostURL = HOST_URL;
    [backendless initApp:APP_ID APIKey:API_KEY];
    
    if (backendless.userService.currentUser) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showChats) userInfo:nil repeats:NO];
    }
    
    self.loginField.delegate = self;
    self.loginField.tag = 0;
    self.passwordField.delegate = self;
    self.passwordField.tag = 1;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.enabled = YES;
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    __weak LoginViewController *weakSelf = self;
    onError = ^(Fault *fault) { [AlertController showErrorAlert:fault target:weakSelf handler:nil]; };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)showChats {
    [self performSegueWithIdentifier:@"ShowChats" sender:nil];
}

- (void)singleTap:(UITapGestureRecognizer *)gesture {
    [self.view endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification {
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.passwordField.superview viewWithTag:textField.tag + 1]) {
        UITextField *nextField = [self.passwordField.superview viewWithTag:textField.tag + 1];
        [nextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
    }
    return NO;
}

- (IBAction)prepareForUnwindToLoginVC:(UIStoryboardSegue *)segue {
    [backendless.userService logout:^(id loggedOut) { } error:onError];
}

- (IBAction)pressedLogin:(id)sender {
    if (self.rememberMeSwitch.isOn) {
        [backendless.userService setStayLoggedIn:YES];
    }
    else {
        [backendless.userService setStayLoggedIn:NO];
    }
    [backendless.userService login:self.loginField.text
                          password:self.passwordField.text
                          response:^(BackendlessUser *currentUser) {
                              [self showChats];
                          } error:onError];
}

- (IBAction)pressedSignUp:(id)sender {
    BackendlessUser *newUser = [BackendlessUser new];
    newUser.email = self.loginField.text;
    newUser.password = self.passwordField.text;
    [backendless.userService registerUser:newUser
                                 response:^(BackendlessUser *registeredUser) {
                                     [AlertController showAlertWithTitle:@"Registration complete" message:[NSString stringWithFormat:@"You have been registered as %@", registeredUser.email] target:self handler:^(UIAlertAction *alertAction) {
                                         [self showChats];
                                     }];
                                 } error:onError];
}

@end
