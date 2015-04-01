//
//  UnknowThreeView.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "NewMessagePageView.h"
#import "SttingPageView.h"
#import "NewMessageCell.h"
#import "EGORefreshTableHeaderView.h"
#import "News.h"
#import "NewDetailView.h"

@interface NewMessagePageView ()<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate>
{
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSMutableArray *newArray;
}

@end

@implementation NewMessagePageView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"最新资讯";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"navigation_menu"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    
    newArray = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
}

- (void)menuAction:(id)sender
{
    [self.navigationController pushViewController:[[SttingPageView alloc] init] animated:YES];
}

- (void)clear
{
    allCount = 0;
    [newArray removeAllObjects];
    isLoadOver = NO;
}

- (void)reload:(BOOL)noRefresh
{
    
    if (isLoading || isLoadOver) {
        return;
    }
    
    if (!noRefresh)
    {
        allCount = 0;
    }
    int pageIndex = allCount/20 + 1;
    
    //生成获取新闻列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
    [param setValue:@"20" forKey:@"countPerPages"];
    NSString *getNoticeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findNewsInfoByPage] params:param];
    
    [[AFOSCClient sharedClient]getPath:getNoticeListUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                   NSError *error;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   
                                   NSArray *arry = [[json objectForKey:@"data"] objectForKey:@"resultsList"];
                                   
                                   NSMutableArray *newlist = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:arry andObjClass:[News class]]];
                                   
                                   isLoading = NO;
                                   if (!noRefresh)
                                   {
                                       [self clear];
                                   }
                                   
                                   @try {
                                       int count = [newlist count];
                                       allCount += count;
                                       if (count < 20)
                                       {
                                           isLoadOver = YES;
                                       }
                                       [newArray addObjectsFromArray:newlist];
                                       [self.tableView reloadData];
                                       [self doneLoadingTableViewData];
                                   }
                                   @catch (NSException *exception) {
                                       [NdUncaughtExceptionHandler TakeException:exception];
                                   }
                                   @finally {
                                       [self doneLoadingTableViewData];
                                   }
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   NSLog(@"列表获取出错");
                                   //如果是刷新
                                   [self doneLoadingTableViewData];
                                   
                                   if ([UserModel Instance].isNetworkRunning == NO) {
                                       return;
                                   }
                                   isLoading = NO;
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
    return 83.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning)
    {
        if (isLoadOver) {
            return newArray.count == 0 ? 1 : newArray.count;
        }
        else
            return newArray.count + 1;
    }
    else
        return newArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if ([newArray count] > 0) {
        if (row < [newArray count])
        {
            NewMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewMessageCell"];
            if (!cell)
            {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NewMessageCell" owner:self options:nil];
                for (NSObject *o in objects)
                {
                    if ([o isKindOfClass:[NewMessageCell class]])
                    {
                        cell = (NewMessageCell *)o;
                        break;
                    }
                }
            }
            
            News *news = [newArray objectAtIndex:indexPath.row];
            
            cell.summaryLabel.text = [Tool filterHTML:news.content];
            cell.timeLabel.text = [Tool TimestampToDateStr:news.starttimeStamp andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    //点击“下面20条”
    if (row >= [newArray count]) {
        //启动刷新
        if (!isLoading)
        {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        News *news = newArray[indexPath.row];
        NewDetailView *detailView = [[NewDetailView alloc] init];
        detailView.newsId = news;
        [self.navigationController pushViewController:detailView animated:YES];
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
    if (!isLoading) {
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

- (NSString *)tabImageName
{
    return @"navigation_three";
}




@end
