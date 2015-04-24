//
//  Reply.h
//  BowlKitchen
//
//  Created by mac on 15/4/23.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reply : Jastor

@property (copy, nonatomic) NSString *regUserName;
@property (copy, nonatomic) NSString *nickName;
@property (assign, nonatomic) NSInteger heartCount;
@property (assign, nonatomic) NSInteger is_heart;
@property (copy, nonatomic) NSString *replyTimeStamp;
@property (copy, nonatomic) NSString *starttime;
@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *replyContent;
@property (copy, nonatomic) NSString *replyTime;
@property (copy, nonatomic) NSString *regUserId;

@end
