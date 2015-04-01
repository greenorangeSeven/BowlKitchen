//
//  MyAddressView.m
//  BowlKitchen
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyAddressView.h"
#import "MyAddressAddView.h"
#import "MyAddress.h"
#import "MyAddressCell.h"
#import "MyAddressDetailView.h"

@interface MyAddressView ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray *addressArray;
}

@end

@implementation MyAddressView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"地址管理";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 19)];
    [rBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"activity_add"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    self.navigationItem.leftBarButtonItem = backbtn;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getMyAddress];
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
        NSArray *arry = [json objectForKey:@"data"];
        addressArray = [Tool readJsonToObjArray:arry andObjClass:[MyAddress class]];
        [self.tableView reloadData];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self getMyAddress];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return addressArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyAddressCell"];
    if (!cell)
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyAddressCell" owner:self options:nil];
        for (NSObject *o in objects)
        {
            if ([o isKindOfClass:[MyAddressCell class]])
            {
                cell = (MyAddressCell *)o;
                break;
            }
        }
    }
    
    MyAddress *address = [addressArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"姓名:%@",address.receivingUserName];
    cell.phoneLabel.text = [NSString stringWithFormat:@"电话:%@",address.phone];
    cell.addressLabel.text = [NSString stringWithFormat:@"地址:%@",address.receivingAddress];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyAddress *address = [addressArray objectAtIndex:indexPath.row];
    //设置
    if(self.type == 1)
    {
        MyAddressDetailView *detailView = [[MyAddressDetailView alloc] init];
        detailView.myAddress = address;
        
        [self.navigationController pushViewController:detailView animated:YES];
    }
    //订单
    else if(self.type == 2)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAddress" object:nil userInfo:[NSDictionary dictionaryWithObject:address forKey:@"address"]];
        
//        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:address,@"address", nil];
//        //创建通知
//        NSNotification *notification =[NSNotification notificationWithName:@"updateAddress" object:nil userInfo:dict];
//        //通过通知中心发送通知
//        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)addAction:(id)sender
{
    [self.navigationController pushViewController:[[MyAddressAddView alloc] init] animated:YES];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
