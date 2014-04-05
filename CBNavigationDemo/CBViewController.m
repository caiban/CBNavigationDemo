//
//  CBViewController.m
//  CBNavigationDemo
//
//  Created by z on 14-4-3.
//  Copyright (c) 2014年 z. All rights reserved.
//

#import "CBViewController.h"

@interface CBViewController ()

@end

@implementation CBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CGFloat red = (arc4random() % 101) / 255.f;
    CGFloat green = (arc4random() % 101) / 100.f;
    CGFloat blue = (arc4random() % 101) / 100.f;
    
    self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 100);
    button.center = self.view.center;
    [button setTitle:@"toRoot" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toRoot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)tap:(UITapGestureRecognizer *)tap
{
//    NSLog(@"tap");
    CBViewController *subVC = [[CBViewController alloc] init];
    [self.navigationController pushViewController:subVC animated:YES];
}

- (void)toRoot:(id)sender
{
//    NSLog(@"toRoot");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
