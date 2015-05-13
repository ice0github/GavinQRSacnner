//
//  GSScannerViewController.m
//  GavinQRSacnner
//
//  Created by 何桂强 on 15/5/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "GSScannerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GSBuilderViewController.h"

#define ScannerTop 120
#define ScannerSize (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?500:220)
#define ScannerBGFixed (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?50:30)
#define ResultButtonWidth 80
#define ResultButtonHeight 40

@interface GSScannerViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    
    AVCaptureDevice * device;
    AVCaptureDeviceInput * input;
    AVCaptureMetadataOutput * output;
    AVCaptureSession * session;
    AVCaptureVideoPreviewLayer * preview;
    UIImageView *scannerBGView;

    
    UIImageView *line;
    int num;
    BOOL upOrdown;
    NSTimer *timer;
    
    UITextView *resultTextView;
    UIButton *resultCopyButton;
    UIButton *resultOpenButton;
    
    UIButton *scanButton;
}



@end

@implementation GSScannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self setupCamera];
}

-(void)buildUI{
    self.title = @"Gavin's Scanner";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.000];
    
    scannerBGView = [[UIImageView alloc] init];
    scannerBGView.frame =  CGRectMake((self.view.bounds.size.width-ScannerSize)*0.5-ScannerBGFixed,
                                      ScannerTop-ScannerBGFixed,
                                      ScannerSize+ScannerBGFixed*2,
                                      ScannerSize+ScannerBGFixed*2);
    scannerBGView.image = [UIImage imageNamed:@"bg_scanner"];
    [self.view addSubview:scannerBGView];
    
    upOrdown = NO;
    num =0;
    line = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-ScannerSize)*0.5-ScannerBGFixed, ScannerTop, ScannerSize+ScannerBGFixed*2, 1)];
    line.backgroundColor = [UIColor greenColor];
    line.layer.cornerRadius = 8;
    [self.view addSubview:line];
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(scanAnimation) userInfo:nil repeats:YES];
    
    resultTextView = [[UITextView alloc] init];
    resultTextView.frame = CGRectMake(10, ScannerTop+ScannerSize+60, self.view.bounds.size.width-10*2-ResultButtonWidth-5, ResultButtonHeight*2+1);
    resultTextView.editable = NO;
    resultTextView.layer.borderWidth = 0.5;
    resultTextView.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view addSubview:resultTextView];
    
    resultCopyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resultCopyButton.frame = CGRectMake(resultTextView.frame.origin.x+resultTextView.frame.size.width+5,
                                        resultTextView.frame.origin.y,
                                        ResultButtonWidth,
                                        ResultButtonHeight);
    resultCopyButton.backgroundColor = [UIColor colorWithRed:0.836 green:0.540 blue:1.000 alpha:1.000];
    [resultCopyButton setTitle:@"复制" forState:UIControlStateNormal];
    [resultCopyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:resultCopyButton];
    
    resultOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resultOpenButton.frame = CGRectMake(resultCopyButton.frame.origin.x,
                                        resultCopyButton.frame.origin.y+ResultButtonHeight,
                                        ResultButtonWidth,
                                        ResultButtonHeight);
    resultOpenButton.backgroundColor = [UIColor colorWithRed:0.309 green:0.609 blue:1.000 alpha:1.000];
    [resultOpenButton setTitle:@"打开" forState:UIControlStateNormal];
    [resultOpenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:resultOpenButton];
    
    scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scanButton.frame = CGRectMake(20,
                                  resultTextView.frame.origin.y+resultTextView.frame.size.height+20,
                                  self.view.bounds.size.width-20*2,
                                  ResultButtonHeight);
    scanButton.backgroundColor = [UIColor colorWithRed:1.000 green:0.528 blue:0.057 alpha:1.000];
    [scanButton setTitle:@"开 始 扫 描" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:scanButton];
    
    
    [resultCopyButton addTarget:self action:@selector(copyResult) forControlEvents:UIControlEventTouchUpInside];
    [resultOpenButton addTarget:self action:@selector(openResult) forControlEvents:UIControlEventTouchUpInside];
    [scanButton addTarget:self action:@selector(startScan) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"生成" style:UIBarButtonItemStyleDone target:self action:@selector(goToGenerate)];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)scanAnimation
{
    if (upOrdown == NO) {
        num ++;
        line.frame = CGRectMake((self.view.bounds.size.width-ScannerSize)*0.5-ScannerBGFixed,
                                ScannerTop+2*num,
                                ScannerSize+ScannerBGFixed*2,
                                1);
        if (2*num >= ScannerSize) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        line.frame = CGRectMake((self.view.bounds.size.width-ScannerSize)*0.5-ScannerBGFixed,
                                ScannerTop+2*num,
                                ScannerSize+ScannerBGFixed*2,
                                1);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}


- (void)setupCamera
{
    // Device
    if (!device) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // Input
    if (!input) {
        input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    
    // Output
    if (!output) {
        output = [[AVCaptureMetadataOutput alloc]init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    
    // Session
    if (!session) {
        session = [[AVCaptureSession alloc]init];
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // Preview
    if (!preview) {
        preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        preview.frame = CGRectMake((self.view.bounds.size.width-ScannerSize)*0.5,
                                  ScannerTop,
                                  ScannerSize,
                                  ScannerSize);
        [self.view.layer insertSublayer:preview atIndex:0];
    }
    
    
    // Start
    resultTextView.text = @"";
    if (!timer.isValid) {
        timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(scanAnimation) userInfo:nil repeats:YES];
    }
    
    [session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0){
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [session stopRunning];
    
    [timer invalidate];
    
    resultTextView.text = stringValue;
}
#pragma mark - button actions
-(void)copyResult{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = resultTextView.text;
    [[[UIAlertView alloc] initWithTitle:@"提示"
                                message:@"目标链接已复制到粘贴板"
                               delegate:nil
                      cancelButtonTitle:@"知道了"
                      otherButtonTitles:nil]
     show];
}

-(void)openResult{
    NSURL *targetUrl = [NSURL URLWithString:resultTextView.text];
    if ([[UIApplication sharedApplication] canOpenURL:targetUrl]) {
        [[UIApplication sharedApplication] openURL:targetUrl];
    }else{
        [[[UIAlertView alloc] initWithTitle:@"提示"
                                    message:@"目标链接无法打开"
                                   delegate:nil
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil]
         show];
    }
}

-(void)startScan{
   [self setupCamera];
}

-(void)goToGenerate{
    GSBuilderViewController *vc = [[GSBuilderViewController alloc] init];
    vc.string = @"哈哈";
    [self.navigationController pushViewController:vc animated:YES];
}
@end
