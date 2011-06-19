//
//  RootViewController.m
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SBJson.h"

@interface RootViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize textView = _textView;
@synthesize sendBtn = _sendBtn;
@synthesize cancelBtn = _cancelBtn;
@synthesize headerView = _headerView;

@synthesize locManager = _locManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    [self.tableView setTableHeaderView:self.headerView];
    
    [self.textView.layer setBorderWidth:1.0];
    [self.textView.layer setBorderColor:[UIColor grayColor].CGColor];
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

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
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
}

- (void)dealloc
{
    [super dealloc];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *issue = [_issuesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [issue objectForKey:@"title"];
    cell.detailTextLabel.text = [issue objectForKey:@"created_at"];
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
    if ([_textView canResignFirstResponder]) {
        [_textView resignFirstResponder];
    }
    
    // Build the string
    NSString *urlString = 
    [NSString stringWithFormat:@"http://mycity.heroku.com/api/issues"];
    
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Setup and start async download
    NSString *body = [NSString stringWithFormat:@"issue[title]=%@", [_textView text]];
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

- (void)startLocationManager {
    self.locManager = [[[CLLocationManager alloc] init] autorelease];
    [self.locManager startUpdatingLocation];
    NSLog(@"Location: %@", [[self.locManager location] description]);
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
        [_issuesArray addObject:jsonResult];
        
    } else if ([jsonResult isKindOfClass:[NSArray class]]) {

        
        [_issuesArray removeAllObjects];
        [_issuesArray addObjectsFromArray:jsonResult];
        
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    //Get the keys and values
    //NSLog(@"JSON Title %@", [results objectForKey:@"title"]);

}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {  
    NSLog(@"Connection did fail with error %@", [error description]);
}

@end
