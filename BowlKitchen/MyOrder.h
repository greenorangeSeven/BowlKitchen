//
//  MyOrder.h
//  BowlKitchen
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyOrder : Jastor

@property (copy, nonatomic) NSString *stateName;

@property (copy, nonatomic) NSString *regUserName;
@property (copy, nonatomic) NSString *payTypeName;
@property (copy, nonatomic) NSString *starttimeStamp;
@property (copy, nonatomic) NSString *payTimeStamp;
@property (copy, nonatomic) NSString *sendTimeStamp;
@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *starttime;
@property (copy, nonatomic) NSString *totalPrice;
@property (copy, nonatomic) NSString *stateId;
@property (copy, nonatomic) NSString *regUserId;
@property (copy, nonatomic) NSString *remark;
@property (copy, nonatomic) NSString *receivingUserName;
@property (copy, nonatomic) NSString *receivingAddress;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *payTypeId;
@property (copy, nonatomic) NSString *sendTimeType;

@property (copy, nonatomic) NSArray *commodityList;

+ (Class)commodityList_class;

@end
