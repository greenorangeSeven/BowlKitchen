//
//  MainPageView.m
//  BowlKitchen
//
//  Created by mac on 15/3/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MainPageView.h"
#import "SttingPageView.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicRec.h"
#import "TCBlobDownloadManager.h"
#import "ImageRec.h"
#import "UIImageView+WebCache.h"
#import <ShareSDK/ShareSDK.h>

@interface MainPageView ()
{
    AVAudioPlayer *audioPlayer;
    MusicRec *resource;
    BOOL isPaused;
    UIWebView *phoneWebView;
}

@end

@implementation MainPageView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"能量碗";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"navigation_menu"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(tellAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"tousu_tell"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    [self initMusic];
    [self imageInfo];
}

- (void)tellAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", ServiceTell]];
    phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

#pragma mar 初始化音乐
- (void)initMusic
{
    EGOCache *cache = [EGOCache globalCache];
    resource = (MusicRec *)[cache objectForKey:@"musicInfocache"];
    if(resource && resource.songDiskPath)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:resource.songDiskPath])
        {
            NSLog(@"truetruetrue");
        }
        
        NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        
        NSString *musicPath = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"MusicCache"] copy];
        
        NSString *muPath = [musicPath stringByAppendingPathComponent:[resource.songDiskPath lastPathComponent]];
        
        [self playBackMusic:muPath];
    }
    [self musicInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(audioPlayer && !isPaused)
    {
        [audioPlayer play];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(audioPlayer)
    {
        [audioPlayer pause];
    }
}

#pragma mark 播放音乐
- (void)playBackMusic:(NSString *)path
{
    //1.音频文件的url路径
    NSURL *url=[NSURL fileURLWithPath:path];
    
    NSError *error;
    
    //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    //设为负数将无限循环播放
    audioPlayer.numberOfLoops = -1;
    
    //3.缓冲
    [audioPlayer prepareToPlay];
    
    //4.播放
    [audioPlayer play];
}

#pragma mark 获取后台音乐信息(判断是否需要更换音乐)
- (void)musicInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@", api_base_url, api_findDaySplendSong];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestOK:)];
    [request startAsynchronous];
}

- (void)imageInfo
{
    NSDate *datenow = [NSDate date];
    
    NSString *todayTimeSps = [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]];
    todayTimeSps = [Tool TimestampToDateStr:todayTimeSps andFormatterStr:@"yyyy-MM-dd"];
    
//    //当前时间+24小时即为第二天的日期
//    datenow = [NSDate dateWithTimeIntervalSinceNow:(24*60*60)];
//    NSString *tomorrowTimeSps = [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]];
//    tomorrowTimeSps = [Tool TimestampToDateStr:tomorrowTimeSps andFormatterStr:@"yyyy-MM-dd"];
    
    EGOCache *cache = [EGOCache globalCache];
    ImageRec *todayImg = (ImageRec *)[cache objectForKey:todayTimeSps];
    
    //显示今天的图片
    if(todayImg)
    {
        [self.main_bg sd_setImageWithURL:[NSURL URLWithString:todayImg.bgImgFull]];
        
        [self.main_fg sd_setImageWithURL:[NSURL URLWithString:todayImg.fontImgFull]];
    }
    else
    {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue: todayTimeSps forKey:@"starttime"];
        
        NSString *url = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findDaySplendid] params:param];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        [request setUseCookiePersistence:NO];
        [request setTimeOutSeconds:30];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestImage:)];
        [request startAsynchronous];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
}

- (void)requestOK:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO)
    {
        return;
    }
    else
    {
        MusicRec *tempResource = [Tool readJsonDicToObj:[json objectForKey:@"data"] andObjClass:[MusicRec class]];
        //如果没有缓存歌曲信息则立马下载歌曲
        if(!resource)
        {
            resource = tempResource;
            [self downloadMusic:tempResource.songUrl];
        }
        else
        {
            //如果当前歌曲时间与后台不同步则立马下载歌曲
            if(![tempResource.timeStmap isEqualToString:resource.timeStmap])
            {
                resource = tempResource;
                [self downloadMusic:resource.songUrl];
            }
        }
    }
}

- (void)requestImage:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO)
    {
        return;
    }
    else
    {
        ImageRec *imageRec = [Tool readJsonDicToObj:[json objectForKey:@"data"] andObjClass:[ImageRec class]];
        [self.main_bg sd_setImageWithURL:[NSURL URLWithString:imageRec.bgImgFull]];
        
        [self.main_fg sd_setImageWithURL:[NSURL URLWithString:imageRec.fontImgFull]];
        EGOCache *cache = [EGOCache globalCache];
        NSDate *datenow = [NSDate date];
        NSString *timeSps = [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]];
        timeSps = [Tool TimestampToDateStr:timeSps andFormatterStr:@"yyyy-MM-dd"];
        [cache setObject:imageRec forKey:timeSps];
    }
}

#pragma mark 下载音乐
- (void)downloadMusic:(NSString *)relativePath
{
    NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSString *musicPath = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"MusicCache"] copy];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",api_base_url,relativePath];
    NSURL *downloadURL = [NSURL URLWithString:url];
    TCBlobDownloadManager *sharedManager = [TCBlobDownloadManager sharedDownloadManager];
    [sharedManager startDownloadWithURL:downloadURL
                             customPath:musicPath
                          firstResponse:^(NSURLResponse *response) {
                              // [response expectedContentLength]?
                          }
                        progress:^(float receivedLength, float totalLength){
                                   
                               }
                        error:^(NSError *error){
                                      
                                  }
                        complete:^(BOOL downloadFinished, NSString *pathToFile) {
                            if(!pathToFile)
                            {
                                pathToFile = [musicPath stringByAppendingPathComponent:[[downloadURL absoluteString] lastPathComponent]];
                            }
                            
                            resource.songDiskPath = pathToFile;
                            EGOCache *cache = [EGOCache globalCache];
                            [cache setObject:resource forKey:@"musicInfocache"];
                            [self playBackMusic:resource.songDiskPath];
                            
                        }];

}

- (void)menuAction:(id)sender
{
    [self.navigationController pushViewController:[[SttingPageView alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//底部tabbar的图标名称
- (NSString *)tabImageName
{
    return @"navigation_main";
}

//播放或者暂停歌曲
- (IBAction)playOrPauseAction:(UIButton *)sender
{
    if(audioPlayer)
    {
        if([audioPlayer isPlaying])
        {
            [audioPlayer pause];
            [sender setImage:[UIImage imageNamed:@"main_play_btn_pause"] forState:UIControlStateNormal];
            isPaused = YES;
        }
        else
        {
            [audioPlayer play];
            [sender setImage:[UIImage imageNamed:@"main_play_btn"] forState:UIControlStateNormal];
            isPaused = NO;
        }
    }
}

- (IBAction)shareAction:(id)sender
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK" ofType:@"png"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"测试一下"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.mob.com"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];
}

@end
