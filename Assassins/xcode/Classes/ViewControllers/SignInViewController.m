//
//  SignInViewController.m
//  UserDefinedTargets
//
//  Created by Andrew Shim on 10/20/13.
//
//

#import "SignInViewController.h"
#import "SignInView.h"
#import "MenuViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        NSLog(@"WORKING ============");
    } else {
        NSLog(@"NOT WORKING ============");
    }
    return self;
}

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)dealloc {
    [_usernameField release];
    [_passwordField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInPressed:(id)sender {
    NSString *username = [_usernameField text];
    NSString *password = [_passwordField text];
    
    NSArray *keys = [NSArray arrayWithObjects:@"username", @"password", nil];
    NSArray *objects = [NSArray arrayWithObjects:username, password, nil];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSData *jsonData ;
    NSString *jsonString;
    if([NSJSONSerialization isValidJSONObject:jsonDictionary]) {
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString *requestString = [NSString stringWithFormat:
                               @"http://10.190.71.27:3000/users"];
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSError *errorReturned = nil;
    NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
    
    if (errorReturned) {
        NSLog(@"Error %@",errorReturned.description);
    } else {
        NSError *jsonParsingError = nil;
        NSMutableArray *arrDoctorInfo  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonParsingError];
        
        NSLog(@"Dict %@",arrDoctorInfo);
        
        
        MenuViewController *menuViewController = [[[MenuViewController alloc] init] autorelease];
        [menuViewController setModalPresentationStyle:UIModalPresentationFormSheet];
        
        //  Animates the modal only if it's an iPad
        BOOL shouldAnimateTransition = NO;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            shouldAnimateTransition = YES;
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
//            [self presentModalViewController:aboutViewController animated:shouldAnimateTransition];
            
            UIViewController *presentingViewController = [self presentingViewController];
            [menuViewController presentMenuViewController:self animated:YES completion:nil presentingViewController:presentingViewController];
        });
        
    }
    
}

@end
