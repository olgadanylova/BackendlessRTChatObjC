
#import "ChatsViewController.h"
#import "AlertController.h"
#import "ChatViewController.h"
#import "Backendless.h"

@interface ChatsViewController() {
    NSMutableArray *chats;
}
@end

@implementation ChatsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self retrieveChats];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ [self addRTListeners]; });
}

- (void)retrieveChats {
    [[backendless.data of:[Chat class]] find:^(NSArray *retrievedChats) {
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        chats = [NSMutableArray arrayWithArray:[retrievedChats sortedArrayUsingDescriptors:[NSArray arrayWithObject:valueDescriptor]]];
        [self.tableView reloadData];
    } error:^(Fault *fault) {
        [AlertController showErrorAlert:fault target:self];
    }];
}

- (void)addRTListeners {
    RTDataStore *chatStore = [backendless.rt.data of:[Chat class]];
    [chatStore addErrorListener:^(Fault *fault) { [AlertController showErrorAlert:fault target:self]; }];
    [chatStore addCreateListener:^(Chat *createdChat) { [self retrieveChats]; }];
    [chatStore addUpdateListener:^(Chat *updatedChat) { [self retrieveChats]; }];
    [chatStore addDeleteListener:^(Chat *deletedChat) { [self retrieveChats]; }];
}
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    Chat *chat = [chats objectAtIndex:indexPath.row];
    cell.textLabel.text = chat.name;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowChat"]) {
        UINavigationController *navController = [segue destinationViewController];
        ChatViewController *chatVC = (ChatViewController *)[navController topViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        chatVC.chat = [chats objectAtIndex:indexPath.row];
    }
}

- (IBAction)prepareForUnwindToChatsVC:(UIStoryboardSegue *)segue {
    ChatViewController *chatVC = (ChatViewController *)segue.sourceViewController;
    chatVC.navigationItem.title = @"";
    chatVC.chatField.text = @"";
    chatVC.inputField.text = @"";
    chatVC.userTypingLabel.hidden = YES;
    [chatVC.leaveChatButton setEnabled:NO];
    [chatVC.detailsButton setEnabled:NO];
    [chatVC.textButton setEnabled:NO];
    [chatVC.sendButton setEnabled:NO];
    [chatVC.channel disconnect];
}

- (IBAction)addNewChat:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New chat" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter chat name here";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        Chat *newChat = [Chat new];
        newChat.name = alertController.textFields.firstObject.text;
        [[backendless.data of:[Chat class]]
         save:newChat
         response:^(Chat *savedChat) {
         } error:^(Fault *fault) {
             [AlertController showErrorAlert:fault target:self];
         }];
    }];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
