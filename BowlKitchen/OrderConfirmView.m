//
//  OrderConfirmView.m
//  BowlKitchen
//
//  Created by mac on 15/3/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "OrderConfirmView.h"
#import "OrderCommoditySubmit.h"
#import "OrderSubmitVO.h"
#import "MyAddress.h"
#import "MyAddressView.h"

@interface OrderConfirmView ()
{
    //送货时间(0,上午. 1,下午)
    NSInteger timeType;
    
    //付款方式(1,货到付款. 0,支付宝)
    NSInteger payType;
    
    NSArray *addressArray;
    
    MyAddress *currentAddress;
}
@end

@implementation OrderConfirmView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    timeType = 0;
    payType = 1;
    self.hidesBottomBarWhenPushed=YES;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"订单";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    [self.shopTypeBtn.layer setMasksToBounds:YES];
    [self.shopTypeBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
    
    [self.alipayTypeBtn.layer setMasksToBounds:YES];
    [self.alipayTypeBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
    
    [self.commitBtn.layer setMasksToBounds:YES];
    [self.commitBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
    
    [self.updateBtn.layer setMasksToBounds:YES];
    [self.updateBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
    
    //添加边框
    CALayer * layer = [self.addressText layer];
    layer.borderColor = [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1] CGColor];
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 3.0;
    
    //上午复选框
    self.forenoonCb = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 25, 25) style:kSSCheckBoxViewStyleGlossy checked:YES];
    //下午复选框
    self.afternoonCb = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 25, 25) style:kSSCheckBoxViewStyleGlossy checked:NO];
    [self.forenoonCb setStateChangedTarget:self selector:@selector(forenoonCheck:)];
    [self.afternoonCb setStateChangedTarget:self selector:@selector(afternoonCheck:)];
    
    [self.forenoonCheckView addSubview:self.forenoonCb];
    [self.afternoonCheckView addSubview:self.afternoonCb];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAddress:) name:@"updateAddress" object:nil];
    
    [self getMyAddress];
}

- (void)forenoonCheck:(id)sender
{
    if(self.forenoonCb.checked)
    {
        self.afternoonCb.checked = NO;
        timeType = 0;
    }
    else
    {
        if(!self.afternoonCb.checked)
        {
            self.forenoonCb.checked = YES;
        }
    }
}

- (void)afternoonCheck:(id)sender
{
    if(self.afternoonCb.checked)
    {
        self.forenoonCb.checked = NO;
        timeType = 1;
    }
    else
    {
        if(!self.forenoonCb.checked)
        {
            self.afternoonCb.checked = YES;
        }
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

- (IBAction)shopTypeAction:(UIButton *)sender
{
    [self.shopTypeBtn setBackgroundColor:[UIColor colorWithRed:0.91 green:0.55 blue:0 alpha:1]];
    [self.alipayTypeBtn setBackgroundColor:[UIColor colorWithRed:0.58 green:0 blue:0.2 alpha:1]];
    payType = 1;
}

- (IBAction)alipayTypeAction:(UIButton *)sender
{
    [self.alipayTypeBtn setBackgroundColor:[UIColor colorWithRed:0.91 green:0.55 blue:0 alpha:1]];
    [self.shopTypeBtn setBackgroundColor:[UIColor colorWithRed:0.58 green:0 blue:0.2 alpha:1]];
    payType = 0;
}


- (void)getMyAddress
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[[UserModel Instance] getUserInfo].regUserId forKey:@"regUserId"];
    
    NSString *orderPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findReceivingAddressList] params:param];
    
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

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
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
    if ([state isEqualToString:@"0000"] == NO)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        av.tag = 0;
        [av show];
        return;
    }
    else
    {
        NSArray *arry = [json objectForKey:@"data"];
        addressArray = [Tool readJsonToObjArray:arry andObjClass:[MyAddress class]];
        if(addressArray && addressArray.count > 0)
        {
            currentAddress = addressArray[0];
            self.addressText.text = [NSString stringWithFormat:@"%@-%@-%@",currentAddress.receivingUserName,currentAddress.phone,currentAddress.receivingAddress];
        }
    }
}

- (void)updateAddress:(NSNotification *)notic
{
    currentAddress = [notic.userInfo objectForKey:@"address"];
    self.addressText.text = [NSString stringWithFormat:@"%@-%@-%@",currentAddress.receivingUserName,currentAddress.phone,currentAddress.receivingAddress];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateAddress" object:nil];
}

- (IBAction)commitOrderAction:(UIButton *)sender
{
    if(!currentAddress)
    {
        return;
    }
    
    NSString *nameStr = currentAddress.receivingUserName;
    NSString *phoneStr = currentAddress.phone;
    NSString *addressStr = currentAddress.receivingAddress;
    
    if(!nameStr || nameStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入收货人姓名" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(!phoneStr || phoneStr.length == 0 || ![phoneStr isValidPhoneNum])
    {
        [Tool showCustomHUD:@"请输入收货人手机号码" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(!addressStr || addressStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入收货人地址" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    OrderCommoditySubmit *ocs = [[OrderCommoditySubmit alloc] init];
    ocs.commodityId = self.commodityId;
    ocs.num = self.shopNum;
    
    OrderSubmitVO *ovo = [[OrderSubmitVO alloc] init];
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    ovo.regUserId = userInfo.regUserId;
    ovo.remark = self.wishStr;
    ovo.receivingUserName = nameStr;
    ovo.receivingAddress = addressStr;
    ovo.phone = phoneStr;
    ovo.payTypeId = payType;
    ovo.sendTimeType = timeType;
    ovo.commodityList = [NSArray arrayWithObjects:ocs, nil];
    NSString *orderJson = [Tool readObjToJson:ovo];
    
    //生成订单提交URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:orderJson forKey:@"orderJson"];
    
    NSString *orderSubmitSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_orderSubmit] params:param];
    
    NSString *orderSubmitUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_orderSubmit];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:orderSubmitUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:orderJson forKey:@"orderJson"];
    [request setPostValue:orderSubmitSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestCCFailed:)];
    [request setDidFinishSelector:@selector(requestOrder:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在提交订单" andView:self.view andHUD:request.hud];
    
}

- (void)requestCCFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.commitBtn.enabled = YES;
}

- (void)requestOrder:(ASIHTTPRequest *)request
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
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        self.commitBtn.enabled = YES;
        return;
    }
    else
    {
        if(payType == 1)
        {
            [Tool showCustomHUD:@"已下单,请等待送货" andView:self.view andImage:nil andAfterDelay:1.2f];
            [self performSelector:@selector(backToBuy) withObject:self afterDelay:1.2f];
        }
    }
}

- (void)backToBuy
{
    NSMutableArray *views = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [views removeObjectAtIndex:views.count - 2];
    self.navigationController.viewControllers = views;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateAddressAction:(id)sender
{
    MyAddressView *myAddressView = [[MyAddressView alloc] init];
    myAddressView.type = 2;
    [self.navigationController pushViewController:myAddressView animated:YES];
}


@end