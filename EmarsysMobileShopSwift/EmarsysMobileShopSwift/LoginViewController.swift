//
//  LoginViewController.swift
//  EmarsysMobileShopSwift
//
//

import UIKit
import EmarsysMobile
import AdSupport

enum UserDefaultsKeys : String {
    case Email = "customer_email"
    case ID = "customer_id"
    case DetailLogic = "item_detail_logic"
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var customerIdTextField: UITextField!
    @IBOutlet weak var itemRecommendedLogic: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var enableLoginWithEmail: UISwitch!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    var isLogin: Bool = false
    
    @IBAction func login(sender: UIBarButtonItem) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let emarsysSession = EMSession.sharedSession()
        let loginWithEmail = enableLoginWithEmail.on
        var message: String!
        
        if isLogin {
            loginButton.title = "Login"
            isLogin = false
            emarsysSession.customerEmail = nil
            emarsysSession.customerID = nil
            message = "Logout successful"
        } else if loginWithEmail {
            if let email = defaults.objectForKey(UserDefaultsKeys.Email.rawValue) {
                emarsysSession.customerEmail = email as? String
                message = "Login was successful"
                loginButton.title = "Logout"
                isLogin = true
            } else {
                message = "Please set email"
            }
        } else {
            if let customerId = defaults.objectForKey(UserDefaultsKeys.ID.rawValue) {
                emarsysSession.customerID = customerId as? String
                message = "Login was successful"
                loginButton.title = "Logout"
                isLogin = true
            } else {
                message = "Please set customer id"
            }
        }
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) in })
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(sender: UIButton) {
        
        // Store the data
        let defaults = NSUserDefaults.standardUserDefaults()
        if let email = emailTextField.text {
            /// Set customer email address.
            defaults.setObject(email, forKey: UserDefaultsKeys.Email.rawValue)
        }
        
        if let customerId = customerIdTextField.text {
            /// Set customer id.
            defaults.setObject(customerId, forKey: UserDefaultsKeys.ID.rawValue)
        }
        
        let selectedSegment = itemRecommendedLogic.selectedSegmentIndex
        let logic = selectedSegment == 0 ? "RELATED" : "ALSO_BOUGHT"
        
        defaults.setObject(logic, forKey: UserDefaultsKeys.DetailLogic.rawValue)
        defaults.synchronize()
        
        let alert = UIAlertController(title: "Save was successful", message: nil, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) in })
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showIDs(sender: AnyObject) {
        let alert = UIAlertController(title: "IDFA:\n\(ASIdentifierManager.sharedManager().advertisingIdentifier?.UUIDString ?? "nil")\n\nAdvertising UUID:\n\(EMSession.sharedSession().advertisingID)", message: nil, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) in })
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let email = defaults.objectForKey(UserDefaultsKeys.Email.rawValue) {
            emailTextField.text = email as? String
        }
        
        if let id = defaults.objectForKey(UserDefaultsKeys.ID.rawValue) {
            customerIdTextField.text = id as? String
        }
        
        if let userLogic = defaults.objectForKey(UserDefaultsKeys.DetailLogic.rawValue) {
            let logic = userLogic as! String
            itemRecommendedLogic.selectedSegmentIndex = (logic == "ALSO_BOUGHT" ? 1 : 0)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
