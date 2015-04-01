//
//  MyAddressAddView.h
//  BowlKitchen
//
//  Created by mac on 15/3/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAddress.h"

@interface MyAddressDetailView : UIViewController

@property (weak, nonatomic) MyAddress *myAddress;

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
- (IBAction)updateAction:(id)sender;

@end
