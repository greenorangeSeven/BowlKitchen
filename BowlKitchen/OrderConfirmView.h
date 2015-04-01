//
//  OrderConfirmView.h
//  BowlKitchen
//
//  Created by mac on 15/3/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"

@interface OrderConfirmView : UIViewController

@property (copy, nonatomic) NSString *commodityId;
//购买数量
@property (assign ,nonatomic) NSInteger shopNum;

//购买总金额
@property (assign ,nonatomic) CGFloat countPrice;

//祝福语
@property (copy, nonatomic) NSString *wishStr;

@property (weak, nonatomic) IBOutlet UITextView *addressText;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

- (IBAction)updateAddressAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *forenoonCheckView;

@property (weak, nonatomic) IBOutlet UIView *afternoonCheckView;

@property (weak, nonatomic) IBOutlet UIButton *shopTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *alipayTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@property SSCheckBoxView *forenoonCb;
@property SSCheckBoxView *afternoonCb;

- (IBAction)shopTypeAction:(UIButton *)sender;
- (IBAction)alipayTypeAction:(UIButton *)sender;

- (IBAction)commitOrderAction:(UIButton *)sender;

@end
