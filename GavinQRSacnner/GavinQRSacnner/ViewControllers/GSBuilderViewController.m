//
//  GSBuilderViewController.m
//  GavinQRSacnner
//
//  Created by 何桂强 on 15/5/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "GSBuilderViewController.h"

#define BuilderButtonWidth 60
#define BuilderTextFieldHeight 40

@interface GSBuilderViewController (){
    UITextField *tf;
    UIButton *btn_build;
    
    UIImageView *iv;
    UIButton *btn_save;
    UIButton *btn_clean;
}

@end

@implementation GSBuilderViewController
@synthesize string;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"生成二维码";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.000];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self buildUI];
}

-(void)buildUI{
    
    CGFloat y = 20+44+10;
    
    if (@available(iOS 11.0, *)) {
        y = y + self.view.safeAreaInsets.bottom;
    }
    
    tf = [[UITextField alloc] init];
    tf.frame = CGRectMake(10, y, self.view.bounds.size.width-10*2-3-BuilderButtonWidth, BuilderTextFieldHeight);
    tf.backgroundColor = [UIColor whiteColor];
    tf.returnKeyType = UIReturnKeyDone;
    tf.clearButtonMode = UITextFieldViewModeAlways;
    tf.layer.borderWidth = 0.5;
    tf.layer.borderColor = [UIColor grayColor].CGColor;
    [tf addTarget:self action:@selector(endEdit) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:tf];
    
    btn_build = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_build.frame = CGRectMake(tf.frame.origin.x+tf.frame.size.width+3, y, BuilderButtonWidth, BuilderTextFieldHeight);
    btn_build.backgroundColor = [UIColor colorWithRed:1.000 green:0.319 blue:0.397 alpha:1.000];
    [btn_build setTitle:@"生成" forState:UIControlStateNormal];
    [btn_build addTarget:self action:@selector(gen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_build];
    
    y += BuilderTextFieldHeight;
    y += 10;

    iv = [[UIImageView alloc] init];
    iv.frame = CGRectMake(10, y, self.view.bounds.size.width-10*2, self.view.bounds.size.width-10*2);
    iv.backgroundColor = [UIColor colorWithRed:0.923 green:1.000 blue:0.942 alpha:1.000];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.layer.borderWidth = 0.5;
    iv.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view addSubview:iv];
    
    y += iv.bounds.size.height;
    y += 5;
    
    btn_clean = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_clean.frame = CGRectMake(iv.frame.origin.x, y, iv.frame.size.width*0.5, BuilderTextFieldHeight);
    btn_clean.backgroundColor = [UIColor colorWithRed:0.946 green:0.564 blue:1.000 alpha:1.000];
    [btn_clean setTitle:@"重置图片" forState:UIControlStateNormal];
    [btn_clean addTarget:self action:@selector(clean) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_clean];
    
    btn_save = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_save.frame = CGRectMake(btn_clean.frame.origin.x+btn_clean.frame.size.width,
                                y, iv.frame.size.width*0.5, BuilderTextFieldHeight);
    btn_save.backgroundColor = [UIColor colorWithRed:0.286 green:0.686 blue:1.000 alpha:1.000];
    [btn_save setTitle:@"保存到相册" forState:UIControlStateNormal];
    [btn_save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_save];
}

-(void)gen{
    [tf resignFirstResponder];
    iv.image = [self qrCodeImageWithString:tf.text];
}

-(void)clean{
    iv.image = nil;
}

-(void)save{
    if (iv.image) {
        UIImageWriteToSavedPhotosAlbum(iv.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"未发现二维码" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:error?@"保存失败":@"保存成功"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

-(void)endEdit{
    [self gen];
}

-(UIImage*)qrCodeImageWithString:(NSString*)str{
    if (str && [str isKindOfClass:[NSString class]] && str.length > 0) {
        return [self createNonInterpolatedUIImageFromCIImage:[self createQRForString:str]
                                                   withScale:2*[[UIScreen mainScreen] scale]];
    }
    return nil;
}

- (CIImage *)createQRForString:(NSString *)qrString
{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
