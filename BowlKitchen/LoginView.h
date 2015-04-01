//
//  LoginView.h
//  BowlKitchen
//
//  Created by mac on 15/3/12.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
- (IBAction)forgotPwdAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
