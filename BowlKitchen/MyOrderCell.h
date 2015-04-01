//
//  MyOrderCell.h
//  BowlKitchen
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *orderImg;
@property (weak, nonatomic) IBOutlet UILabel *orderDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderCountPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;

@end
