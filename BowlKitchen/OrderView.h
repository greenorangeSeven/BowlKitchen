//
//  WishView.h
//  BowlKitchen
//
//  Created by mac on 15/3/23.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commodity.h"

@interface OrderView : UIViewController

@property (strong, nonatomic) Commodity *commodity;
@property (weak, nonatomic) IBOutlet UIImageView *commodityImg;
@property (weak, nonatomic) IBOutlet UILabel *commodityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityPriceLabel;

@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (weak, nonatomic) IBOutlet UILabel *textHint;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *countText;
@property (weak, nonatomic) IBOutlet UITextField *countField;
@property (weak, nonatomic) IBOutlet UIView *shopView;

- (IBAction)finishAction:(UIButton *)sender;

- (IBAction)minAction:(UIButton *)sender;
- (IBAction)addAction:(UIButton *)sender;

@end
