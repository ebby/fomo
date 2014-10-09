//
//  WelcomeViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/21/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SignupViewController.h"
#import "NBAsYouTypeFormatter.h"
#import "Client.h"
#import "User.h"
#import "LoadingViewController.h"
#import <TSMessages/TSMessage.h>
#import <FacebookSDK/FacebookSDK.h>

@interface WelcomeViewController () <FBLoginViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) SignupViewController *signupViewController;
@property (strong, nonatomic) NBAsYouTypeFormatter *phoneFormatter;
@property (strong, nonatomic) NSMutableString *phoneNumber;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (assign) BOOL signin;
@property (nonatomic) NSUInteger lastPhoneLength;

@end

@implementation WelcomeViewController {
    UIButton *_facebookButton;
    UIButton *_twitterButton;
    UIActionSheet *_twitterAccountsSheet;
    
    UIButton *_signupButton;
    UIButton *_signinButton;
    UIView *_signupView;
    
    UITextField *_usernameInput;
    UITextField *_phoneInput;
    UITextField *_passwordInput;
    UIButton *_closeButton;
    UILabel *_signupTitle;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);

    self.view.backgroundColor = [UIColor colorWithRed:127.0/255.0 green:140.0/255.0 blue:141.0/255.0 alpha:1.0];
    
    
    _facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth/2 - 100, viewHeight - 150, 200, 60)];
    [_facebookButton setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
    _facebookButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _facebookButton.titleLabel.font = [UIFont fontWithName:@"MrsEaves-Italic" size:28];
    [_facebookButton addTarget:self action:@selector(_handleFacebookButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_facebookButton];
    
    _twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth/2 - 100, viewHeight - 100, 200, 60)];
    [_twitterButton setTitle:@"Connect with Twitter" forState:UIControlStateNormal];
    _twitterButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _twitterButton.titleLabel.font = [UIFont fontWithName:@"MrsEaves-Italic" size:28];
    [_twitterButton addTarget:self action:@selector(_handleTwitterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_twitterButton];

    
//    _signupButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth/2 - 100, viewHeight - 100, 200, 60)];
//    //_signupButton.backgroundColor = [UIColor whiteColor];
//    [_signupButton setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
//    //_signupButton.titleLabel.textColor = [UIColor blackColor];
//    _signupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    _signupButton.titleLabel.font = [UIFont fontWithName:@"MrsEaves-Italic" size:28];
//    [_signupButton addTarget:self action:@selector(_handleSignupButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_signupButton];
//
//    _signinButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth - 80, 20, 70, 40)];
//    _signinButton.titleLabel.textColor = [UIColor whiteColor];
//    _signinButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    _signinButton.titleLabel.font = [UIFont fontWithName:@"MrsEaves-Italic" size:20];
//    [_signinButton setTitle:@"Login" forState:UIControlStateNormal];
//    [_signinButton addTarget:self action:@selector(_handleSigninButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_signinButton];
    
    // Signup View
    _signupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 300)];
    _signupView.hidden = YES;
    _signupView.alpha = 0;
    [self.view addSubview:_signupView];
    
    // Phone Formatter
    self.phoneFormatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"US"];
    self.phoneNumber = [[NSMutableString alloc] init];
    self.lastPhoneLength = 0;
    
    // Username Input
    _usernameInput = [[UITextField alloc] initWithFrame:CGRectMake(40, 70, 280, 30)];
    _usernameInput.placeholder = @"Username";
    _usernameInput.textColor = [UIColor whiteColor];
    [_signupView addSubview:_usernameInput];
    
    // Phone Input
    _phoneInput = [[UITextField alloc] initWithFrame:CGRectMake(40, 120, 280, 30)];
    _phoneInput.placeholder = @"Phone number";
    _phoneInput.keyboardType = UIKeyboardTypeDecimalPad;
    _phoneInput.textColor = [UIColor whiteColor];
    [_phoneInput addTarget:self action:@selector(_handlePhoneInput:) forControlEvents:UIControlEventEditingChanged];
    [_signupView addSubview:_phoneInput];
    
    // Password Input
    _passwordInput = [[UITextField alloc] initWithFrame:CGRectMake(40, 170, 280, 30)];
    _passwordInput.placeholder = @"Password";
    _passwordInput.secureTextEntry = YES;
    _passwordInput.textColor = [UIColor whiteColor];
    [_signupView addSubview:_passwordInput];
    
    // close button
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth - 48.0f, 20.0f, 40.0f, 40.0f)];
    _closeButton.alpha = 0.8;
    UIImage *closeButtonImage = [UIImage imageNamed:@"close"];
    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(_handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [_signupView addSubview:_closeButton];
    
    // Title
    _signupTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20.0f, viewWidth, 40.0f)];
    _signupTitle.text = @"Join";
    _signupTitle.textAlignment = NSTextAlignmentCenter;
    _signupTitle.userInteractionEnabled = NO;
    _signupTitle.textColor = [UIColor whiteColor];
    [_signupTitle setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:28]];
    [_signupView addSubview:_signupTitle];

    
//    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:
//                              @[@"public_profile", @"email", @"user_friends"]];
//    // Align the button in the center horizontally
//    loginView.frame = CGRectMake(viewWidth/2 - 120, viewHeight - 100, 240, 60);
//    loginView.delegate = self;
//    [self.view addSubview:loginView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_handleFacebookButton:(UIButton *)button
{
    NSArray *permissions = @[@"email"];
    
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nearsight-Info" ofType:@"plist"]];
    NSString *facebookAppId = [plist objectForKey:@"FacebookAppID"];
    
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountTypeFacebook = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = @{
                              ACFacebookAppIdKey: facebookAppId,
                              ACFacebookPermissionsKey: @[@"email"],
                              ACFacebookAudienceKey: ACFacebookAudienceFriends
                              };
    
    [accountStore requestAccessToAccountsWithType:accountTypeFacebook
                                          options:options
                                       completion:^(BOOL granted, NSError *error) {
                                           
                                           if(granted) {
                                               NSLog(@"GRANTED");
                                               
                                               NSArray *accounts = [accountStore accountsWithAccountType:accountTypeFacebook];
                                               
                                               //it will always be the last object with single sign on
                                               ACAccount *facebookAccount = [accounts lastObject];
                                               
                                               //i  got the Facebook UID and logged it here (ANSWER)
                                               
                                               NSLog(@"facebook account =%@",[facebookAccount valueForKeyPath:@"properties.uid"]);
                                               
                                               // Get the access token, could be used in other scenarios
                                               ACAccountCredential *fbCredential = [facebookAccount credential];
                                               NSString *userId = [facebookAccount valueForKeyPath:@"properties.uid"];
                                               NSString *accessToken = [fbCredential oauthToken];
                                               NSLog(@"Facebook Access Token: %@", accessToken);
                                               
                                               [[[[[Client sharedClient] loginWithFacebookId:userId andAccessToken:accessToken]
                                                  doNext:^(User *user) {
                                                      NSLog(@"Logged in");
                                                      [[NSNotificationCenter defaultCenter]
                                                       postNotificationName:@"LoggedIn"
                                                       object:self];
                                                  }]
                                                 // Now the assignment will be done on the main thread.
                                                 deliverOn:RACScheduler.mainThreadScheduler]
                                                subscribeError:^(NSError *error) {
                                                    [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem logging in: " type:TSMessageNotificationTypeError];
                                                }];
                                               
                                           } else {
                                               NSLog(@"Access Denied");
                                               NSLog(@"[%@]",[error localizedDescription]);
                                               [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                                 allowLoginUI:YES
                                                 completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                                     // Handler for session state changes
                                                     // This method will be called EACH time the session state changes,
                                                     // also for intermediate states and NOT just when the session open
                                                     if (state == FBSessionStateOpen) {
                                                         [[[FBSession activeSession] accessTokenData] accessToken];
                                                         [[[[[Client sharedClient] loginWithFacebookId:@""
                                                                                        andAccessToken:[[[FBSession activeSession] accessTokenData] accessToken]]
                                                            doNext:^(User *user) {
                                                                NSLog(@"Logged in");
                                                                [[NSNotificationCenter defaultCenter]
                                                                 postNotificationName:@"LoggedIn"
                                                                 object:self];
                                                            }]
                                                           // Now the assignment will be done on the main thread.
                                                           deliverOn:RACScheduler.mainThreadScheduler]
                                                          subscribeError:^(NSError *error) {
                                                              [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem logging in: " type:TSMessageNotificationTypeError];
                                                          }];
                                                     }
                                                 }];
                                           }
                                       }];
}


- (void)_handleTwitterButton:(UIButton *)button
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
    {
        if (granted == YES)
        {
            self.twitterAccounts = [account accountsWithAccountType:accountType];
            if ([self.twitterAccounts count] == 1)
            {
                ACAccount *twitterAccount = [self.twitterAccounts lastObject];
                NSLog(@"twitter: %@", twitterAccount);
            } else if ([self.twitterAccounts count] > 1) {
                [self performSelectorOnMainThread:@selector(_createTwitterAccountsActionSheet)
                                       withObject:nil
                                    waitUntilDone:YES];
            }
        }
    }];
}

-(void)_createTwitterAccountsActionSheet
{
    // Action sheet
    _twitterAccountsSheet = [[UIActionSheet alloc] init];
    _twitterAccountsSheet.title = @"Select a Twitter Account";
    _twitterAccountsSheet.delegate = self;
    for (ACAccount *account in self.twitterAccounts) {
        NSLog(@"Account: %@", account.username);
        [_twitterAccountsSheet addButtonWithTitle:account.username];
    }
    NSLog(@"created buttons");
    _twitterAccountsSheet.cancelButtonIndex = [_twitterAccountsSheet addButtonWithTitle:@"Cancel"];
    [_twitterAccountsSheet showInView:self.view];

}


- (void)_handleSignupButton:(UIButton *)button
{
//    if (_signupView.hidden) {
//        _signupView.hidden = NO;
//        [UIView animateWithDuration:0.3 animations:^(void) {
//            _signupView.alpha = 1;
//            _signinButton.alpha = 0;
//            _signupButton.frame = CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height - 300, 200, 60);
//        }];
//        [_usernameInput becomeFirstResponder];
//    } else {
//        NSLog(@"username: %@, phone: %@, password: %@", _usernameInput.text, self.phoneNumber, _passwordInput.text);
//        
//        if (_usernameInput.text && self.phoneNumber && _passwordInput.text) {
//            [_usernameInput resignFirstResponder];
//            [_phoneInput resignFirstResponder];
//            [_passwordInput resignFirstResponder];
//            [[LoadingViewController sharedLoader] show];
//            [[[[[Client sharedClient] signupWithUsername:_usernameInput.text phone:self.phoneNumber password:_passwordInput.text]
//             doNext:^(User *user) {
//                 [[NSNotificationCenter defaultCenter]
//                  postNotificationName:@"LoggedIn"
//                  object:self];
//             }]
//            // Now the assignment will be done on the main thread.
//            deliverOn:RACScheduler.mainThreadScheduler]
//            subscribeError:^(NSError *error) {
//                [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem logging in: " type:TSMessageNotificationTypeError];
//            }];
//        }
//    }
}

- (void)_handleSigninButton:(UIButton *)button
{
    NSArray *permissions = @[@"email"];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    
    ACAccountType *FBaccountType= [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nearsight-Info" ofType:@"plist"]];
    NSString *facebookAppId = [plist objectForKey:@"FacebookAppID"];
    NSLog(@"Fb app id: %@", facebookAppId);
    //    NSDictionary *dictFB = @{
    //                             ACFacebookAppIdKey:facebookAppId,
    //                             ACFacebookPermissionsKey:permissions,
    //                             ACFacebookAudienceKey : ACFacebookAudienceOnlyMe
    //                             };
    NSDictionary *dictFB = [NSDictionary dictionaryWithObjectsAndKeys:facebookAppId,ACFacebookAppIdKey,@[@"email"],ACFacebookPermissionsKey, nil];
    
    
    [accountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion:
     ^(BOOL granted, NSError *e) {
         if (granted) {
             NSArray *accounts = [accountStore accountsWithAccountType:FBaccountType];
             
             //it will always be the last object with single sign on
             ACAccount *facebookAccount = [accounts lastObject];
             
             //i  got the Facebook UID and logged it here (ANSWER)
             
             NSLog(@"facebook account =%@",[facebookAccount valueForKeyPath:@"properties.uid"]);
             
             // Get the access token, could be used in other scenarios
             ACAccountCredential *fbCredential = [facebookAccount credential];
             NSString *userId = [facebookAccount valueForKeyPath:@"properties.uid"];
             NSString *accessToken = [fbCredential oauthToken];
             NSLog(@"Facebook Access Token: %@", accessToken);
             
             [[[[[Client sharedClient] loginWithFacebookId:userId andAccessToken:accessToken]
                doNext:^(User *user) {
                    NSLog(@"Logged in");
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"LoggedIn"
                     object:self];
                }]
               // Now the assignment will be done on the main thread.
               deliverOn:RACScheduler.mainThreadScheduler]
              subscribeError:^(NSError *error) {
                  [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem logging in: " type:TSMessageNotificationTypeError];
              }];

             
         } else {
             //Fail gracefully...
             NSLog(@"error getting permission %@",e);
             
         }
     }];
//    if (_signupView.hidden) {
//        self.signin = YES;
//        
//        // Hide phone input
//        _phoneInput.hidden = YES;
//        
//        // Move password input up
//        _passwordInput.frame = CGRectMake(40, 120, 280, 30);
//        
//        // Change Title
//        _signupTitle.text = @"Login";
//        
//        _signupView.hidden = NO;
//        [UIView animateWithDuration:0.3 animations:^(void) {
//            _signupView.alpha = 1;
//            _signinButton.alpha = 0;
//            [_signupButton setTitle:@"Login" forState:UIControlStateNormal];
//            _signupButton.frame = CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height - 300, 200, 60);
//        }];
//        [_usernameInput becomeFirstResponder];
//    } else {
//        //        ABAddressBookRef addressBook = ABAddressBookCreate( );
//        //        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
//        //        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
//        
//        if (self.signin) {
//            if (_usernameInput.text && _passwordInput.text) {
//                [_usernameInput resignFirstResponder];
//                [_passwordInput resignFirstResponder];
//                [[LoadingViewController sharedLoader] show];
//                [[[[[Client sharedClient] signupWithUsername:_usernameInput.text phone:self.phoneNumber password:_passwordInput.text]
//                   doNext:^(User *user) {
//                       [[NSNotificationCenter defaultCenter]
//                        postNotificationName:@"LoggedIn"
//                        object:self];
//                   }]
//                  // Now the assignment will be done on the main thread.
//                  deliverOn:RACScheduler.mainThreadScheduler]
//                 subscribeError:^(NSError *error) {
//                     [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem logging in: " type:TSMessageNotificationTypeError];
//                 }];
//            }
//        } else {
//            if (_usernameInput.text && self.phoneNumber && _passwordInput.text) {
//                [_usernameInput resignFirstResponder];
//                [_phoneInput resignFirstResponder];
//                [_passwordInput resignFirstResponder];
//                [[LoadingViewController sharedLoader] show];
//                [[[[[Client sharedClient] signupWithUsername:_usernameInput.text phone:self.phoneNumber password:_passwordInput.text]
//                   doNext:^(User *user) {
//                       [[NSNotificationCenter defaultCenter]
//                        postNotificationName:@"LoggedIn"
//                        object:self];
//                   }]
//                  // Now the assignment will be done on the main thread.
//                  deliverOn:RACScheduler.mainThreadScheduler]
//                 subscribeError:^(NSError *error) {
//                     [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem logging in: " type:TSMessageNotificationTypeError];
//                 }];
//            }
//        }
//    }
}

- (void)_handleCloseButton:(UIButton *)button
{
    self.signin = NO;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:0.3 animations:^(void) {
        _signupView.alpha = 0;
        _signinButton.alpha = 1;
        _signupButton.frame = CGRectMake(viewWidth/2 - 100, viewHeight - 100, 200, 60);
    } completion:^(BOOL finished) {
        _signupView.hidden = YES;
        
        // Change back to signup
        
        // Hide phone input
        _phoneInput.hidden = NO;
        
        // Move password input up
        _passwordInput.frame = CGRectMake(40, 170, 280, 30);
        
        // Change Title
        _signupTitle.text = @"Join";
        
        // Button Title
        [_signupButton setTitle:@"Join" forState:UIControlStateNormal];

    }];
    [_usernameInput resignFirstResponder];
    [_phoneInput resignFirstResponder];
    [_passwordInput resignFirstResponder];
}


- (void)_handlePhoneInput:(UITextField *)textField
{
    NSString *formatted;
    if ([textField.text length] < self.lastPhoneLength) {
        formatted = [self.phoneFormatter removeLastDigit];
        [self.phoneNumber deleteCharactersInRange:NSMakeRange([self.phoneNumber length] - 1, 1)];
    } else {
        NSString *inputDigit = [textField.text substringFromIndex:([textField.text length] - 1)];
        [self.phoneNumber appendString:inputDigit];
        formatted = [self.phoneFormatter inputDigit:inputDigit];
    }
    self.lastPhoneLength = [formatted length];
    textField.text = formatted;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

# pragma mark - FBLoginViewDelegate

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"LOGGED IN");
    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    [[[[[Client sharedClient] loginWithFacebookId:user.id andAccessToken:accessToken]
       doNext:^(User *user) {
           [[NSNotificationCenter defaultCenter]
            postNotificationName:@"LoggedIn"
            object:self];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem logging in: " type:TSMessageNotificationTypeError];
     }];

//    self.profilePictureView.profileID = user.id;
//    self.nameLabel.text = user.name;
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"LOGGED IN as");
    //self.statusLabel.text = @"You're logged in as";
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
