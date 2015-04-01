//
//  MyOrderView.m
//  BowlKitchen
//
//  Created by mac on 15/3/26.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyOrderView.h"
#import "MyOrder.h"
#import "MyOrderCell.h"
#import "MyCommodity.h"
#import "OrderDetailView.h"

@interface MyOrderView ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray *orderArray;
}

@end

@implementation MyOrderView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"我的订单";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self getMyOrderList];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getMyOrderList
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"250" forKey:@"countPerPages"];
    [param setValue:@"1" forKey:@"pageNumbers"];
    [param setValue:[[UserModel Instance] getUserInfo].regUserId forKey:@"regUserId"];
    
    NSString *orderPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findOrderByPage] params:param];
    
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
       NSArray *arry = [[json objectForKey:@"data"] objectForKey:@"resultsList"];
        orderArray = [Tool readJsonToObjArray:arry andObjClass:[MyOrder class]];
        [self.tableView reloadData];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self getMyOrderList];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return orderArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderCell"];
    if (!cell)
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyOrderCell" owner:self options:nil];
        for (NSObject *o in objects)
        {
            if ([o isKindOfClass:[MyOrderCell class]])
            {
                cell = (MyOrderCell *)o;
                break;
            }
        }
    }
    
    MyOrder *order = [orderArray objectAtIndex:indexPath.row];
    MyCommodity *comm = order.commodityList[0];
    [cell.orderImg sd_setImageWithURL:[NSURL URLWithString:comm.imgUrlFull]];
    cell.orderTitleLabel.text = comm.commodityName;
    cell.orderDateLabel.text = [Tool TimestampToDateStr:order.starttimeStamp andFormatterStr:@"yyyy-MM-dd HH:mm"];
    cell.orderCountPriceLabel.text = [NSString stringWithFormat:@"总金额:￥%@",order.totalPrice];
    cell.orderNumLabel.text = [NSString stringWithFormat:@"%@份",comm.num];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailView *detailView = [[OrderDetailView alloc] init];
    
    detailView.myOrder = [orderArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailView animated:YES];
}

@end
