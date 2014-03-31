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

@interface WelcomeViewController ()

@property (strong, nonatomic) SignupViewController *signupViewController;
@property (strong, nonatomic) NBAsYouTypeFormatter *phoneFormatter;
@property (strong, nonatomic) NSMutableString *phoneNumber;
@property (nonatomic) NSUInteger lastPhoneLength;

@end

@implementation WelcomeViewController {
    UIButton *_signupButton;
    UIButton *_signinButton;
    UIView *_signupView;
    
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
    
    _signupButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth/2 - 100, viewHeight - 100, 200, 60)];
    //_signupButton.backgroundColor = [UIColor whiteColor];
    [_signupButton setTitle:@"Join" forState:UIControlStateNormal];
    //_signupButton.titleLabel.textColor = [UIColor blackColor];
    _signupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _signupButton.titleLabel.font = [UIFont fontWithName:@"MrsEaves-Italic" size:28];
    [_signupButton addTarget:self action:@selector(_handleSignupButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_signupButton];
    
    _signinButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth - 80, 20, 70, 40)];
    _signinButton.titleLabel.textColor = [UIColor whiteColor];
    _signinButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _signinButton.titleLabel.font = [UIFont fontWithName:@"MrsEaves-Italic" size:20];
    [_signinButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.view addSubview:_signinButton];
    
    // Signup View
    _signupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 300)];
    _signupView.hidden = YES;
    _signupView.alpha = 0;
    [self.view addSubview:_signupView];
    
    // Phone Formatter
    self.phoneFormatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"US"];
    self.phoneNumber = [[NSMutableString alloc] init];
    self.lastPhoneLength = 0;
    
    // Phone Input
    _phoneInput = [[UITextField alloc] initWithFrame:CGRectMake(40, 70, 280, 30)];
    _phoneInput.placeholder = @"Phone number";
    _phoneInput.keyboardType = UIKeyboardTypeDecimalPad;
    _phoneInput.textColor = [UIColor whiteColor];
    [_phoneInput addTarget:self action:@selector(_handlePhoneInput:) forControlEvents:UIControlEventEditingChanged];
    [_signupView addSubview:_phoneInput];
    
    // Password Input
    _passwordInput = [[UITextField alloc] initWithFrame:CGRectMake(40, 120, 280, 30)];
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
    _signupTitle.text = @"Signup";
    _signupTitle.textAlignment = NSTextAlignmentCenter;
    _signupTitle.userInteractionEnabled = NO;
    _signupTitle.textColor = [UIColor whiteColor];
    [_signupTitle setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:28]];
    [_signupView addSubview:_signupTitle];
    
    
    self.signupViewController = [[SignupViewController alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_handleSignupButton:(UIButton *)button
{
    if (_signupView.hidden) {
        _signupView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^(void) {
            _signupView.alpha = 1;
            _signinButton.alpha = 0;
            _signupButton.frame = CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height - 300, 200, 60);
        }];
        [_phoneInput becomeFirstResponder];
    } else {
//        ABAddressBookRef addressBook = ABAddressBookCreate( );
//        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
//        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    }
}

- (void)_handleCloseButton:(UIButton *)button
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:0.3 animations:^(void) {
        _signupView.alpha = 0;
        _signinButton.alpha = 1;
        _signupButton.frame = CGRectMake(viewWidth/2 - 100, viewHeight - 100, 200, 60);
    } completion:^(BOOL finished) {
        _signupView.hidden = YES;
    }];
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
    
@end
