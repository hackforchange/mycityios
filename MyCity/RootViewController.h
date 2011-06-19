//
//  RootViewController.h
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextViewDelegate> {
    
    BOOL _issueHasText;
    
    NSMutableArray *_issuesArray;
    
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIButton *sendBtn;
@property (nonatomic, retain) IBOutlet UIButton *cancelBtn;
@property (nonatomic, retain) IBOutlet UIView *headerView;

@property (nonatomic, retain) CLLocationManager *locManager;

- (IBAction)sendIssue;
- (IBAction)cancelIssue;

- (IBAction)getIssues;

- (void)registerForKeyboardNotifications;

- (void)startLocationManager;

@end
