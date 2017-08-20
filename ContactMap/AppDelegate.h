//
//  AppDelegate.h
//  ContactMap
//
//  Created by Gopal on 19/08/17.
//  Copyright © 2017 Sagoon. All rights reserved.
//
@import GoogleMaps;
@import GooglePlaces;
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,NSObject>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;


@end

