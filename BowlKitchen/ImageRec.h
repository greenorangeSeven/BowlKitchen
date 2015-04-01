//
//  ImageRec.h
//  BowlKitchen
//
//  Created by mac on 15/3/19.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageRec : Jastor<NSCoding>

@property (copy, nonatomic) NSString *starttime;

@property (copy, nonatomic) NSString *bgImg;

@property (copy, nonatomic) NSString *bgImgFull;

@property (copy, nonatomic) NSString *bgImgDiskPath;

@property (copy, nonatomic) NSString *fontImg;

@property (copy, nonatomic) NSString *fontImgFull;

@property (copy, nonatomic) NSString *fontImgDiskPath;

@end
