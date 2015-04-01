//
//  UserInfo.h
//  BowlKitchen
//
//  Created by mac on 15/3/16.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jastor.h"

@interface UserInfo : Jastor <NSCoding>

@property (copy, nonatomic) NSString *regUserId;
@property (copy, nonatomic) NSString *regUserName;
@property (copy, nonatomic) NSString *mobileNo;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *starttime;
@property (copy, nonatomic) NSString *lastLoginTime;

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *photoFull;

@property (assign, nonatomic) int loginCount;
@property (assign, nonatomic) int userStateId;
@property (assign, nonatomic) int age;

@end
