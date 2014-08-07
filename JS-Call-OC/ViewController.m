//
//  ViewController.m
//  JS-Call-OC
//
//  Created by Jakey on 14-8-6.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self reload:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reload:(id)sender {
    //传输
    //NSString *temp = @"测试以下";
    //NSString *encodestring = [self encodeString:temp];
    //NSLog(@"encodestring%@",encodestring);
    //NSLog(@"decodestring%@",[self decodeString:encodestring]);
    [self loadHtml:@"demo"];
}

#pragma mark --
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *requestString = [[[request URL]  absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    if ([requestString hasPrefix:@"myapp:"]) {
        NSLog(@"requestString:%@",requestString);
        //如果是自己定义的协议, 再截取协议中的方法和参数, 判断无误后在这里手动调用oc方法
        NSMutableDictionary *param = [self queryStringToDictionary:requestString];
        NSLog(@"get param:%@",[param description]);

        NSString *func = [param objectForKey:@"func"];
        
        //调用本地函数1
        if([func isEqualToString:@"addSubView"])
        {
            Class tempClass =  NSClassFromString([param objectForKey:@"view"]);
            CGRect frame = CGRectFromString([param objectForKey:@"frame"]);
            
            if(tempClass && [tempClass isSubclassOfClass:[UIWebView class]])
            {
                UIWebView *tempObj = [[tempClass alloc] initWithFrame:frame];
                tempObj.tag = [[param objectForKey:@"tag"] integerValue];
                
                NSURL *url = [NSURL URLWithString:[param objectForKey:@"urlstring"]];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [tempObj loadRequest:request];
                [self.view addSubview:tempObj];
            }
        }
        //调用本地函数2
        else if([func isEqualToString:@"alert"])
        {
            [self showMessage:@"来自网页的提示" message:[param objectForKey:@"message"]];
            
        }
        //调用本地函数3
        else if([func isEqualToString:@"callFunc"])
        {
            [self testFunc:[param objectForKey:@"first"] withParam2:[param objectForKey:@"second"]  andParam3:[param objectForKey:@"third"] ];
            
        }
        //调用本地函数4
        else if([func isEqualToString:@"testFunc"])
        {
            [self testFunc:[param objectForKey:@"param1"] withParam2:[param objectForKey:@"param2"]  andParam3:[param objectForKey:@"param3"] ];
  
        }
        
        
        
    }
    return YES;
}
-(void)testFunc:(NSString*)param1 withParam2:(NSString*)param2 andParam3:(NSString*)param3{
    NSLog(@"%@ %@ %@",param1,param2,param3);
}



-(void)loadWebView:(NSString*)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:request];
}

-(void)loadHtml:(NSString*)name{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:name ofType:@"html"];
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.myWebView loadRequest:request];
}

-(void)showMessage:(NSString *)title message:(NSString *)message;
{
    if (message == nil)
    {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}
//get参数转字典
- (NSMutableDictionary*)queryStringToDictionary:(NSString*)string {
    NSMutableArray *elements = (NSMutableArray*)[string componentsSeparatedByString:@"&"];
    [elements removeObjectAtIndex:0];
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:[elements count]];
    for(NSString *e in elements) {
        NSArray *pair = [e componentsSeparatedByString:@"="];
        [retval setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
    }
    return retval;
}
//URLEncode
-(NSString*)encodeString:(NSString*)unencodedString{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}
//URLDEcode
-(NSString *)decodeString:(NSString*)encodedString

{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];

    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}
@end
