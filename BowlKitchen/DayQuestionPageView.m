//
//  UnknowTwoView.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "DayQuestionPageView.h"
#import "SttingPageView.h"

@interface DayQuestionPageView ()<UITextViewDelegate,UIAlertViewDelegate>
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

    [self.commitBtn.layer setMasksToBounds:YES];
    [self.commitBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
    
    //添加边框
    CALayer * layer = [self.textView layer];
    layer.borderColor = [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1] CGColor];
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 3.0;
    
    self.textView.delegate = self;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
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
        else if(alertView.tag == 1)
        {
             [self commitAction:self.commitBtn];
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(!self.textHint.hidden)
        self.textHint.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    if(!textView.text || textView.text.length == 0)
    {
        self.textHint.hidden = NO;
    }
}

- (IBAction)commitAction:(id)sender
{
    if(!questionStr || questionStr.length == 0)
    {
        [Tool showCustomHUD:@"今日没有问题提供" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    NSString *answerStr = self.textView.text;
    
    if(!answerStr || answerStr.length == 0)
    {
        [Tool showCustomHUD:@"请填写问题答案" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    self.commitBtn.enabled = NO;
    
    NSDate *datenow = [NSDate date];
    
    NSString *todayTimeSps = [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]];
    todayTimeSps = [Tool TimestampToDateStr:todayTimeSps andFormatterStr:@"yyyy-MM-dd"];
    
    //生成订单提交URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:todayTimeSps forKey:@"starttime"];
    [param setValue:answerStr forKey:@"replyContent"];
    [param setValue:[[UserModel Instance] getUserInfo].regUserId forKey:@"regUserId"];
    
    NSString *questionSubmitSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addDayQuestionReply] params:param];
    
    NSString *questionSubmitUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addDayQuestionReply];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:questionSubmitUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:todayTimeSps forKey:@"starttime"];
    [request setPostValue:answerStr forKey:@"replyContent"];
    [request setPostValue:[[UserModel Instance] getUserInfo].regUserId forKey:@"regUserId"];
    [request setPostValue:questionSubmitSign forKey:@"sign"];
    
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestCommitFailed:)];
    [request setDidFinishSelector:@selector(requestCommitOK:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在提交" andView:self.view andHUD:request.hud];
}

- (void)requestCommitFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                 message:@"网络连接失败"
                                                delegate:self
                                       cancelButtonTitle:@"重新提交"
                                       otherButtonTitles:@"取消", nil];
    av.tag = 1;
    [av show];
}

- (void)requestCommitOK:(ASIHTTPRequest *)request
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
        [Tool showCustomHUD:@"已提交" andView:self.view andImage:nil andAfterDelay:1.2f];
        self.textView.editable = NO;
    }
}
@end
