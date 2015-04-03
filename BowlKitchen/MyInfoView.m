//
//  MyInfoView.m
//  BowlKitchen
//
//  Created by mac on 15/3/26.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyInfoView.h"
#import "VPImageCropperViewController.h"

@interface MyInfoView ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate, UIPickerViewDelegate,UIAlertViewDelegate>
{
    UIImage *uploadFace;
}

@end

@implementation MyInfoView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed=YES;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"个人信息";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [lBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [lBtn setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    [self.commitBtn.layer setMasksToBounds:YES];
    [self.commitBtn.layer setCornerRadius:4.0f];
    
    [self initUserInfo];
}

- (void)initUserInfo
{
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    self.nameField.text = userInfo.nickName;
    self.emailField.text = userInfo.email;
    self.addressField.text = userInfo.address;
    self.phoneLabel.text = userInfo.mobileNo;
    [self.avatarImg sd_setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head"]];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)updateAvatarImg:(UIButton *)sender
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (IBAction)commitAction:(UIButton *)sender
{
    NSString *nickNameStr = self.nameField.text;
    NSString *emailStr = self.emailField.text;
    NSString *addressStr = self.addressField.text;
    NSString *oldPwdStr = self.oldPwdField.text;
    NSString *newPwdStr = self.pwdField.text;
    
    if(!nickNameStr || nickNameStr.length == 0)
    {
        [Tool showCustomHUD:@"昵称不能为空" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(emailStr && ![emailStr isValidEmail])
    {
        [Tool showCustomHUD:@"邮箱格式错误" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(oldPwdStr && oldPwdStr.length > 0 && (!newPwdStr || newPwdStr.length == 0))
    {
        [Tool showCustomHUD:@"新密码不能为空" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    if(newPwdStr && newPwdStr.length > 0 && (!oldPwdStr || oldPwdStr.length == 0))
    {
        [Tool showCustomHUD:@"旧密码不能为空" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    //生成修改个人资料URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    [param setValue:nickNameStr forKey:@"nickName"];
    if(newPwdStr && newPwdStr.length > 0)
    {
        [param setValue:newPwdStr forKey:@"password"];
    }
    if(oldPwdStr && oldPwdStr.length > 0)
    {
        [param setValue:oldPwdStr forKey:@"oldPassword"];
    }
    if(emailStr && emailStr.length > 0)
    {
        [param setValue:emailStr forKey:@"email"];
    }
    if(addressStr && addressStr.length > 0)
    {
        [param setValue:addressStr forKey:@"address"];
    }
    NSString *changeInfoSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_modiRegUserInfo] params:param];
    
    NSString *changeInfoUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_modiRegUserInfo];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:changeInfoUrl]];
    [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
    [request setTimeOutSeconds:30];
    [request setPostValue:changeInfoSign forKey:@"sign"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request setPostValue:nickNameStr forKey:@"nickName"];
    
    if(newPwdStr && newPwdStr.length > 0)
    {
        [request setPostValue:newPwdStr forKey:@"password"];
    }
    if(oldPwdStr && oldPwdStr.length > 0)
    {
        [request setPostValue:oldPwdStr forKey:@"oldPassword"];
    }
    if(emailStr && emailStr.length > 0)
    {
        [request setPostValue:emailStr forKey:@"email"];
    }
    if(addressStr && addressStr.length > 0)
    {
        [request setPostValue:addressStr forKey:@"address"];
    }
    
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestChangeUserInfo:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"资料更新..." andView:self.view andHUD:request.hud];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    uploadFace = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        self.avatarImg.image = editedImage;
        [self uploadFaceApi];
    }];
}

- (void)uploadFaceApi
{
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    //生成更换头像URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    NSString *changePhotoSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_changeUserPhoto] params:param];
    
    NSString *changePhotoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_changeUserPhoto] params:param];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:changePhotoUrl]];
    [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
    [request setTimeOutSeconds:30];
    [request setPostValue:changePhotoSign forKey:@"sign"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request addData:UIImageJPEGRepresentation(uploadFace, 0.8f) withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"pic"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestChangeUserPhoto:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"头像更新..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
    if(self.navigationItem.rightBarButtonItem.enabled == NO)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestChangeUserPhoto:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        NSString *userPhoto = [json objectForKey:@"data"];
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        userInfo.photoFull = userPhoto;
        [[UserModel Instance] saveUserInfo:userInfo];
        [self.avatarImg sd_setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head"]];
    }
}

- (void)requestChangeUserInfo:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        userInfo.nickName = self.nameField.text;
        NSString *emailStr = self.emailField.text;
        NSString *addressStr = self.addressField.text;
        if(emailStr && emailStr.length > 0)
        {
            userInfo.email = emailStr;
        }
        if(addressStr && addressStr.length > 0)
        {
            userInfo.address = addressStr;
        }
        [[UserModel Instance] saveUserInfo:userInfo];

        [Tool showCustomHUD:@"已修改" andView:self.view andImage:nil andAfterDelay:1.5f];
    }
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                //使用前置摄像头
                //                if ([self isFrontCameraAvailable]) {
                //                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                //                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
