
#import <Foundation/Foundation.h>

@interface ChatMember : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *identity;
@property (strong, nonatomic) NSString *status;

@end
