//
//  ReplyView.h
//  BowlKitchen
//
//  Created by mac on 15/4/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReplyView : UIViewController

@property (copy, nonatomic) NSString *starttimeStr;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)backAction:(id)sender;
- (IBAction)pushAction:(id)sender;

@end
