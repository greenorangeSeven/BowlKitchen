//
//  OrderDetailView.m
//  BowlKitchen
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "OrderDetailView.h"

@interface OrderDetailView ()

@end

@implementation OrderDetailView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed=YES;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"订单详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    [self bindData];
}

- (void)bindData
{
    if(self.myOrder)
    {
        self.nameLabel.text = self.myOrder.receivingUserName;
        MyCommodity *comm = self.myOrder.commodityList[0];
        self.shopNameLabel.text = [NSString stringWithFormat:@"%@%@份",comm.commodityName,comm.num];
        self.timeLabel.text = [Tool TimestampToDateStr:self.myOrder.starttimeStamp andFormatterStr:@"yyyy-MM-dd HH:mm"];
        self.addressLabel.text = self.myOrder.receivingAddress;
        self.statusLabel.text = self.myOrder.stateName;
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

@end
