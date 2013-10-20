//
//  SignInView.m
//  UserDefinedTargets
//
//  Created by Andrew Shim on 10/20/13.
//
//

#import "SignInView.h"

@implementation SignInView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *usernameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50, 100, 80, 30)]autorelease];
        [usernameLabel setText:@"Username:"];
        UILabel *passwordLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50, 175, 80, 30)]autorelease];
        [passwordLabel setText:@"Password:"];
        
        UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 150, 30)];
        UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(100, 175, 150, 30)];
        
        [self addSubview:usernameLabel];
        [self addSubview:usernameField];
        [self addSubview:passwordLabel];
        [self addSubview:passwordField];
        NSLog(@"WORKING =================================================");
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
