//
//  LoginViewController.h
//  EmarsysPredictShop
//

@import UIKit;

UIKIT_EXTERN NSString *const LoginCustomerEmail;
UIKIT_EXTERN NSString *const LoginCustomerId;
UIKIT_EXTERN NSString *const ItemDetailLogic;

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField *emailTextField;
@property(weak, nonatomic) IBOutlet UITextField *customerIdTextField;
@property(weak, nonatomic) IBOutlet UISegmentedControl *itemRecommendedLogic;
@property(weak, nonatomic) IBOutlet UIButton *saveButton;
@property(weak, nonatomic) IBOutlet UISwitch *enableLoginWithEmail;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property BOOL isLogin;
- (IBAction)login:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)showIDs:(id)sender;

@end
