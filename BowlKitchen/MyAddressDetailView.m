//
//  MyAddressAddView.m
//  BowlKitchen
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyAddressDetailView.h"

@interface MyAddressDetailView ()<UIAlertViewDelegate>


@end

@implementation MyAddressDetailView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"地址详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 22)];
    [rBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setTitle:@"删除" forState:UIControlStateNormal];
    
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    self.navigationItem.leftBarButtonItem = backbtn;
    [self.updateBtn.layer setMasksToBounds:YES];
    [self.updateBtn.layer setCornerRadius:4.0f];
    
    [self bindData];
}

- (void)bindData
{
    self.nameField.text = self.myAddress.receivingUserName;
    self.phoneField.text = self.myAddress.phone;
    self.addressField.text = self.myAddress.receivingAddress;
}

- (void)deleteAction:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"是否删除该地址?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.myAddress.addressId forKey:@"addressId"];
        
        NSString *orderPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_delReceivingAddress] params:param];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:orderPageUrl]];
        [request setUseCookiePersistence:NO];
        [request setTimeOutSeconds:30];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestOK:)];
        [request startAsynchronous];
        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)requestOK:(ASIHTTPRequest *)request
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"地址已删除" andView:self.view andImage:nil andAfterDelay:1.2f];
        [self performSelector:@selector(backAction:) withObject:nil afterDelay:1.2f];
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

- (IBAction)updateAction:(id)sender
{
    NSString *nameStr = self.nameField.text;
    NSString *phoneStr = self.phoneField.text;
    NSString *addressStr = self.addressField.text;
    
    if(!nameStr || nameStr.length == 0)
    {
        [Tool showCustomHUD:@"收货人姓名不能为空" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    if(!phoneStr || phoneStr.length == 0 || ![phoneStr isValidPhoneNum])
    {
        [Tool showCustomHUD:@"请输入正确的手机号码" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    if(!addressStr || addressStr.length == 0)
    {
        [Tool showCustomHUD:@"收货人地址不能为空" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    BOOL isNoEdit = YES;
    if(![nameStr isEqualToString:self.myAddress.receivingUserName])
        isNoEdit = NO;
    if(![phoneStr isEqualToString:self.myAddress.phone])
        isNoEdit = NO;
    if(![addressStr isEqualToString:self.myAddress.receivingAddress])
        isNoEdit = NO;
    if(isNoEdit)
    {
        [Tool showCustomHUD:@"信息一致不能修改" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    //生成注册URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:nameStr forKey:@"receivingUserName"];
    [param setValue:addressStr forKey:@"receivingAddress"];
    [param setValue:phoneStr forKey:@"phone"];
    [param setValue:self.myAddress.addressId forKey:@"addressId"];
    
    NSString *modiSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_modiReceivingAddress] params:param];
    
    NSString *modiUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_modiReceivingAddress];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:modiUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:nameStr forKey:@"receivingUserName"];
    [request setPostValue:addressStr forKey:@"receivingAddress"];
    [request setPostValue:phoneStr forKey:@"phone"];
    [request setPostValue:self.myAddress.addressId forKey:@"addressId"];
    
    [request setPostValue:modiSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestUpdateFailed:)];
    [request setDidFinishSelector:@selector(requestUpdate:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"修改中..." andView:self.view andHUD:request.hud];
    self.updateBtn.enabled = NO;
}

- (void)requestUpdateFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.updateBtn.enabled = YES;
}

- (void)requestUpdate:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSLog(@"%@",request.responseString);
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        self.updateBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"修改成功" andView:self.view andImage:nil andAfterDelay:1.2f];
        self.updateBtn.enabled = YES;
    }
}

@end
