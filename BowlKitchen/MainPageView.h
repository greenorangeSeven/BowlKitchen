//
//  MainPageView.h
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPageView : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *main_bg;
@property (weak, nonatomic) IBOutlet UIImageView *main_fg;
- (IBAction)playOrPauseAction:(UIButton *)sender;

@end
