//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//


//Development URL
//#define base_URL @"http://103.15.232.35/ivy/webservices/"


//Staging URL
//#define base_URL @"http://103.15.232.35/singsys-stg3/ivy/webservices/"


//Production URL
#define base_URL @"http://54.169.203.88/webservices/"



#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


#import <AFNetworking/AFNetworking.h>
//#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "AFNetworkReachabilityManager.h"
//#import "AFHTTPRequestOperation.h"
//#import "AFHTTPRequestOperationManager.h"

//#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
//#import "AFNetworking.h"
//#import "UIProgressView+AFNetworking.h"
#import <UIImageView+AFNetworking.h>
#import "SWTableViewCell.h"
//#import <SWTableViewCell/SWTableViewCell.h>
#import "CircularProgressView.h"
#import "CustomBadge.h"
//#import "BluetoothManager.h"

#define login_URL @"login.php"
#define logout_URL @"logout.php"
#define registration_URL @"registration.php"
#define forgotpwd_URL @"forgot-password.php"
#define contactUs_URL @"contact-us.php"
#define changePassword_URL @"changepassword.php"
#define generalSettings_URL @"general-settings.php"
#define viewProfile_URL @"view-profile.php"
#define static_URL @"static-pa ges.php"
#define viewGeneralSettings_URL @"view-general-settings.php"
#define editProfile_URL @"myprofile.php"
#define addPhonebook_URL @"add-phonebook.php"
#define searchUser_URL @"view-search-phonebook-users.php"
//#define addUser_URL @"add-phonebook-user.php"
#define addUser_URL @"add-single-phonebook-contact.php"

#define deleteUser_URL @"delete-phonebook-user.php"
#define defaultUser_URL @"user-number.php"
#define viewAppUser_URL @"view-search-app-users.php"
#define addAppUser_URL @"add-app-users.php"

#define deleteAppUser_URL @"delete-app-users.php"
#define locationUpdate_URL @"user-lat-long-update.php"
#define manageContact_URL @"user-added-contacts.php"
#define addDevice_URL @"add-device.php"
#define viewDevice_URL @"view-device-list.php"
#define viewDeviceDetail_URL @"view-device.php"
#define deleteDevice_URL @"delete-device.php"
#define countryList_URL @"country-list.php"
#define sendAlert_URL @"send-alert.php"
#define listOfAlerts_URL @"list-alerts.php"
#define senderAlert_URL @"sender-alert-detail.php"
#define recieverAlert_URL @"receiver-alert-detail.php"
#define markAsSafe_URL @"alert-mark-safe.php"

#define alert_response_URL @"sender-alert-response.php"

#define cancel_URL @"cancel-alert.php"
#define notificationList_URL @"list-alerts.php"
#define notificationListData_URL @"notification_list.php"
#define myNotificationListData_URL @"my_notification_list.php"
#define userRing_URL @"user-ring.php"
#define twillio_calling_URL @"twillio-calling.php"
