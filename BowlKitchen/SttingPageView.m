//
//  SttingPageView.m
//  BowlKitchen
//
//  Created by mac on 15/3/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SttingPageView.h"
#import "LoginView.h"
#import "RegisterView.h"
#import "MyInfoView.h"
#import "MyOrderView.h"
#import "MyAddressView.h"

@interface SttingPageView ()<UIAlertViewDelegate>

@end

@implementation SttingPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"设置";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    UITapGestureRecognizer *infoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myInfoAction:)];
    [self.myInfoView addGestureRecognizer:infoRecognizer];
    
    UITapGestureRecognizer *orderRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myOrderAction:)];
    
    [self.myOrderView addGestureRecognizer:orderRecognizer];
    
    UITapGestureRecognizer *addressRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myAddressAction:)];
    
    [self.myAddressView addGestureRecognizer:addressRecognizer];
    
    UITapGestureRecognizer *userRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchUser:)];
    
    [self.switchUserView addGestureRecognizer:userRecognizer];
}

- (void)myInfoAction:(id)sender
{
    if(![[UserModel Instance] isLogin])
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
    else
       [self.navigationController pushViewController:[[MyInfoView alloc] init] animated:YES];
}

- (void)myOrderAction:(id)sender
{
    if(![[UserModel Instance] isLogin])
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
    else
        [self.navigationController pushViewController:[[MyOrderView alloc] init] animated:YES];
}

- (void)myAddressAction:(id)sender
{
    if(![[UserModel Instance] isLogin])
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
    else
    {
        MyAddressView *myAddressView = [[MyAddressView alloc] init];
        myAddressView.type = 1;
        [self.navigationController pushViewController:myAddressView animated:YES];
    }
}

- (void)switchUser:(id)sender
{
    if([[UserModel Instance] isLogin])
    {
        [[UserModel Instance] logoutUser];
    }
    LoginView *loginView = [[LoginView alloc] init];
    [self.navigationController pushViewController:loginView animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"登录"]) {
        LoginView *loginView = [[LoginView alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else if([buttonTitle isEqualToString:@"注册"])
    {
        RegisterView *regView = [[RegisterView alloc] init];
        [self.navigationController pushViewController:regView animated:YES];
    }
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
