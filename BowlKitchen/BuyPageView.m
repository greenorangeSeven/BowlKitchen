//
//  BuyPageView.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "BuyPageView.h"
#import "SttingPageView.h"
#import "OrderView.h"
#import "Commodity.h"
#import "UIImageView+WebCache.h"
#import "LoginView.h"
#import "RegisterView.h"

@interface BuyPageView ()<UIAlertViewDelegate>
{
    Commodity *commodity;
}

@end

@implementation BuyPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"navigation_menu"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    [self.buy_btn.layer setMasksToBounds:YES];
    [self.buy_btn.layer setCornerRadius:4.0]; //设置矩圆角半径
   
    //添加边框
    CALayer * layer = [self.shop_img layer];
    layer.borderColor = [[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] CGColor];
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 3.0;
    [self getCommodityInfo];
}

- (void)getCommodityInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@", api_base_url, api_getCommodityInfo];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
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
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                 message:@"网络连接失败"
                                                delegate:self
                                       cancelButtonTitle:@"重新连接"
                                       otherButtonTitles:@"取消", nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self getCommodityInfo];
    }
}

- (void)requestOK:(ASIHTTPRequest *)request
{
    if (request.hud) {
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
        [av show];
        return;
    }
    else
    {
        commodity = [Tool readJsonDicToObj:[json objectForKey:@"data"] andObjClass:[Commodity class]];
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        titleLabel.text = commodity.commodityName;
        self.shop_name_label.text = commodity.commodityName;
        
        //WebView的背景颜色去除
        [Tool clearWebViewBackground:self.shop_details_webview];
        //    [self.webView setScalesPageToFit:YES];
        [self.shop_details_webview sizeToFit];
        
        NSString *html = [NSString stringWithFormat:@"<body>%@<div id='web_body'>%@</div></body>", HTML_Style, commodity.details];
        NSString *result = [Tool getHTMLString:html];
        [self.shop_details_webview loadHTMLString:result baseURL:nil];
        self.shop_details_webview.opaque = YES;
        for (UIView *subView in [self.shop_details_webview subviews])
        {
            if ([subView isKindOfClass:[UIScrollView class]])
            {
                ((UIScrollView *)subView).bounces = YES;
            }
        }
        [self.shop_img sd_setImageWithURL:[NSURL URLWithString:commodity.imgURL]];
    }
}

- (void)menuAction:(id)sender
{
    [self.navigationController pushViewController:[[SttingPageView alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)tabImageName
{
    return @"navigation_buy.png";
}

- (IBAction)shareAction:(UIButton *)sender
{
}

- (IBAction)buyAction:(UIButton *)sender
{
    if(![[UserModel Instance] isLogin])
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
    else
    {
        OrderView *orderView = [[OrderView alloc] init];
        orderView.commodity = commodity;
        [self.navigationController pushViewController:orderView animated:YES];
    }
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

@end
