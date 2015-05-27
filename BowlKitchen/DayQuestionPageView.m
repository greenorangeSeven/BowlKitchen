//
//  UnknowTwoView.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "DayQuestionPageView.h"
#import "SttingPageView.h"
#import "EGORefreshTableHeaderView.h"
#import "Reply.h"
#import "ReplyCell.h"
#import "LoginView.h"
#import "RegisterView.h"
#import "ReplyView.h"

@interface DayQuestionPageView ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate>
{
    NSString *questionStr;
    NSString *starttimeStr;
    UIWebView *phoneWebView;
    
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSMutableArray *topicArray;
    UIButton *zanBtn;
    
    ReplyCell *_cell;
}

@end

@implementation DayQuestionPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"每周一问";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"navigation_menu"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(tellAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"tousu_tell"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    topicArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    allCount = 0;
    
    //添加的代码
    if (_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    _cell = [[[NSBundle mainBundle] loadNibNamed:@"ReplyCell" owner:self options:nil] lastObject];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 4.0f;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0; // 设置为一个接近“平均”行高的值
    
    //图片圆形处理
    self.faceIv.layer.masksToBounds=YES;
    self.faceIv.layer.cornerRadius=self.faceIv.frame.size.width/2;    //最重要的是这个地方要设成imgview高的一半
    self.faceIv.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticReload:) name:@"noticeReload" object:nil];
    [self getQuestion];
}

- (void)noticReload:(NSNotification *)notification
{
    Reply *reply = [[notification userInfo] valueForKey:@"newReply"];
    [topicArray insertObject:reply atIndex:0];
    [self.tableView reloadData];
}

- (void)tellAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", ServiceTell]];
    phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
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
    NSLog(@"the res:%@",request.responseString);
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
        starttimeStr = [[json objectForKey:@"data"] objectForKey:@"starttimeStr"];
        self.questionText.text= questionStr;
        [self reload:YES];
    }
}

- (void)clear
{
    allCount = 0;
    [topicArray removeAllObjects];
    isLoadOver = NO;
}

- (void)reload:(BOOL)noRefresh
{
    
    if (isLoading || isLoadOver)
    {
        return;
    }
    
    if (!noRefresh)
    {
        allCount = 0;
    }
    
    int pageIndex = allCount/page_count + 1;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
    [param setValue:@"20" forKey:@"countPerPages"];
    [param setValue:starttimeStr forKey:@"starttime"];
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    if(userInfo)
    {
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
    }
    
    NSString *findQuestionReplyByPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url,api_findQuestionReplyByPage] params:param];
    
    [[AFOSCClient sharedClient]getPath:findQuestionReplyByPageUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   NSLog(@"the response:%@",operation.responseString);
                                   
                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                   NSError *error;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   
                                   NSArray *arry = [[json objectForKey:@"data"] objectForKey:@"resultsList"];
                                   
                                   NSMutableArray *newlist = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:arry andObjClass:[Reply class]]];
                                   
                                   isLoading = NO;
                                   if (!noRefresh)
                                   {
                                       [self clear];
                                   }
                                   
                                   @try {
                                       int count = [newlist count];
                                       allCount += count;
                                       if (count < page_count)
                                       {
                                           isLoadOver = YES;
                                       }
                                       [topicArray addObjectsFromArray:newlist];
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                   }
                                   @catch (NSException *exception)
                                   {
                                       [NdUncaughtExceptionHandler TakeException:exception];
                                   }
                                   @finally {
                                       [self doneLoadingTableViewData];
                                   }
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   //如果是刷新
                                   [self doneLoadingTableViewData];
                                   
                                   if ([UserModel Instance].isNetworkRunning == NO)
                                   {
                                       return;
                                   }
                                   isLoading = NO;
                                   [self.tableView reloadData];
                                   if ([UserModel Instance].isNetworkRunning) {
                                       [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                   }
                               }];
    isLoading = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(topicArray.count > 0)
    {
        if(indexPath.row > topicArray.count - 1)
        {
            return 50;
        }
        Reply *reply = [topicArray objectAtIndex:indexPath.row];
        CGSize size = [_cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        _cell.replyContent.text = reply.replyContent;
        CGSize textViewSize = [_cell.replyContent sizeThatFits:CGSizeMake(_cell.replyContent.frame.size.width, 100000.0f)];
        return 71 > size.height+1.0f+textViewSize.height-20 ? 71 : size.height+1.0f+textViewSize.height-20;
        
        
    }
    else
    {
        return 50;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning)
    {
        if (isLoadOver)
        {
            return topicArray.count == 0 ? 1 : topicArray.count + 1;
        }
        else
            return topicArray.count + 1;
    }
    else
        return topicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if ([topicArray count] > 0)
    {
        if (row < [topicArray count])
        {
            ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell"];
            if (!cell)
            {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ReplyCell" owner:self options:nil];
                for (NSObject *o in objects)
                {
                    if ([o isKindOfClass:[ReplyCell class]])
                    {
                        cell = (ReplyCell *)o;
                        break;
                    }
                }
            }
            
            Reply *reply = [topicArray objectAtIndex:indexPath.row];
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",reply.regUserName,reply.replyContent]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.91 green:0.55 blue:0 alpha:1] range:NSMakeRange(0,reply.regUserName.length)];
            cell.replyContent.attributedText = str;
            
            [cell.zanBtn setTitle:[NSString stringWithFormat:@"赞(%li)",(long)reply.heartCount] forState:UIControlStateNormal];
            if(reply.is_heart)
            {
                [cell.zanBtn setImage:[UIImage imageNamed:@"zan_pro"] forState:UIControlStateNormal];
                                       
            }
            else
            {
                [cell.zanBtn setImage:[UIImage imageNamed:@"zan_nor"] forState:UIControlStateNormal];
            }
            cell.zanBtn.tag = indexPath.row;
            [cell.zanBtn addTarget:self action:@selector(zanAction:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部"
                                            andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
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

- (void)zanAction:(id)sender
{
    if(![[UserModel Instance] isLogin])
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
    else
    {
        zanBtn = (UIButton *)sender;
        Reply *reply = [topicArray objectAtIndex:zanBtn.tag];
        
        //生成订单提交URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:reply.id forKey:@"replyId"];
        UserInfo *userinfo = [[UserModel Instance] getUserInfo];
        [param setValue:userinfo.regUserId forKey:@"regUserId"];
        
        NSString *heartSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addOrRemoveReplyHeart] params:param];
        
        NSString *heartUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addOrRemoveReplyHeart];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:heartUrl]];
        [request setUseCookiePersistence:NO];
        [request setTimeOutSeconds:30];
        [request setPostValue:heartSign forKey:@"sign"];
        [request setPostValue:reply.id forKey:@"replyId"];
        [request setPostValue:userinfo.regUserId forKey:@"regUserId"];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestCCFailed:)];
        [request setDidFinishSelector:@selector(requestHeart:)];
        [request startAsynchronous];
        
        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    }
}

- (void)requestCCFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestHeart:(ASIHTTPRequest *)request
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
        Reply *reply = [topicArray objectAtIndex:zanBtn.tag];
        if(reply.is_heart)
        {
            reply.is_heart = 0;
            --reply.heartCount;
            [zanBtn setImage:[UIImage imageNamed:@"zan_nor"] forState:UIControlStateNormal];
        }
        else
        {
            reply.is_heart = 1;
            ++reply.heartCount;
            [zanBtn setImage:[UIImage imageNamed:@"zan_pro"] forState:UIControlStateNormal];
        }
        
        [zanBtn setTitle:[NSString stringWithFormat:@"赞(%i)",reply.heartCount] forState:UIControlStateNormal];
        zanBtn = nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [topicArray count]) {
        //启动刷新
        if (!isLoading)
        {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
    }
}


#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}

// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    if (!isLoading)
    {
        [self performSelector:@selector(reload:)];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }
}

- (void)menuAction:(id)sender
{
    [self.navigationController pushViewController:[[SttingPageView alloc] init] animated:YES];
}

- (NSString *)tabImageName
{
    return @"navigation_two";
}

- (IBAction)replyAction:(UIButton *)sender
{
    if(![[UserModel Instance] isLogin])
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
    else
    {
        ReplyView *replyView = [[ReplyView alloc] init];
        replyView.hidesBottomBarWhenPushed = YES;
        replyView.starttimeStr = starttimeStr;
        [self.navigationController pushViewController:replyView animated:YES];
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
@end
