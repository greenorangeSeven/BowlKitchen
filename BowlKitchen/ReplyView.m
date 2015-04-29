//
//  ReplyView.m
//  BowlKitchen
//
//  Created by mac on 15/4/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "ReplyView.h"
#import "Reply.h"

@interface ReplyView ()

@end

@implementation ReplyView

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)pushAction:(id)sender
{
    NSString *replyContent = self.textView.text;
    
    if(replyContent.length == 0)
    {
        [Tool showCustomHUD:@"回复内容不能为空" andView:self.view andImage:nil andAfterDelay:1.2];
        return;
    }
    
    //生成订单提交URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.starttimeStr forKey:@"starttime"];
    [param setValue:replyContent forKey:@"replyContent"];
    UserInfo *userinfo = [[UserModel Instance] getUserInfo];
    [param setValue:userinfo.regUserId forKey:@"regUserId"];
    
    NSString *replySign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addDayQuestionReply] params:param];
    
    NSString *replyUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addDayQuestionReply];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:replyUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:replySign forKey:@"sign"];
    [request setPostValue:self.starttimeStr forKey:@"starttime"];
    [request setPostValue:replyContent forKey:@"replyContent"];
    [request setPostValue:userinfo.regUserId forKey:@"regUserId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestCCFailed:)];
    [request setDidFinishSelector:@selector(requestReply:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}

- (void)requestCCFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestReply:(ASIHTTPRequest *)request
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
        return;
    }
    else
    {
        [Tool showCustomHUD:[[json objectForKey:@"header"] objectForKey:@"msg"] andView:self.view andImage:nil andAfterDelay:1.2f];
        
        Reply *reply = [Tool readJsonDicToObj:[json objectForKey:@"data"] andObjClass:[Reply class]];
        UserInfo *userinfo = [[UserModel Instance] getUserInfo];
        reply.regUserName = userinfo.regUserName;
        reply.regUserId = userinfo.regUserId;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeReload" object:self userInfo:[NSDictionary dictionaryWithObject:reply forKey:@"newReply"]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
