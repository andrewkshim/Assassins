//
//  MenuViewController.m
//  UserDefinedTargets
//
//  Created by Andrew Shim on 10/20/13.
//
//

#import "MenuViewController.h"

@interface MenuViewController ()

@property UIViewController *prevPresentingViewController;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)attackPressed:(id)sender {
    [_prevPresentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentMenuViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion presentingViewController:(UIViewController *)presentingViewController {
    _prevPresentingViewController = presentingViewController;
    [viewControllerToPresent presentViewController:self animated:YES completion:completion];
    
}
@end
