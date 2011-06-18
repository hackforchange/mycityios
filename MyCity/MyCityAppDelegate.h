//
//  MyCityAppDelegate.h
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCityAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
