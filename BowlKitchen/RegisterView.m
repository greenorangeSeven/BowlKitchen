//
//  RegisterVerifyView.m
//  BowlKitchen
//
//  Created by mac on 15/3/16.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "RegisterView.h"
#import "LoginView.h"

@interface RegisterView ()
{
    bool isSendVerifyCode;
    NSString *verifyMobileStr;
}

@end

@implementation RegisterView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"注册";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //设置注册按钮带圆角
    [self.registerBtn.layer setCornerRadius:4.0f];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)doRegisterAction:(id)sender
{
    NSString *mobileStr = self.phoneField.text;
    NSString *pwdStr = self.pwdField.text;
    NSString *verifyCodeStr = self.verfyCodeField.text;
    if (![mobileStr isValidPhoneNum])
    {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
//    if(![verifyMobileStr isEqualToString:mobileStr])
//    {
//        [Tool showCustomHUD:@"手机号与验证的手机号不一致" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
//        return;
//    }
    if(verifyCodeStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入验证码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if(pwdStr.length < 6)
    {
        [Tool showCustomHUD:@"请输入大于6位的密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    self.registerBtn.enabled = NO;
    //生成注册URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:verifyCodeStr forKey:@"validateCode"];
    [param setValue:mobileStr forKey:@"mobileNo"];
    [param setValue:pwdStr forKey:@"password"];
    
    NSString *regUserSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_regUser] params:param];
    NSString *regUserUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_regUser];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUserUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:verifyCodeStr forKey:@"validateCode"];
    [request setPostValue:mobileStr forKey:@"mobileNo"];
    [request setPostValue:pwdStr forKey:@"password"];
    [request setPostValue:regUserSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestRegUser:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"注册中..." andView:self.view andHUD:request.hud];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.sendCodeBtn.enabled == NO)
    {
        self.sendCodeBtn.enabled = YES;
    }
    if(self.registerBtn.enabled == NO)
    {
        self.registerBtn.enabled = YES;
    }
}

- (void)requestRegUser:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        self.registerBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"注册成功" andView:self.view andImage:nil andAfterDelay:1.2f];
        [self performSelector:@selector(doback) withObject:nil afterDelay:1.2f];
    }
}

- (void)doback
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array removeLastObject];
    self.navigationController.viewControllers = array;
    [self.navigationController pushViewController:[[LoginView alloc] init] animated:YES];
}

- (IBAction)doSendCodeAction:(id)sender
{
    isSendVerifyCode = YES;
    [self.phoneField resignFirstResponder];
    NSString *mobileStr = self.phoneField.text;
    if (![mobileStr isValidPhoneNum])
    {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.sendCodeBtn.enabled = NO;
    //生成验证码URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileStr forKey:@"mobileNo"];
    NSString *createRegCodeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_createRegCode] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:createRegCodeListUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreateRegCode:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"验证码发送中" andView:self.view andHUD:request.hud];
}

- (void)requestCreateRegCode:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        self.sendCodeBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"验证码已发送,请注意查收" andView:self.view andImage:nil andAfterDelay:1.2f];
        verifyMobileStr = self.phoneField.text;
        self.sendCodeBtn.hidden = YES;
    }
}

@end
