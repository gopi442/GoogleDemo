//
//  ShowContactsViewController.m
//  ContactMap
//
//  Created by Wydr on 19/08/17.
//  Copyright © 2017 Sagoon. All rights reserved.
//


#define WINDOW_HEIGHT              [UIScreen mainScreen].bounds.size.height
#define WINDOW_WIDTH               [UIScreen mainScreen].bounds.size.width

@import GoogleMaps;
#import "ShowContactsViewController.h"
#import <CoreData/CoreData.h>
@interface ShowContactsViewController ()
{
      __weak IBOutlet UIButton *addContactShow;
             IBOutlet UIButton *btnAddContact;
	          NSMutableArray *contactsForMap;
                GMSMapView     *mapView_;
}

@end
@implementation ShowContactsViewController
@synthesize contactsForMap;
- (void)viewDidLoad {
    [super viewDidLoad];
     addContactShow.hidden=YES;
     btnAddContact.layer.cornerRadius=8;
}

-(void) viewDidAppear:(BOOL)animated{

      [self fetchAllContacts];
}
-(void) fetchAllContacts{
      NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ContactInfo"];
      contactsForMap = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
      if ([contactsForMap count]>0 && contactsForMap!=nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
            addContactShow.hidden=YES;
            mapView_.hidden=NO;
            });
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.664392
                                                                    longitude:77.446532
                                                                         zoom:7];
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT) camera:camera];
            mapView_.myLocationEnabled = YES;
            [self.view addSubview:mapView_];
            for(int i=0;i<[contactsForMap count];i++)
              {
                  NSManagedObject *contactInfo = [contactsForMap objectAtIndex:i];
                  NSString *name=[contactInfo valueForKey:@"contact_name"];
                  NSString *phone=[contactInfo valueForKey:@"phone_num"];
                  NSString *email=[contactInfo valueForKey:@"email"];
                  NSString *lat = [contactInfo valueForKey:@"latitude"];
                  NSString *lon = [contactInfo valueForKey:@"longitude"];
                  double lt=[lat floatValue];
                  double ln=[lon floatValue];
                  GMSMarker *marker = [[GMSMarker alloc] init];
                  marker.position = CLLocationCoordinate2DMake(lt,ln );
                  marker.title = [NSString stringWithFormat:@"%@,%@",name,phone];
                  marker.snippet =[NSString stringWithFormat:@"%@",email];
                  marker.map = mapView_;
              }
      }
      else{
            dispatch_async(dispatch_get_main_queue(), ^{
            addContactShow.hidden=NO;
            mapView_.hidden=YES;
             });

      }
}
- (IBAction)addContacts:(id)sender {
	AddContactViewController *addContact=[self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
	[self.navigationController pushViewController:addContact animated:YES];
}

- (NSManagedObjectContext *)managedObjectContext {
	NSManagedObjectContext *context = nil;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		context = [delegate managedObjectContext];
	}
	return context;
}

- (IBAction)addMoreContacts:(id)sender {
	AddContactViewController *addContact=[self.storyboard instantiateViewControllerWithIdentifier:@"AddContactViewController"];
	[self.navigationController pushViewController:addContact animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
