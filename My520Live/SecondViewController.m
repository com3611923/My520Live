//
//  SecondViewController.m
//  My520Live
//
//  Created by caobin on 16/9/5.
//  Copyright © 2016年 caobin. All rights reserved.
//

#import "SecondViewController.h"
#import "ShowTimeViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UITextField *serverAddrTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverPortTextField;
@property (weak, nonatomic) IBOutlet UITextField *liveNameTextField;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)SingleTap:(UITapGestureRecognizer *)gesture
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (IBAction)startMyLiving:(id)sender {
    
    ShowTimeViewController *controller = [[ShowTimeViewController alloc] init];
    controller.serverAddr = _serverAddrTextField.text;
    controller.serverPort = _serverPortTextField.text;
    controller.liveName = _liveNameTextField.text;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
