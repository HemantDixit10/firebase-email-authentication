//
//  LoginViewController.m
//  FirebaseSignUpAndEmail
//
//  Created by TriState on 8/30/16.
//  Copyright © 2016 Tristate Technology. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "Firebase.h"



@interface LoginViewController (){
    IBOutlet UITextField *tfEmailID;
    IBOutlet UITextField *tfPassword;
    IBOutlet UIImageView *imgCompanyLogo;    
}
@property(strong,nonatomic)IBOutlet UIScrollView *scrollView;
@property(strong,nonatomic) UITextField *txtFieldCheck;

@end

@implementation LoginViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     self.navigationController.navigationBar.hidden = YES;
    tfEmailID.text = tfPassword.text = @"";
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillShowNotification];
     [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - All Validation methods

-(BOOL)validation{
    NSString *strEmailID = [tfEmailID.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    NSString *strPassword = [tfPassword.text stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceCharacterSet]];
    
    if (strEmailID.length <= 0){
        [self displayAlertView:@"Please enter email Id"];
        return NO;
    }
    else if (strPassword.length <= 0){
        [self displayAlertView:@"Please enter password"];
        return NO;
    }
    else if ([self validateEmailAddress:strEmailID] == NO){
        [self displayAlertView:@"Please enter valid email Id"];
        return NO;
    }
    return YES;
}

-(BOOL)validateEmailAddress:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - UITextField Delegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    self.txtFieldCheck = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertView  methods
-(void)displayAlertView:(NSString *)strMessage
{
    TSTAlertView *alert = [[TSTAlertView alloc] init];
    alert.backgroundType = Blur;
    alert.showAnimationType = SlideInFromTop;
    [alert showError:self title:ALERT_TITLE subTitle:strMessage closeButtonTitle:@"Okay!" duration:0.0f];
}

#pragma mark - custom Methods
-(IBAction)btnLoginAction:(id)sender{
    if ([self validation]){
        [self showHud];
        [[FIRAuth auth] signInWithEmail:tfEmailID.text password:tfPassword.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            [self hideHud];
            if (error) {
                [self displayAlertView:error.localizedDescription];
                NSLog(@"Error in FIRAuth := %@",error.localizedDescription);
            }
            else{
                TSTAlertView *alert = [[TSTAlertView alloc] init];
                alert.backgroundType = Blur;
                alert.showAnimationType = SlideInFromTop;
                [alert showSuccess:self title:ALERT_TITLE subTitle:@"Successfully login with Firebase." closeButtonTitle:nil duration:0.0f];
                [alert addButton:@"Okay" actionBlock:^{
                    
                }];
                NSLog(@"user Id : %@", user.uid);
            }
        }];
    }
}

-(IBAction)btnSignUpAction:(id)sender{
    SignUpViewController *objSignUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:objSignUpViewController animated:YES];
}

#pragma mark - Keyboard Notifications Methods
- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height+60;
    if (!CGRectContainsPoint(aRect, self.txtFieldCheck.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.txtFieldCheck.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (UIView*)viewFormatingFunction:(UIView*)view
{
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:NO ];
    [viewLayer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [viewLayer setShadowOpacity:0.8 ];
    [viewLayer setShadowRadius:3.0 ];
    [viewLayer setShadowOffset:CGSizeMake( 0 , 0 )];
    [viewLayer setShouldRasterize:YES];
    [viewLayer setCornerRadius:3.0];

    [viewLayer setShadowPath:[UIBezierPath bezierPathWithRect:viewLayer.bounds].CGPath];
    return view;
}
@end