//
//  MainResource.h
//  BowlKitchen
//
//  Created by mac on 15/3/19.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicRec : Jastor<NSCoding>

@property (copy, nonatomic) NSString *id;

@property (copy, nonatomic) NSString *timeStmap;

@property (copy, nonatomic) NSString *songUrl;

@property (copy, nonatomic) NSString *songDiskPath;

@property (copy, nonatomic) NSString *songName;

@end
