//
//  AppDelegate.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "AppDelegate.h"
#import "CheckNetwork.h"
#import "MainPageView.h"
#import "DayQuestionPageView.h"
#import "NewMessagePageView.h"
#import "BuyPageView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    //检查网络是否存在 如果不存在 则弹出提示
    [UserModel Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bg"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
    //实例化主窗口
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    //首页
    UINavigationController *mainNavController = [[UINavigationController alloc] initWithRootViewController:[[MainPageView alloc] init]];
    //每日一问
    UINavigationController *daysAskNavController = [[UINavigationController alloc] initWithRootViewController:[[DayQuestionPageView alloc] init]];
    //最新资讯
    UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:[[NewMessagePageView alloc] init]];
    //买猪脚
    UINavigationController *buyNavController = [[UINavigationController alloc] initWithRootViewController:[[BuyPageView alloc] init]];
    
    // If the device is an iPad, we make it taller.
    _tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70 : 50];
    
    [_tabBarController setMinimumHeightToDisplayTitle:40.0];
    
    [_tabBarController setViewControllers:[NSMutableArray arrayWithObjects:
                                           mainNavController,
                                           daysAskNavController,
                                           newNavController,
                                           buyNavController, nil]];
    
    // Tab background Image
    [_tabBarController setBackgroundImageName:@"navigation_bg.png"];
    [_tabBarController setSelectedBackgroundImageName:@"navigation_bg_p.png"];
    
    //设置图标的颜色无论是默认还是选中状态都为白色
    [_tabBarController setIconColors:@[[UIColor colorWithRed:1 green:1 blue:1 alpha:1],
                                       [UIColor colorWithRed:1 green:1 blue:1 alpha:1]]]; // MAX 2 Colors
    
    [_tabBarController setSelectedIconColors:@[[UIColor colorWithRed:1 green:1 blue:1 alpha:1],
                                               [UIColor colorWithRed:1 green:1 blue:1 alpha:1]]]; // MAX 2 Colors
    // Tabs top embos Color
    [_tabBarController setTabEdgeColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    
    [_window setRootViewController:_tabBarController];
    [_window makeKeyAndVisible];

    // Below you will find an example of possible customization, just uncomment the lines
    
    /*
     // Tab background Image
     [_tabBarController setBackgroundImageName:@"noise-dark-gray.png"];
     [_tabBarController setSelectedBackgroundImageName:@"noise-dark-blue.png"];
     
     
     
     // Tabs Colors settings
     [_tabBarController setTabColors:@[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.0],
     [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]]]; // MAX 2 Colors
     
     [_tabBarController setSelectedTabColors:@[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0],
     [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0]]]; // MAX 2 Colors
     
     
     
     // Icons Color settings
     [_tabBarController setIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1],
     [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors
     
     [_tabBarController setSelectedIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1],
     [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors
     
     // Text Color
     [_tabBarController setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
     [_tabBarController setSelectedTextColor:[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0]];
     
     // Hide / Show glossy on tab icons
     [_tabBarController setIconGlossyIsHidden:YES];
     */

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.greenorange.BowlKitchen" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BowlKitchen" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BowlKitchen.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
