//
//  SignInViewController.h
//  UserDefinedTargets
//
//  Created by Andrew Shim on 10/20/13.
//
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

#define KEYCHAIN_IDENTIFIER @"AssassinKeychain"

@property (retain, nonatomic) IBOutlet UITextField *usernameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UILabel *notificationLabel;

- (IBAction)signInPressed:(id)sender;
- (bool)isSignedIn;
- (void)presentMenuView;

@end
