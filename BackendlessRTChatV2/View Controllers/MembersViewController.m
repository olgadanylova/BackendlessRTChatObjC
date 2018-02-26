
#import "MembersViewController.h"
#import "AlertController.h"
#import "ChatMember.h"

#define CONNECTED_STATUS @"CONNECTED"
#define DISCONNECTED_STATUS @"DISCONNECTED"
#define ONLINE_STATUS @"online"
#define OFFLINE_STATUS @"offline"

@interface MembersViewController() {
    NSMutableSet *members;
    void(^onUserStatus)(UserStatusObject *);
    void(^onError)(Fault *);
}
@end

@implementation MembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Members";
    members = [NSMutableSet new];
    
    ChatMember *you = [ChatMember new];
    you.userId = backendless.userService.currentUser.objectId;
    you.identity = backendless.userService.currentUser.email;
    you.status = ONLINE_STATUS;
    [members addObject:you];
    
    __weak MembersViewController *weakSelf = self;
    __weak NSMutableSet *weakMembers = members;
    
    onUserStatus = ^(UserStatusObject *userStatus) {
        if ([userStatus.status isEqualToString:CONNECTED_STATUS]) {
            NSMutableSet *connectedMembers = [NSMutableSet new];
            for (NSDictionary *data in userStatus.data) {
                [connectedMembers addObject:[data valueForKey:@"userId"]];
            }
            for (NSString *userId in connectedMembers) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
                ChatMember *member = [[weakMembers allObjects] filteredArrayUsingPredicate:predicate].firstObject;
                if (!member) {
                    BackendlessUser *user = [backendless.userService findById:userId];
                    ChatMember *member = [ChatMember new];
                    member.userId = user.objectId;
                    member.identity = user.email;
                    member.status = ONLINE_STATUS;
                    [weakMembers addObject: member];
                }
                else {
                    member.status = ONLINE_STATUS;
                }
            }
        }
        else if ([userStatus.status isEqualToString:DISCONNECTED_STATUS]) {
            NSMutableSet *disconnectedMembers = [NSMutableSet new];
            for (NSDictionary *data in userStatus.data) {
                [disconnectedMembers addObject:[data valueForKey:@"userId"]];
            }
            for (NSString *userId in disconnectedMembers) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
                ChatMember *member = [[weakMembers allObjects] filteredArrayUsingPredicate:predicate].firstObject;
                if (member) {
                    member.status = OFFLINE_STATUS;
                }
            }
        }
        [weakSelf.tableView reloadData];
    };
    
    onError = ^(Fault *fault) { [AlertController showErrorAlert:fault target:weakSelf handler:nil]; };
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addRTListeners];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController]) {
        [self.channel removeUserStatusListeners:onUserStatus];
    }
}

-(void)addRTListeners {
    [self.channel addUserStatusListener:onUserStatus error:onError];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell" forIndexPath:indexPath];
    ChatMember *member = [[members allObjects] objectAtIndex:indexPath.row];
    cell.textLabel.text = member.identity;
    cell.detailTextLabel.text = member.status;
    if ([member.status isEqualToString:OFFLINE_STATUS]) {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    else if ([member.status isEqualToString:ONLINE_STATUS]) {
        cell.detailTextLabel.textColor = [UIColor blueColor];
    }
    return cell;
}

@end
