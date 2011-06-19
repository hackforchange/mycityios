//
//  LoginViewController.h
//  MyCity
//
//  Created by Emerson Malca on 6/19/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    BOOL _registerMode;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *pwField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPwField;
@property (nonatomic, retain) IBOutlet UIButton *cancelBtn;
@property (nonatomic, retain) IBOutlet UIButton *mainBtn;
@property (nonatomic, retain) IBOutlet UIButton *createAccountBtn;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)mainAction;
- (IBAction)createAccountAction;
- (IBAction)cancel;
- (void)confirmLogin;
- (void)confirmRegistration;

- (void)registerForKeyboardNotifications;
- (void)dismissKeyboardIfNeeded;

@end
