
#import "ChatsViewController.h"
#import "AlertController.h"
#import "ChatViewController.h"
#import "Chat.h"

@interface ChatsViewController() {
    NSMutableArray *chats;
}
@end

@implementation ChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Chat *c1 = [Chat new];
    c1.name = @"C1";
    Chat *c2 = [Chat new];
    c2.name = @"C2";
    
    chats = [NSMutableArray arrayWithArray:@[c1, c2]];
    
}

#pragma mark - Table view data source

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowChats"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        ChatViewController *chatVC = segue.destinationViewController;
        chatVC.chat = [chats objectAtIndex:indexPath.row];
    }
}

- (IBAction)addNewChat:(id)sender {
    [AlertController createNewChatAlert:self action:^(UIAlertAction *createChat) {
        
    }];
}

-(IBAction)prepareForUnwindToChatsVC:(UIStoryboardSegue *)segue {
}

@end
