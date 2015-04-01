//
//  MyAddress.h
//  BowlKitchen
//
//  Created by mac on 15/3/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyAddress : Jastor<NSCoding>

@property (copy, nonatomic) NSString *regUserId;
@property (copy, nonatomic) NSString *addressId;
@property (copy, nonatomic) NSString *receivingUserName;
@property (copy, nonatomic) NSString *receivingAddress;
@property (copy, nonatomic) NSString *phone;

@end
