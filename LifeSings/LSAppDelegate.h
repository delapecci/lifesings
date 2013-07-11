//
//  LSAppDelegate.h
//  LifeSings
//
//  Created by lichong on 13-7-11.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
