//
//  LoginViewController.m
//  EmarsysPredictShop
//

#import <EmarsysPredictSDK/EmarsysPredictSDK.h>
@import AdSupport.ASIdentifierManager;

#import "LoginViewController.h"

@interface LoginViewController ()

@end

NSString *const LoginCustomerEmail = @"customer_email";
NSString *const LoginCustomerId = @"customer_id";
NSString *const ItemDetailLogic = @"item_detail_logic";

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLogin = false;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *email = [defaults objectForKey:LoginCustomerEmail];
    if (email) {
        [self.emailTextField setText:email];
    }
    NSString *id = [defaults objectForKey:LoginCustomerId];
    if (id) {
        [self.customerIdTextField setText:id];
    }

    NSString *itemLogic = [defaults objectForKey:ItemDetailLogic];
    if (itemLogic) {
        NSInteger i = 0;
        if ([itemLogic isEqualToString:@"RELATED"]) {
            i = 0;
        } else if ([itemLogic isEqualToString:@"ALSO_BOUGHT"]) {
            i = 1;
        }
        [self.itemRecommendedLogic setSelectedSegmentIndex:i];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL loginWithEmail = _enableLoginWithEmail.isOn;
    EMSession *emarsysSession = [EMSession sharedSession];
    NSString *message = nil;

    if (self.isLogin) {
        [self.loginButton setTitle:@"Login"];
        self.isLogin = false;
        [emarsysSession setCustomerEmail:nil];
        [emarsysSession setCustomerID:nil];
        message = @"Logout successful";
    } else {
        if (loginWithEmail) {
            NSString *email = [defaults objectForKey:LoginCustomerEmail];
            if (email) {
                [emarsysSession setCustomerEmail:email];
                message = @"Login was successful";
                [self.loginButton setTitle:@"Logout"];
                self.isLogin = true;
            } else {
                message = @"Please set email";
            }
        } else {
            NSString *customerId = [defaults objectForKey:LoginCustomerId];
            if (customerId) {
                [emarsysSession setCustomerID:customerId];
                message = @"Login was successful";
                [self.loginButton setTitle:@"Logout"];
                self.isLogin = true;
            } else {
                message = @"Please set customer id";
            }
        }
    }

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:message
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                               }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)save:(id)sender {

    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.emailTextField.hasText) {
        /// Set customer email address.
        [defaults setObject:self.emailTextField.text forKey:LoginCustomerEmail];
    }

    if (self.customerIdTextField.hasText) {
        /// Set customer id.
        [defaults setObject:self.customerIdTextField.text
                     forKey:LoginCustomerId];
    }

    NSInteger selectedSegment = _itemRecommendedLogic.selectedSegmentIndex;

    NSString *logic;

    if (selectedSegment == 0) {
        logic = @"RELATED";
    } else {
        logic = @"ALSO_BOUGHT";
    }

    [defaults setObject:logic forKey:ItemDetailLogic];
    [defaults synchronize];

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Save was successful"
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                               }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)showIDs:(id)sender {
    NSString *message =
        [NSString stringWithFormat:@"IDFA:\n%@\n\nAdvertising UUID:\n%@",
                                   [[ASIdentifierManager sharedManager]
                                       advertisingIdentifier]
                                       .UUIDString,
                                   [[EMSession sharedSession] advertisingID]];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:message
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                               }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
