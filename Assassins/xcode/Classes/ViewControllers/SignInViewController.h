//
//  SignInViewController.h
//  UserDefinedTargets
//
//  Created by Andrew Shim on 10/20/13.
//
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *usernameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)signInPressed:(id)sender;

@end
