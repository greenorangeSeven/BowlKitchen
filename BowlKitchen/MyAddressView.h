//
//  MyAddressView.h
//  BowlKitchen
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAddressView : UIViewController

@property int type;//1:设置，2:订单

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
