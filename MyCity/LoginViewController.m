//
//  LoginViewController.m
//  MyCity
//
//  Created by Emerson Malca on 6/19/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import "LoginViewController.h"
#import "SBJson.h"

#define kUserTokenKey       @"UserTokenKey"

@implementation LoginViewController

@synthesize usernameField;
@synthesize pwField;
@synthesize confirmPwField;
@synthesize cancelBtn;
@synthesize mainBtn;
@synthesize createAccountBtn;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBg"]]];
    
    [self registerForKeyboardNotifications];
    [self.scrollView setContentSize:self.view.frame.size];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)mainAction {
    if (_registerMode) {
        [self confirmRegistration];
    } else {
        [self confirmLogin];
    }
}

- (IBAction)createAccountAction {
    CGRect mainBtnFinalFrame = CGRectOffset(self.mainBtn.frame, 0.0, 50.0);
    [self.mainBtn setTitle:@"Sign up" forState:UIControlStateNormal];
    _registerMode = YES;
    [UIView animateWithDuration:0.5
                     animations:^ {
                         [self.mainBtn setFrame:mainBtnFinalFrame];
                         [self.confirmPwField setAlpha:1.0];
                         [self.createAccountBtn setAlpha:0.0];
                     }];
}

- (void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)confirmLogin {
    [self dismissKeyboardIfNeeded];
    
    // Build the string
    NSString *urlString = [NSString stringWithFormat:@"http://mycity.heroku.com/api/users"];
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Setup and start async download
    NSString *body = [NSString stringWithFormat:@"user[email]=%@&user[password]=%@", [self.usernameField text], [self.pwField text]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSStringEncodingConversionAllowLossy]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection release];
    [request release];
}

- (void)confirmRegistration {
    
    [self dismissKeyboardIfNeeded];
    
    //Confirm that password and confirm password are the same, or less than 6 characters
    if (![self.pwField.text isEqualToString:self.confirmPwField.text]) {
        //If they are not equal we alert the user
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Wrong password" 
                                                             message:@"Please enter the same password on both password fields"
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    } else if ([self.pwField.text length] < 6) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Too short" 
                                                             message:@"Password needs to be at least 6 characters long"
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    //Validation passed, sent request to server
    
    // Build the string
    NSString *urlString = [NSString stringWithFormat:@"http://mycity.heroku.com/api/users"];
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Setup and start async download
    NSString *body = [NSString stringWithFormat:@"user[email]=%@&user[password]=%@", [self.usernameField text], [self.pwField text]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSStringEncodingConversionAllowLossy]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection release];
    [request release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.pwField becomeFirstResponder];
    } else if (textField == self.pwField) {
        [self.confirmPwField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    
    NSLog(@"Connection did receive response %@", [response description]);
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    // Store incoming data into a string
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Create a dictionary from the JSON string
    id jsonResult = [jsonString JSONValue];
    
    //POST will return an NSDictionary, GET will return an array
    if ([jsonResult isKindOfClass:[NSDictionary class]]) {
        
        NSLog(@"JSON Results Dictionary: %@", [jsonResult description]);
        NSString *authToken = [jsonResult valueForKey:@"auth_token"];
        NSLog(@"Auth token: %@",authToken);
        if (authToken) {
            [[NSUserDefaults standardUserDefaults] setValue:authToken forKey:kUserTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [self dismissModalViewControllerAnimated:YES];
        
    } else if ([jsonResult isKindOfClass:[NSArray class]]) {
        
        
        NSLog(@"JSON Result Array: %@", [jsonResult description]);
        
    } else {
        //We most likely returned an error so alert the user
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Invalid" 
                                                             message:@"The email/password combination is not valid. Please try again."
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {  
    NSLog(@"Connection did fail with error %@", [error description]);
}

#pragma mark -
#pragma mark Keyboard notifications

- (void)dismissKeyboardIfNeeded {
    if ([self.usernameField canResignFirstResponder]) {
        [self.usernameField resignFirstResponder];
    }
    if ([self.pwField canResignFirstResponder]) {
        [self.pwField resignFirstResponder];
    }
    if ([self.confirmPwField canResignFirstResponder]) {
        [self.confirmPwField resignFirstResponder];
    }
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)aNotification {
    CGRect scrollFrame  = self.scrollView.frame, keyboardFrame;
	CGRect normalizedTableFrame = [self.view convertRect:scrollFrame toView:[UIApplication sharedApplication].keyWindow];
	
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardFrame];
	
	CGRect intersection = CGRectIntersection(normalizedTableFrame, keyboardFrame);
	
	scrollFrame.size.height -= intersection.size.height;
    self.scrollView.frame = scrollFrame;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.3 
                     animations:^ {
                         self.scrollView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
                     }];
}

@end
