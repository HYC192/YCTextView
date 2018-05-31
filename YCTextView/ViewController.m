//
//  ViewController.m
//  YCTextView
//
//  Created by mac on 2018/5/28.
//  Copyright © 2018年 YC. All rights reserved.
//

#import "ViewController.h"
#import "YCEditController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"主界面";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextAction:(id)sender {
    YCEditController *editVC = [[YCEditController alloc] init];
//    editVC.messageContent = @"[img]https://app.niannian99.com?isdf1.jpg[/img][img]https://app.niannian99.com?isdf2.jpg[/img]sodfsdlf[img]https://app.niannian99.com?isdf3.jpg[/img]";
    [self.navigationController pushViewController:editVC animated:YES];
}


@end
