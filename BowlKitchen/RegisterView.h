//
//  RegisterVerifyView.h
//  BowlKitchen
//
//  Created by mac on 15/3/16.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterView : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *verfyCodeField;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
- (IBAction)doRegisterAction:(id)sender;
- (IBAction)doSendCodeAction:(id)sender;


@end
