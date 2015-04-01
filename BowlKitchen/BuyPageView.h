//
//  BuyPageView.h
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyPageView : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *share_btn;
@property (weak, nonatomic) IBOutlet UIImageView *shop_img;
@property (weak, nonatomic) IBOutlet UILabel *shop_name_label;
@property (weak, nonatomic) IBOutlet UIWebView *shop_details_webview;

@property (weak, nonatomic) IBOutlet UIButton *buy_btn;
- (IBAction)shareAction:(UIButton *)sender;
- (IBAction)buyAction:(UIButton *)sender;

@end
