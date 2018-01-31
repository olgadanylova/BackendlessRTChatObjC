
#import "MembersViewController.h"
#import "AlertController.h"
#import "ChatMember.h"

#define LISTING_STATUS @"LISTING"
#define CONNECTED_STATUS @"CONNECTED"
#define DISCONNECTED_STATUS @"DISCONNECTED"
#define ONLINE_STATUS @"online"
#define OFFLINE_STATUS @"offline"

@interface MembersViewController() {
    NSMutableSet *members;
}
@end

@implementation MembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRTListeners];
    self.navigationItem.title = @"Members";
}

-(void)addRTListeners {
    members = [NSMutableSet new];
    __weak NSMutableSet *weakMembers = members;
    __weak MembersViewController *weakSelf = self;
    
    [self.channel addErrorListener:^(Fault *fault) { [AlertController showErrorAlert:fault target:weakSelf]; }];
    
    [self.channel addUserStatusListener:^(UserStatusObject *userStatus) {
        if ([userStatus.status isEqualToString:LISTING_STATUS]) {
            NSMutableSet *listingMembers = [NSMutableSet new];
            for (NSDictionary *data in userStatus.data) {
                [listingMembers addObject:[data valueForKey:@"userId"]];
            }
            for (NSString *userId in listingMembers) {
                BackendlessUser *user = [backendless.userService findById:userId];
                ChatMember *member = [ChatMember new];
                member.userId = user.objectId;
                member.identity = user.email;
                member.status = ONLINE_STATUS;
                [weakMembers addObject: member];
            }
        }
        else if ([userStatus.status isEqualToString:CONNECTED_STATUS]) {
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
    }];
    
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
