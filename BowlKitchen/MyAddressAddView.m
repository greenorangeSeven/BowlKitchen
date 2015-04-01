//
//  MyAddressAddView.m
//  BowlKitchen
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyAddressAddView.h"

@interface MyAddressAddView ()

@end

@implementation MyAddressAddView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"新增地址";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 38, 22)];
    [rBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setTitle:@"新增" forState:UIControlStateNormal];
    
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    self.navigationItem.leftBarButtonItem = backbtn;

}

- (void)addAction:(id)sender
{
    NSString *nameStr = self.nameField.text;
    NSString *phoneStr = self.phoneField.text;
    NSString *addressStr = self.addressField.text;
    
    if(!nameStr || nameStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入收货人姓名" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(!phoneStr || ![phoneStr isValidPhoneNum])
    {
        [Tool showCustomHUD:@"请输入正确的手机号码" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(!addressStr || addressStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入收件人地址" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //生成注册URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[[UserModel Instance] getUserInfo].regUserId forKey:@"regUserId"];
    [param setValue:nameStr forKey:@"receivingUserName"];
    [param setValue:addressStr forKey:@"receivingAddress"];
    [param setValue:phoneStr forKey:@"phone"];
    
    NSString *receiveSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addReceivingAddress] params:param];
    NSString *regUserUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addReceivingAddress];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUserUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:nameStr forKey:@"receivingUserName"];
    [request setPostValue:addressStr forKey:@"receivingAddress"];
    [request setPostValue:phoneStr forKey:@"phone"];
    [request setPostValue:[[UserModel Instance] getUserInfo].regUserId forKey:@"regUserId"];
    [request setPostValue:receiveSign forKey:@"sign"];
    
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestReceive:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}
- (void)requestReceive:(ASIHTTPRequest *)request
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
        [Tool showCustomHUD:@"新增成功" andView:self.view andImage:nil andAfterDelay:1.2f];
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

@end
