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
#import <AlipaySDK/AlipaySDK.h>

@interface OrderConfirmView ()<UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
{
    //送货时间
    NSInteger selectTime;
    
    //付款方式(1,货到付款. 0,支付宝)
    NSInteger payType;
    
    NSArray *addressArray;
    
    MyAddress *currentAddress;
    MBProgressHUD *hud;
}

@property (nonatomic, strong) NSArray *fieldArray;

@property (nonatomic, strong) UIPickerView *timePicker;

@end

@implementation OrderConfirmView

- (void)viewDidLoad
{
    [super viewDidLoad];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
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
    
    self.timeTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAddress:) name:@"updateAddress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToBuy) name:ORDER_PAY_NOTIC object:nil];
    _fieldArray = [NSArray arrayWithObjects:@"11:30", @"12:30" ,@"1:30", @"2:30", @"3:30", @"4:30", @"5:30", @"6:30", @"7:30", @"8:30",nil];
    
    [self getMyAddress];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORDER_PAY_NOTIC object:nil];
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
    if(self.timeTextField.text.length == 0)
    {
        [Tool showCustomHUD:@"请选择收货时间" andView:self.view andImage:nil andAfterDelay:1.2f];
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
    ovo.sendTimeType = selectTime;
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
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.commitBtn.enabled = YES;
}

- (void)requestOrder:(ASIHTTPRequest *)request
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
        else
        {
            [Tool showHUD:@"正在支付" andView:self.view andHUD:hud];
            [self doPay:[[json objectForKey:@"header"] objectForKey:@"msg"]];
        }
    }
}

- (void)doPay:(NSString *)orderNo
{
    
    //生成支付宝订单URL
    NSString *createOrderUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createAlipayParams];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createOrderUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:orderNo forKey:@"orderId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestPayFailed:)];
    [request setDidFinishSelector:@selector(requestCreate:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    
}

- (void)requestPayFailed:(ASIHTTPRequest *)request
{
    if (hud)
    {
        [hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestCreate:(ASIHTTPRequest *)request
{
    if (hud)
    {
        [hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [json objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        NSString *orderStr = [json objectForKey:@"msg"];
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:@"BowlKitchenAlipay" callback:^(NSDictionary *resultDic)
         {
             NSString *resultState = resultDic[@"resultStatus"];
             if([resultState isEqualToString:ORDER_PAY_OK])
             {
                 [Tool showCustomHUD:@"已付款,请等待发货" andView:self.view andImage:nil andAfterDelay:1.2f];
                 [self performSelector:@selector(backToBuy) withObject:self afterDelay:1.2f];
             }
         }];
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

#pragma mark Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _fieldArray.count;
}

#pragma mark Picker Delegate Methods
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return [_fieldArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectTime = row;
    NSString *str = [_fieldArray objectAtIndex:row];
    self.timeTextField.text = str;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.inputAccessoryView == nil)
    {
        textField.inputAccessoryView = [self keyboardToolBar:textField.tag];
    }
    self.timePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.timePicker.showsSelectionIndicator = YES;
    self.timePicker.delegate = self;
    self.timePicker.dataSource = self;
    textField.inputView = self.timePicker;
    
}

- (UIToolbar *)keyboardToolBar:(int)fieldIndex
{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar sizeToFit];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.tag = fieldIndex;
    doneButton.title = @"完成";
    doneButton.style = UIBarButtonItemStyleDone;
    doneButton.action = @selector(doneClicked:);
    doneButton.target = self;
    
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    return toolBar;
}

//用户不滑动UIPickerView控件及滑动操作过快解决方法，不滑动默认选定数组第一个，滑动过快由于先处理doneClicked事件才会触发UIPickerView选定事件，所有还判断了当前选定全局变量是否大于控件数组长度处理
- (void)doneClicked:(UITextField *)sender
{
    NSString *str = [_fieldArray objectAtIndex:selectTime];
    self.timeTextField.text = str;
    [self.timeTextField resignFirstResponder];
}

@end
