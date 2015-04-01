//
//  WishView.m
//  BowlKitchen
//
//  Created by mac on 15/3/23.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "OrderView.h"
#import "OrderConfirmView.h"
#import "UIImageView+WebCache.h"
@interface OrderView ()<UITextViewDelegate>
{
    //购买数量
    NSInteger shopNum;
    
    //购买总金额
    CGFloat countPrice;
}

@end

@implementation OrderView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //购买数量默认为一份
    shopNum = 1;
    //购买总金额默认为100
    countPrice = self.commodity.price;
    self.countText.text = [NSString stringWithFormat:@"共%i件商品    合计：￥%0.2f",shopNum,countPrice];
    
    self.commodityNameLabel.text = self.commodity.commodityName;
    self.commodityPriceLabel.text = [NSString stringWithFormat:@"￥%0.2f",self.commodity.price];
    [self.commodityImg sd_setImageWithURL:[NSURL URLWithString:self.commodity.imgURL]];
    
    self.hidesBottomBarWhenPushed=YES;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"订单";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    [self.finishBtn.layer setMasksToBounds:YES];
    [self.finishBtn.layer setCornerRadius:4.0]; //设置矩圆角半径
    
    //添加边框
    CALayer * layer = [self.textView layer];
    layer.borderColor = [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1] CGColor];
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 3.0;
    
    layer = [self.shopView layer];
    layer.borderColor = [[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1] CGColor];
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 3.0;
    
    self.textView.delegate = self;
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text

{
    if (range.location > 30)
    {
        [textView resignFirstResponder];
        [Tool showCustomHUD:@"输入字数超过限制" andView:self.view andImage:nil andAfterDelay:1.2f];
        NSString *textStr = [NSString stringWithFormat:@"%@%@",textView.text,text];
        [textView setText:[textStr substringToIndex:30]];
        return NO;
    }
    return YES;
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)finishAction:(UIButton *)sender
{
    OrderConfirmView *orderConfirmView = [[OrderConfirmView alloc] init];
    orderConfirmView.shopNum = shopNum;
    orderConfirmView.countPrice = countPrice;
    orderConfirmView.wishStr = self.textView.text;
    orderConfirmView.commodityId = self.commodity.commodityId;
    
    [self.navigationController pushViewController:orderConfirmView animated:YES];
}

- (IBAction)minAction:(UIButton *)sender
{
    if(shopNum > 1)
    {
        --shopNum;
        countPrice -= self.commodity.price;
        self.countText.text = [NSString stringWithFormat:@"共%i件商品    合计：￥%0.2f",shopNum,countPrice];
        self.countField.text = [NSString stringWithFormat:@"%i",shopNum];
    }
}

- (IBAction)addAction:(UIButton *)sender
{
    ++shopNum;
    countPrice += self.commodity.price;
    self.countText.text = [NSString stringWithFormat:@"共%i件商品    合计：￥%0.2f",shopNum,countPrice];
    self.countField.text = [NSString stringWithFormat:@"%i",shopNum];
}

@end
