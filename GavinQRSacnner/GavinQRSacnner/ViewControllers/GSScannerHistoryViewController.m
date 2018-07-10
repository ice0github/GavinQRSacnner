//
//  GSScannerHistoryViewController.m
//  GavinQRSacnner
//
//  Created by 何桂强 on 15/5/14.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "GSScannerHistoryViewController.h"
#import <SafariServices/SafariServices.h>

#import "GSScannerHistoryManager.h"
#import "GSSetting.h"

@interface GSScannerHistoryViewController ()<UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate>{
    UITableView *tb;
    
    UIView *detailView;
    UIView *detailBG;
    UITextView *tv;
    NSIndexPath *lastSelected;
    
    SFSafariViewController *sfWebVC;
}

@end

@implementation GSScannerHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildUI];
}

-(void)buildUI{
    self.title = @"历史记录";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.000];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(cleanHistory)];
    self.navigationItem.rightBarButtonItem = item2;
    
    [self.view addSubview:[[UIView alloc] init]];

    tb = [[UITableView alloc] init];
    tb.frame = CGRectMake(0, 20+44, self.view.frame.size.width, self.view.frame.size.height-20-44);
    tb.delegate = self;
    tb.dataSource = self;
    [self.view addSubview:tb];
    
    
    detailBG = [[UIView alloc] init];
    detailBG.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5];
    detailBG.frame = tb.frame;
    [self.view addSubview:detailBG];
    
    detailView = [[UIView alloc] init];
    detailView.frame = CGRectMake(20, (self.view.frame.size.height-160)*0.5, self.view.frame.size.width-20*2, 160);
    detailView.backgroundColor = [UIColor whiteColor];
    detailView.layer.cornerRadius = 8;
    detailView.layer.masksToBounds = YES;
    [self.view addSubview:detailView];
    
    tv = [[UITextView alloc] init];
    tv.frame = CGRectMake(10, 10, detailView.bounds.size.width-10*2, 100);
    tv.editable = NO;
    tv.font = [UIFont systemFontOfSize:16];
    tv.backgroundColor = [UIColor colorWithRed:0.904 green:1.000 blue:0.923 alpha:1.000];
    tv.layer.borderWidth = 0.5;
    tv.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [detailView addSubview:tv];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, tv.frame.size.height+tv.frame.origin.y+10, detailView.bounds.size.width, 44);
    [detailView addSubview:toolbar];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismissDetailView)];
    cancelItem.width = 90;
    
    UIBarButtonItem *openItem = [[UIBarButtonItem alloc] initWithTitle:@"打开" style:UIBarButtonItemStyleDone target:self action:@selector(openHistory)];
    openItem.width = 90;
    
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithTitle:@"复制" style:UIBarButtonItemStyleDone target:self action:@selector(copyHistory)];
    copyItem.width = 90;
    
    toolbar.items = @[cancelItem,fixed,openItem,fixed,copyItem];

    detailBG.alpha = 0;
    detailView.alpha = 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return HistoryManager.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistoryCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = HistoryManager.history[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [HistoryManager removeHistoryAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    tv.text = HistoryManager.history[indexPath.row];
    [self showDetailView];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller{
    [sfWebVC dismissViewControllerAnimated:YES completion:^{
        sfWebVC = nil;
    }];
}

-(void)copyHistory{
    NSString *text = tv.text;
    [self dismissDetailView];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"目标链接已复制到粘贴板"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

-(void)openHistory{
    NSString *text = tv.text;
    [self dismissDetailView];
    
    NSURL *targetUrl = [NSURL URLWithString:text];
   
    if (targetUrl){
        NSString *tmp = [targetUrl.absoluteString lowercaseString];
        if (tmp && ([tmp hasPrefix:@"http://"] || [tmp hasPrefix:@"https://"])){
            if (![self goToChrome:targetUrl]) {
                sfWebVC = [[SFSafariViewController alloc] initWithURL:targetUrl];
                sfWebVC.delegate = self;
                [self presentViewController:sfWebVC animated:YES completion:nil];
            }
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"只支持打开http和https协议的URL"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (BOOL)goToChrome:(NSURL*)inputURL{
    if (![GSSetting setting].openURLByChromeAtFirst){
        return NO;
    }
    
    NSString *scheme = inputURL.scheme?[inputURL.scheme lowercaseString]:@"";
    
    // Replace the URL Scheme with the Chrome equivalent.
    NSString *chromeScheme = nil;
    if ([scheme isEqualToString:@"http"]) {
        chromeScheme = @"googlechrome";
    } else if ([scheme isEqualToString:@"https"]) {
        chromeScheme = @"googlechromes";
    }
    
    // Proceed only if a valid Google Chrome URI Scheme is available.
    if (chromeScheme) {
        NSString *absoluteString = [inputURL absoluteString];
        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
        NSString *urlNoScheme =
        [absoluteString substringFromIndex:rangeForScheme.location];
        NSString *chromeURLString = [chromeScheme stringByAppendingString:urlNoScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
        
        // Open the URL with Chrome.
        if ([[UIApplication sharedApplication] canOpenURL:chromeURL]) {
            [[UIApplication sharedApplication] openURL:chromeURL options:@{} completionHandler:^(BOOL success) {
                
            }];
            return YES;
        }
    }
    return NO;
}

-(void)cleanHistory{
    [HistoryManager cleanHistory];
    [tb reloadData];
}

-(void)showDetailView{
    [UIView animateWithDuration:0.3 animations:^{
        detailView.alpha = 1;
        detailBG.alpha = 1;
    }];
}

-(void)dismissDetailView{
    [UIView animateWithDuration:0.3 animations:^{
        tv.text = nil;
        detailBG.alpha = 0;
        detailView.alpha = 0;
    }];

}


-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
