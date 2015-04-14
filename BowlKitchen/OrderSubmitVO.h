//
//  OrderSubmitVO.h
//  BowlKitchen
//
//  Created by mac on 15/3/25.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderSubmitVO : NSObject

/**
 * 注册用户id
 */
@property (copy, nonatomic)  NSString *regUserId;

/**
 * 用户下单留言
 */
@property (copy, nonatomic)  NSString *remark;

/**
 * 收货人姓名
 */
@property (copy, nonatomic)  NSString *receivingUserName;

/**
 * 收货地址
 */
@property (copy, nonatomic)  NSString *receivingAddress;

/**
 * 联系电话
 */
@property (copy, nonatomic)  NSString *phone;

/**
 * 支付方式(0:支付宝,1:货到付款)
 */
@property (assign, nonatomic)  NSInteger payTypeId;

/**
 * 支付方式
 */
@property (assign, nonatomic)  NSInteger sendTimeType;

/**
 * 下单商品列表OrderCommoditySubmit
 */
@property (strong, nonatomic) NSArray *commodityList;

@end
