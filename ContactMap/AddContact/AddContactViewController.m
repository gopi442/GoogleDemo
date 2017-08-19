//
//  AddContactViewController.m
//  ContactMap
//
//  Created by Wydr on 19/08/17.
//  Copyright © 2017 Sagoon. All rights reserved.
//

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ONLY_NUMBERS @" +-0123456789"

#import "AddContactViewController.h"
#import "ShowContactsViewController.h"
#import <CoreData/CoreData.h>
#import <GooglePlaces/GooglePlaces.h>
#import "UIView+Toast.h"
@interface AddContactViewController ()<GMSAutocompleteViewControllerDelegate>{
	
	__weak IBOutlet UITextField *txtname;
	__weak IBOutlet UITextField *txtphone_num;
	__weak IBOutlet UITextField *txtemail;


      IBOutlet UIButton *btnGetLocation;
      IBOutlet UIButton *btnSaveContact;
      IBOutlet UIButton *btnShowAllContact;
	
	__weak IBOutlet UILabel *lblYouLocation;
	NSString *strLat,*strLong;

}

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      txtname.tag=1001;
      txtphone_num.tag=1002;
      btnSaveContact.layer.cornerRadius=8;
      btnGetLocation.layer.cornerRadius=8;
      btnShowAllContact.layer.cornerRadius=8;
	
}
- (IBAction)getYourLocation:(id)sender {
	GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
	acController.delegate = self;
	[self presentViewController:acController animated:YES completion:nil];
}
- (IBAction)saveContact:(id)sender {
	
	[txtname resignFirstResponder];
	[txtphone_num resignFirstResponder];
	[txtemail resignFirstResponder];
	BOOL isOk=[self NSStringIsValidEmail:txtemail.text];
	if ([txtname.text isEqualToString:@""]) {
		[self.view makeToast:@"name can not be blank" duration:1.0 position:CSToastPositionBottom];
		return;
	}
	else if ([txtphone_num.text isEqualToString:@""]){
		[self.view makeToast:@"phone can not be blank" duration:1.0 position:CSToastPositionBottom];
		return;
	}
	else if (txtphone_num.text.length !=10) {
		[self.navigationController.view makeToast:@"Please enter 10 digit valid phone number" duration:1.0 position:CSToastPositionBottom];
		return;
	}
	else if ([txtemail.text isEqualToString:@""]){
		[self.view makeToast:@"email can not be blank" duration:1.0 position:CSToastPositionBottom];
		return;
	}
	else if (isOk==NO) {
		[self.navigationController.view makeToast:@"Please enter valid email" duration:1.0 position:CSToastPositionBottom];
		return;
	}
	else if (strLat==nil || strLong==nil ){
		[self.view makeToast:@"please set your location" duration:1.0 position:CSToastPositionBottom];
		return;
	}
	else{
		NSManagedObjectContext *context = [self managedObjectContext];
		NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"ContactInfo" inManagedObjectContext:context];
		[newDevice setValue:txtname.text forKey:@"contact_name"];
		[newDevice setValue:txtphone_num.text forKey:@"phone_num"];
		[newDevice setValue:txtemail.text forKey:@"email"];
		[newDevice setValue:strLat forKey:@"latitude"];
		[newDevice setValue:strLong forKey:@"longitude"];
		
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
		}
		else{
                  txtname.text=@"";
                  txtphone_num.text=@"";
                  txtemail.text=@"";
                  strLat=nil;
                  strLong=nil;
                  lblYouLocation.text=@"";
			[self.view makeToast:@"save successfully !" duration:1.0 position:CSToastPositionBottom];
		}
	}
	
	
}
- (IBAction)showAllContacts:(id)sender {
//	ShowContactsViewController *showContacts=[self.storyboard instantiateViewControllerWithIdentifier:@"ShowContactsViewController"];
//	[self.navigationController pushViewController:showContacts animated:YES];
      [self.navigationController popViewControllerAnimated:YES];
}

- (NSManagedObjectContext *)managedObjectContext {
	NSManagedObjectContext *context = nil;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		context = [delegate managedObjectContext];
	}
	return context;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
	[self dismissViewControllerAnimated:YES completion:nil];
  	strLat=[NSString stringWithFormat:@"%f",place.coordinate.latitude];
	strLong=[NSString stringWithFormat:@"%f",place.coordinate.longitude];
	lblYouLocation.text=[NSString stringWithFormat:@"%@",place.name];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion:nil];
	NSLog(@"Error: %@", [error description]);
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
      if (textField.tag==1001) {
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            return [string isEqualToString:filtered];
      }
     else if (textField.tag==1002) {
            NSUInteger newLength = textField.text.length + string.length - range.length;
            if( newLength<11)
              {
                  NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:ONLY_NUMBERS] invertedSet];
                  NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
                  return [string isEqualToString:filtered];
              }
            else
                  return NO;
      }
      else{
            return YES;
      }
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	[textField resignFirstResponder];
	return NO;
}


-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
	NSString *emailRegex = @"[A-Z0-9a-z][A-Z0-9a-z._%+-]*@[A-Za-z0-9][A-Za-z0-9.-]*\\.[A-Za-z]{2,6}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	NSRange aRange;
	if([emailTest evaluateWithObject:checkString]) {
		aRange = [checkString rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [checkString length])];
		int indexOfDot = (int)aRange.location;
		
		if(aRange.location != NSNotFound) {
			NSString *topLevelDomain = [checkString substringFromIndex:indexOfDot];
			topLevelDomain = [topLevelDomain lowercaseString];
			
			NSSet *TLD;
			TLD = [NSSet setWithObjects:@".aero", @".asia", @".biz", @".cat", @".com", @".coop", @".edu", @".gov", @".info", @".int", @".jobs", @".mil", @".mobi", @".museum", @".name", @".net", @".org", @".pro", @".tel", @".travel", @".ac", @".ad", @".ae", @".af", @".ag", @".ai", @".al", @".am", @".an", @".ao", @".aq", @".ar", @".as", @".at", @".au", @".aw", @".ax", @".az", @".ba", @".bb", @".bd", @".be", @".bf", @".bg", @".bh", @".bi", @".bj", @".bm", @".bn", @".bo", @".br", @".bs", @".bt", @".bv", @".bw", @".by", @".bz", @".ca", @".cc", @".cd", @".cf", @".cg", @".ch", @".ci", @".ck", @".cl", @".cm", @".cn", @".co", @".cr", @".cu", @".cv", @".cx", @".cy", @".cz", @".de", @".dj", @".dk", @".dm", @".do", @".dz", @".ec", @".ee", @".eg", @".er", @".es", @".et", @".eu", @".fi", @".fj", @".fk", @".fm", @".fo", @".fr", @".ga", @".gb", @".gd", @".ge", @".gf", @".gg", @".gh", @".gi", @".gl", @".gm", @".gn", @".gp", @".gq", @".gr", @".gs", @".gt", @".gu", @".gw", @".gy", @".hk", @".hm", @".hn", @".hr", @".ht", @".hu", @".id", @".ie", @" No", @".il", @".im", @".in", @".io", @".iq", @".ir", @".is", @".it", @".je", @".jm", @".jo", @".jp", @".ke", @".kg", @".kh", @".ki", @".km", @".kn", @".kp", @".kr", @".kw", @".ky", @".kz", @".la", @".lb", @".lc", @".li", @".lk", @".lr", @".ls", @".lt", @".lu", @".lv", @".ly", @".ma", @".mc", @".md", @".me", @".mg", @".mh", @".mk", @".ml", @".mm", @".mn", @".mo", @".mp", @".mq", @".mr", @".ms", @".mt", @".mu", @".mv", @".mw", @".mx", @".my", @".mz", @".na", @".nc", @".ne", @".nf", @".ng", @".ni", @".nl", @".no", @".np", @".nr", @".nu", @".nz", @".om", @".pa", @".pe", @".pf", @".pg", @".ph", @".pk", @".pl", @".pm", @".pn", @".pr", @".ps", @".pt", @".pw", @".py", @".qa", @".re", @".ro", @".rs", @".ru", @".rw", @".sa", @".sb", @".sc", @".sd", @".se", @".sg", @".sh", @".si", @".sj", @".sk", @".sl", @".sm", @".sn", @".so", @".sr", @".st", @".su", @".sv", @".sy", @".sz", @".tc", @".td", @".tf", @".tg", @".th", @".tj", @".tk", @".tl", @".tm", @".tn", @".to", @".tp", @".tr", @".tt", @".tv", @".tw", @".tz", @".ua", @".ug", @".uk", @".us", @".uy", @".uz", @".va", @".vc", @".ve", @".vg", @".vi", @".vn", @".vu", @".wf", @".ws", @".ye", @".yt", @".za", @".zm", @".zw", nil];
			if(topLevelDomain != nil && ([TLD containsObject:topLevelDomain])) {
				return TRUE;
			}
			
			
		}
	}
	return FALSE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}



@end
