//
//  LSAppDelegate.m
//  LifeSings
//
//  Created by lichong on 13-7-11.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import "LSAppDelegate.h"
#import "UIColor+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UIImage+FlatUI.h"

#import "KxIntroViewController.h"
#import "KxIntroViewPage.h"
#import "KxIntroView.h"

#import "LSLeftSideMenuViewController.h"
#import "MMDrawerController.h"
#import "DDFileLogger.h"

@implementation LSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

//    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
//    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//
//    [DDLog addLogger:fileLogger];
    [self initTheme];

    // 加载用户配置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger typeNum = [userDefaults integerForKey:@"rynthm_type"];
    if (!typeNum) {
        typeNum = 1;
        [userDefaults setInteger:typeNum forKey:@"rynthm_type"];
    }

    //NSString *showIntroSettingString = [userDefaults stringForKey:@"should_show_intro"];

    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainNavViewController = [mainStoryBoard instantiateInitialViewController];

    UIViewController * leftSideDrawerViewController = [[LSLeftSideMenuViewController alloc] init];
    MMDrawerController * drawerController = [[MMDrawerController alloc]
    initWithCenterViewController:mainNavViewController
    leftDrawerViewController:leftSideDrawerViewController
    rightDrawerViewController:nil];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    [drawerController setMaximumLeftDrawerWidth:screenBounds.size.width / 2];
    // 不打开手势触发菜单
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeTapCenterView];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = drawerController;
    [self.window makeKeyAndVisible];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.window.clipsToBounds =YES;
        
        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
        
        //added on 19th Sep
        self.window.bounds = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height);
    }

    [self showIntro];
    return YES;
}

- (void) initTheme {
    // 自定义主题色调
    UINavigationBar *themeNavBar = [UINavigationBar appearance];
    [themeNavBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [themeNavBar setShadowImage:[UIImage imageWithColor:[UIColor greenSeaColor] cornerRadius:1.0f]];
    themeNavBar.titleTextAttributes = @{UITextAttributeFont: [UIFont flatFontOfSize:21.0f],
            UITextAttributeTextColor: [UIColor whiteColor]};

    //[(UITableView *)[UITableView appearance] setBackgroundColor:[UIColor cloudsColor]];
    //[(UITableView *)[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[application setStatusBarHidden:NO];
    
}

- (void) showIntro
{
    KxIntroViewPage *page0 = [KxIntroViewPage introViewPageWithTitle: @""
                                                          withDetail: @"每一天苦乐相伴，在忘却之前\n简单的指尖滑动，时光留下回声"
                                                           withImage: [UIImage imageNamed:@"intro2.png"]];
    
    KxIntroViewPage *page1 = [KxIntroViewPage introViewPageWithTitle: @""
                                                          withDetail: @"乐音起伏，追忆似水流年\n不同的节奏，相同的感动"
                                                           withImage: [UIImage imageNamed:@"intro3.png"]];

    [page0.detailLabel setFont:[UIFont flatFontOfSize:19.0f]];
    [page1.detailLabel setFont:[UIFont flatFontOfSize:19.0f]];
    page0.detailLabel.textAlignment = NSTextAlignmentCenter;
    page1.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    KxIntroViewController *vc = [[KxIntroViewController alloc ] initWithPages:@[ page0, page1 ]];

    vc.introView.backgroundColor = [UIColor midnightBlueColor];
    vc.introView.animatePageChanges = YES;
    vc.introView.gradientBackground = YES;
    
    //[vc presentInView:self.window.rootViewController.view];
    [vc presentInViewController:self.window.rootViewController fullScreenLayout:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LifeSings" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LifeSings.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current     managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
        */

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
