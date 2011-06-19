//
//  RootViewController.m
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import "SBJson.h"
#import "LoginViewController.h"

#define kRowHeightNormal    44.0
#define kRowHeightSubMenu   88.0
#define kUserTokenKey       @"UserTokenKey"

@interface RootViewController ()
- (void)configureCell:(SwipeableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize textView = _textView;
@synthesize sendBtn = _sendBtn;
@synthesize cancelBtn = _cancelBtn;
@synthesize headerView = _headerView;
@synthesize cityLabel = _cityLabel;

@synthesize locManager = _locManager;
@synthesize geoCoder = _geoCoder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    [self.tableView setTableHeaderView:self.headerView];
    
    //Customize it
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBg"]]];
    [(TISwipeableTableView*)self.tableView setSwipeDelegate:self];
    [self.tableView setDelaysContentTouches:NO];
    
    UIFont *cityFont = [UIFont fontWithName:@"Futura" size:20.0];
    [self.cityLabel setFont:cityFont];
    [self.cityLabel setText:@"Locating city..."];
    
    [self.textView.layer setBorderWidth:1.0];
    [self.textView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.textView.layer setCornerRadius:10.0];
    
    [self registerForKeyboardNotifications];
    
    [self startLocationManager];
    
    if (_issuesArray == nil) {
        _issuesArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getIssues];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *userToken = [[NSUserDefaults standardUserDefaults] stringForKey:kUserTokenKey];
    if (userToken == nil && !_loginInitiallyShown) {
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self presentModalViewController:login animated:YES];
        _loginInitiallyShown = YES;
        [login release];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_issuesArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SwipeableCell *cell = (SwipeableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        cell = [[[SwipeableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setDelegate:self];
    }

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(TISwipeableTableView*)tableView showBackForCellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	
	NSLog(@"Did swipe");
}

- (void)swipeableCellFixItButtonWasPressed:(SwipeableCell *)cell {
    
    [(TISwipeableTableView*)self.tableView hideVisibleBackView:YES];
    
    //The fix it button was pressed for a cell, time to vote if the user has logged in
    NSString *userToken = [[NSUserDefaults standardUserDefaults] stringForKey:kUserTokenKey];
    if (userToken == nil) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Log in" 
                                                             message:@"You need to be logged in to vote to fix existing issues"
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *issue = [_issuesArray objectAtIndex:indexPath.row];
    NSString *issueID = [issue objectForKey:@"_id"];
    
    // Build the string
    //NOTE: We need to pass the auth token in the URL
    NSString *urlString = [NSString stringWithFormat:@"http://mycity.heroku.com/api/issues/%@/votes?auth_token=%@", issueID, userToken];
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Setup and start async download
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection release];
    [request release];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	
	[(TISwipeableTableView*)self.tableView hideVisibleBackView:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.textView = nil;
    self.sendBtn = nil;
    self.cancelBtn = nil;
    self.headerView = nil;
    if (_issuesArray) {
        [_issuesArray release];
    }
    self.cityLabel = nil;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)configureCell:(SwipeableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *issue = [_issuesArray objectAtIndex:indexPath.row];
    [cell setText:[issue objectForKey:@"title"]];
    [cell setVotes:[issue objectForKey:@"votes_count"]];
}

#pragma mark-
#pragma mark Text view delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!_issueHasText) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    _issueHasText = [textView hasText];
    if (![textView hasText]) {
        [textView setText:@"Report an issue"];
        [textView setTextColor:[UIColor lightGrayColor]];
    }
}

#pragma mark-
#pragma mark Custom methods 

- (IBAction)sendIssue {
    
    //Save the issue text and remove it from the textview
    NSString *issueText = [NSString stringWithString:_textView.text];
    
    [_textView setText:@"Report an issue"];
    [_textView setTextColor:[UIColor lightGrayColor]];
    
    if ([_textView canResignFirstResponder]) {
        [_textView resignFirstResponder];
    }
    
    // Build the string
    NSString *urlString = 
    [NSString stringWithFormat:@"http://mycity.heroku.com/api/issues"];
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Setup and start async download
    NSString *body = [NSString stringWithFormat:@"issue[title]=%@", issueText];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSStringEncodingConversionAllowLossy]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection release];
    [request release];
}

- (IBAction)cancelIssue {
    if ([_textView canResignFirstResponder]) {
        [_textView resignFirstResponder];
    }
}

- (IBAction)getIssues {
    // Build the string
    NSString *urlString = 
    [NSString stringWithFormat:@"http://mycity.heroku.com/api/issues"];
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Setup and start async download
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection release];
    [request release];
}

#pragma mark -
#pragma mark Geolocation

- (void)startLocationManager {
    self.locManager = [[[CLLocationManager alloc] init] autorelease];
    [self.locManager setDelegate:self];
    [self.locManager startUpdatingLocation];
}

// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
    // this creates a MKReverseGeocoder to find a placemark using the found coordinates
    if (self.geoCoder == nil) {
        self.geoCoder = [[[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate] autorelease];
        self.geoCoder.delegate = self;
        [self.geoCoder start];
    }
}

// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
}
// this delegate is called when the reverseGeocoder finds a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    MKPlacemark * myPlacemark = placemark;
    // with the placemark you can now retrieve the city name
    NSString *city = [myPlacemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
    [self.cityLabel setText:city];
}

// this delegate is called when the reversegeocoder fails to find a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"reverseGeocoder:%@ didFailWithError:%@", geocoder, error);
}

#pragma mark -
#pragma mark Keyboard notifications

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    //Show the cancel btn to get rid of the keyboard
    [UIView animateWithDuration:0.3
                     animations:^ {
                         [_cancelBtn setAlpha:1.0];
                     }];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    //Show the cancel btn to get rid of the keyboard
    [UIView animateWithDuration:0.3
                     animations:^ {
                         [_cancelBtn setAlpha:0.0];
                     }];
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
        
        NSLog(@"JSON Results: %@", [jsonResult description]);
        
        //If we returned an issue, it will have a title value
        if ([jsonResult valueForKey:@"title"]) {
            
            [_issuesArray insertObject:jsonResult atIndex:0];
            
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
        } else {
            //Else, it is a vote
            //Find the issue associated with it
            NSString *issue_id = [jsonResult valueForKey:@"issue_id"];
            NSUInteger index = [_issuesArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                    NSString *issueID = [obj valueForKey:@"_id"];
                if ([issueID isEqualToString:issue_id]) {
                    //We want to manually update the vote count, to avoid having to call the server again
                    NSNumber *votesCount = [obj valueForKey:@"votes_count"];
                    NSUInteger votes = [votesCount integerValue];
                    votes++;
                    [obj setValue:[NSNumber numberWithInteger:votes] forKey:@"votes_count"];
                    *stop = YES;
                    return YES;
                }
                return NO;
                                }];
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewScrollPositionNone];
            [self.tableView endUpdates];
        }
        
        
    } else if ([jsonResult isKindOfClass:[NSArray class]]) {

        
        [_issuesArray removeAllObjects];
        [_issuesArray addObjectsFromArray:jsonResult];
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }

}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {  
    NSLog(@"Connection did fail with error %@", [error description]);
}

@end
