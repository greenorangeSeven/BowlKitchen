//
//  Commodity.h
//  BowlKitchen
//
//  Created by mac on 15/3/25.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commodity : Jastor

@property (copy, nonatomic) NSString *commodityId;

@property (copy, nonatomic) NSString *commodityName;

@property (assign, nonatomic) CGFloat marketPrice;

@property (assign, nonatomic) CGFloat price;

@property (copy, nonatomic) NSString *details;

@property (copy, nonatomic) NSString *imgURL;

@end
