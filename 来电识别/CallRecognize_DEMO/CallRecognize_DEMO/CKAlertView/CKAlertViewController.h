//
//  CKAlertViewController.h
//  自定义警告框
//
//  Created by 陈凯 on 16/8/24.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(CKAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;

@end


@interface CKAlertViewController : UIViewController

@property (nonatomic, readonly) NSArray<CKAlertAction *> *actions;
@property (nonatomic, copy) NSString *bigTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSTextAlignment messageAlignment;
@property (nonatomic, assign) BOOL sureNearCancle;//确定按钮和取消按钮靠近并排显示

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message;
- (void)addAction:(CKAlertAction *)action;
- (void)setImage:(UIImage *)image selImage:(UIImage *)selImage;///可以选择的按钮的图片
@property (nonatomic, weak) UIButton *selBtn;

@end
