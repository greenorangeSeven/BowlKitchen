//
//  OrderCommoditySubmit.h
//  BowlKitchen
//
//  Created by mac on 15/3/25.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderCommoditySubmit : NSObject

/**
 * 商品ID
 */
@property (copy, nonatomic) NSString *commodityId;

/**
 * 购买数量
 */
@property (assign, nonatomic) NSInteger num;

@end
