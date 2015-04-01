//
//  LoginView.m
//  BowlKitchen
//
//  Created by mac on 15/3/12.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "LoginView.h"
#import "RegisterView.h"
#import "ForgotPwdView.h"

@interface LoginView ()

@end

@implementation LoginView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"登录";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //设置按钮带圆角
    [self.loginBtn.layer setCornerRadius:4.0f];
    [self.registerBtn.layer setCornerRadius:4.0f];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)forgotPwdAction:(id)sender
{
    [self.navigationController pushViewController:[[ForgotPwdView alloc] init] animated:YES];
}

- (IBAction)loginAction:(id)sender
{
    self.loginBtn.enabled = NO;
    
    NSString *phoneStr = self.phoneField.text;
    NSString *pwdStr = self.pwdField.text;
    if(![phoneStr isValidPhoneNum])
    {
        [Tool showCustomHUD:@"请输入正确的手机号码" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(pwdStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入密码" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    //生成登录URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:phoneStr forKey:@"mobileNo"];
    [param setValue:pwdStr forKey:@"password"];
    
    NSString *regUserSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_regUser] params:param];
    NSString *regUserUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_login];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUserUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:phoneStr forKey:@"mobileNo"];
    [request setPostValue:pwdStr forKey:@"password"];
    [request setPostValue:regUserSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestLogin:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"登录中..." andView:self.view andHUD:request.hud];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.loginBtn.enabled == NO)
    {
        self.loginBtn.enabled = YES;
    }
    if(self.registerBtn.enabled == NO)
    {
        self.registerBtn.enabled = YES;
    }
}

- (void)requestLogin:(ASIHTTPRequest *)request
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
        self.loginBtn.enabled = YES;
        self.registerBtn.enabled = YES;
        return;
    }
    else
    {
        UserInfo *userInfo = [Tool readJsonDicToObj:[json objectForKey:@"data"] andObjClass:[UserInfo class]];
        [[UserModel Instance] saveUserInfo:userInfo];
        [Tool showCustomHUD:@"欢迎回来" andView:self.view andImage:nil andAfterDelay:1.1f];
        [self performSelector:@selector(back) withObject:self afterDelay:1.2f];
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)registerAction:(id)sender
{
    [self.navigationController pushViewController:[[RegisterView alloc] init] animated:YES];
}

@end
