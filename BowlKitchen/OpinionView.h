//
//  OpinionView.h
//  XuChangLife
//
//  Created by Seven on 15/2/5.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpinionView : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *contentTv;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
- (IBAction)submitAction:(id)sender;

@end
