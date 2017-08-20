//
//  AppDelegate.m
//  ContactMap
//
//  Created by Gopal on 19/08/17.
//  Copyright © 2017 Sagoon. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      [GMSServices provideAPIKey:@"AIzaSyBJEt_aRsWzOOJm7gbidB8_MgYPjVkyW2g"];
      [GMSPlacesClient provideAPIKey:@"AIzaSyBIPcTQSlGLWeb2qfsG9MdpELS9hn4SDiY"];
      return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveContext];
}


#pragma mark - Core Data stack

- (void)saveContext{
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			abort();
		}
	}
}
- (NSManagedObjectContext *)managedObjectContext{
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

- (NSManagedObjectModel *)managedObjectModel{
	if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ContactMap" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil) {
		return _persistentStoreCoordinator;
	}
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ContactMap.sqlite"];
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            abort();
	}
	return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
