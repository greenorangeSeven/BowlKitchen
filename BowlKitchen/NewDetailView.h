//
//  NewDetailView.h
//  BowlKitchen
//
//  Created by mac on 15/3/31.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
@class News;

@interface NewDetailView : UIViewController

@property (weak, nonatomic) News *newsId;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
