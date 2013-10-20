//
//  MenuViewController.h
//  UserDefinedTargets
//
//  Created by Andrew Shim on 10/20/13.
//
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
- (void)presentMenuViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion presentingViewController:(UIViewController *)presentingViewController;

- (IBAction)attackPressed:(id)sender;

@end
