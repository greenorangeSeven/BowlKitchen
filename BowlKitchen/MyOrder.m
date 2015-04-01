//
//  MyOrder.m
//  BowlKitchen
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyOrder.h"
#import "MyCommodity.h"

@implementation MyOrder

+ (Class)commodityList_class
{
    return [MyCommodity class];
}

@end
