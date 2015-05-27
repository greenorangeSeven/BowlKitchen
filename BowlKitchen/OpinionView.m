//
//  OpinionView.m
//  XuChangLife
//
//  Created by Seven on 15/2/5.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "OpinionView.h"

@interface OpinionView ()

@end

@implementation OpinionView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed=YES;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"意见反馈";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    [Tool roundTextView:self.contentTv andBorderWidth:1.0 andCornerRadius:5.0];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitAction:(id)sender {
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSString *contentStr = self.contentTv.text;
        if ([contentStr length] == 0) {
            [Tool showCustomHUD:@"请输入内容" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
            return;
        }
        self.submitBtn.enabled = NO;
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:contentStr forKey:@"content"];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        NSString *addAfterFellSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addAfterFell] params:param];
        [param setValue:addAfterFellSign forKey:@"sign"];
        NSString *addAfterFellUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addAfterFell];
        
        [[AFOSCClient sharedClient] postPath:addAfterFellUrl parameters:param
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
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
                                               [Tool showCustomHUD:@"提交成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                               self.contentTv.text = @"";
                                           }
                                           self.submitBtn.enabled = YES;
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
//                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}
@end
