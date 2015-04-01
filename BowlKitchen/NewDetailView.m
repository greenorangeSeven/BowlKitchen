//
//  NewDetailView.m
//  BowlKitchen
//
//  Created by mac on 15/3/31.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "NewDetailView.h"
#import "News.h"

@interface NewDetailView ()

@end

@implementation NewDetailView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    
    NSString *html = [NSString stringWithFormat:@"<body>%@<div id='web_body'>%@</div></body>", HTML_Style, self.newsId.content];
    NSString *result = [Tool getHTMLString:html];
    [self.webView loadHTMLString:result baseURL:nil];
    self.webView.opaque = YES;
    for (UIView *subView in [self.webView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)subView).bounces = YES;
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

//
//- (void)getNewDetail
//{
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:self.newsId forKey:@"newsId"];
//    
//    NSString *orderPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findNewsInfoById] params:param];
//    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:orderPageUrl]];
//    [request setUseCookiePersistence:NO];
//    [request setTimeOutSeconds:30];
//    [request setDelegate:self];
//    [request setDidFailSelector:@selector(requestFailed:)];
//    [request setDidFinishSelector:@selector(requestOK:)];
//    [request startAsynchronous];
//    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
//}
//
//- (void)requestFailed:(ASIHTTPRequest *)request
//{
//    if (request.hud)
//    {
//        [request.hud hide:NO];
//    }
//    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
//                                                 message:@"网络连接失败"
//                                                delegate:self
//                                       cancelButtonTitle:@"重新连接"
//                                       otherButtonTitles:@"取消", nil];
//    [av show];
//}
//
//- (void)requestOK:(ASIHTTPRequest *)request
//{
//    if (request.hud) {
//        [request.hud hide:YES];
//    }
//    
//    [request setUseCookiePersistence:YES];
//    NSLog(@"the response:%@",request.responseString);
//    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    
//    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
//    if ([state isEqualToString:@"0000"] == NO)
//    {
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
//                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
//                                                    delegate:nil
//                                           cancelButtonTitle:@"确定"
//                                           otherButtonTitles:nil];
//        av.tag = 0;
//        [av show];
//        return;
//    }
//    else
//    {
//        
//    }
//}
@end
