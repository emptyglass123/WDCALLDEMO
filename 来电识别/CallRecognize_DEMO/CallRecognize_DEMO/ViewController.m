//
//  ViewController.m
//  CallRecognize_DEMO
//
//  Created by 朱辉 on 2017/5/3.
//  Copyright © 2017年 jxx. All rights reserved.
//

#import "ViewController.h"
#import <CallKit/CallKit.h>
#import <CallKit/CXBase.h>
#import "AppDelegate.h"
#import "CKAlertViewController.h"


#define CallNumberGroupString @"group.CALLGROUP"
#define CallNumberGroupPath   @"Library/Caches/good"
#define iOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define DLog(x, ...) NSLog(@"%s-line# %d: " x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define getPointX(x)         ScreenWidth*x/1080


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self checkCallPermissions];
    
    [self writeTextCallNumber];

}


-(void)writeTextCallNumber
{
    NSMutableArray *mDataArr = [NSMutableArray arrayWithCapacity:0];
    // 测试数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"8618811777516" forKey:@"CALL_NUMBER"];
    [dic setObject:@"哈哈" forKey:@"CALL_NAME"];
    [dic setObject:@"2" forKey:@"CALL_SEX"];
    [dic setObject:@"" forKey:@"CALL_ADDRESS"];
    [mDataArr addObject:dic];
    
    NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
    [dic2 setObject:@"8618811777517" forKey:@"CALL_NUMBER"];
    [dic2 setObject:@"呵呵" forKey:@"CALL_NAME"];
    [dic2 setObject:@"2" forKey:@"CALL_SEX"];
    [dic2 setObject:@"" forKey:@"CALL_ADDRESS"];
    [mDataArr addObject:dic2];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:CallNumberGroupString];
    containerURL = [containerURL URLByAppendingPathComponent:CallNumberGroupPath];
    
    BOOL result = [mDataArr writeToURL:containerURL atomically:YES];
    if (!result) {
        DLog(@"号码库写入共享数据区失败 !");
    } else {
        DLog(@"号码库写入共享数据区成功 !");
        [self reloadExtension];
    }
    
}
-(void)checkCallPermissions
{
    
    if (iOS10) {
        NSString *extBundleId = [NSString stringWithFormat:@"%@.WDCallKit", [[NSBundle mainBundle] bundleIdentifier]];// Call dictionary Extension 的 Bundle Identifer
        CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
        // 获取权限状态
        [manager getEnabledStatusForExtensionWithIdentifier:extBundleId completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
            
            if (!error) {
                
                NSString *title = nil;NSInteger type; type = 0;
                if (enabledStatus == CXCallDirectoryEnabledStatusDisabled) {
                    title = @"来电识别未授权,请在设置->电话->来电阻止与身份识别中打开";
                    type = 1;
                    [self showCallKitView:title withType:type handler:nil];
                    
                }else if (enabledStatus == CXCallDirectoryEnabledStatusEnabled){
                    title = @"来电识别授权成功";
                    
                }else{
                    title = @"授权失败";
                    
                }
                DLog(@"来电识别:%@",title);
                
                
            }else{
                if (!(TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1)) {
                    
                    [self showCallKitView:@"来电识别授权发生错误" withType:0 handler:nil];
                    
                }
            }
            
            
        }];
    }
    
    
}

-(void)reloadExtension{
    
    if (iOS10) {
        NSString *extBundleId = [NSString stringWithFormat:@"%@.WDCallKit", [[NSBundle mainBundle] bundleIdentifier]];// Call dictionary Extension 的 Bundle Identifer
        CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
        [manager reloadExtensionWithIdentifier:extBundleId completionHandler:^(NSError * _Nullable error) {
            ///NSLog(@"end time =  %@ ",[NSDate date]);
            NSString *msg = @"" ;
            if (error == nil) {
                
                msg = @"更新号码库成功";
            }else{
                msg = @"更新号码库失败";
            }
            
            DLog(@"%@",msg);
        }];
        
    }
}



-(void)showCallKitView:(nullable NSString *)msg withType:(NSInteger)type handler:(void (^ __nullable)())handler
{
    AppDelegate *appdelegate = (AppDelegate  * _Nullable )[UIApplication sharedApplication].delegate;// Appdelegate
    UIViewController *rootViewController = appdelegate.window.rootViewController;// RootViewController
    
    // Create AlertController
    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:@"" message:msg];
    alertVC.messageAlignment = NSTextAlignmentCenter;
    
    if (type == 1) { // 打开来电识别权限步骤
        // Create nextTip Alert Action
        CKAlertAction *nextTip = [CKAlertAction actionWithTitle:@"确定" handler:^(CKAlertAction *action) {
        }];
        [alertVC addAction:nextTip];// Add nextTip alert action
    }
    
    [rootViewController presentViewController:alertVC animated:NO completion:^{
        
        if (type != 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [rootViewController dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
