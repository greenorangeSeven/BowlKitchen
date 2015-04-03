//
//  UnknowTwoView.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "DayQuestionPageView.h"
#import "SttingPageView.h"

@interface DayQuestionPageView ()
{
    NSString *questionStr;
}

@end

@implementation DayQuestionPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"每日一问";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"navigation_menu"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    [self getQuestion];
}

- (void)getQuestion
{
    NSDate *datenow = [NSDate date];
    
    NSString *todayTimeSps = [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]];
    todayTimeSps = [Tool TimestampToDateStr:todayTimeSps andFormatterStr:@"yyyy-MM-dd"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:todayTimeSps forKey:@"starttime"];
    
    NSString *createQuestionUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findDayQuestion] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:createQuestionUrl]];
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
        av.tag = 0;
        [av show];
        return;
    }
    else
    {
        questionStr = [[json objectForKey:@"data"] objectForKey:@"content"];
        
        NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
        NSArray *fontNames;
        NSInteger indFamily, indFont;
        
        self.questionLabel.text= questionStr;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(alertView.tag == 0)
        {
            [self getQuestion];
        }
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
    return @"navigation_two";
}

@end
