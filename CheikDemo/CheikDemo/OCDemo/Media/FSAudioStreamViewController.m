//
//  FSAudioStreamViewController.m
//  CheikDemo
//
//  Created by Cheik.chen on 16/5/17.
//  Copyright © 2016年 cheik. All rights reserved.
//

#import "FSAudioStreamViewController.h"
//#import "AFNetworking.h"
#import "FSAudioStream.h"

@interface FSAudioStreamViewController ()

@property (nonatomic,strong) FSAudioStream *audioStream;

@end

@implementation FSAudioStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= [UIColor grayColor];
      [self.audioStream play];
}

/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getFileUrl{
    NSString *urlStr=[[NSBundle mainBundle]pathForResource:@"原来你也在这里-刘若英.mp3" ofType:nil];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
-(NSURL *)getNetworkUrl{
    NSString *urlStr=@"http://183.6.240.140/file3.data.weipan.cn/77039907/66fb167c0be86ba2cbbc701d1847b7a2885ad4a7?ip=1463476558,183.62.222.129&ssig=bSQTM%2FnssY&Expires=1463478348&KID=sae,l30zoo1wmz&fn=%E5%8E%9F%E6%9D%A5%E4%BD%A0%E4%B9%9F%E5%9C%A8%E8%BF%99%E9%87%8C-%E5%88%98%E8%8B%A5%E8%8B%B1.mp3&skiprd=2&se_ip_debug=183.62.222.129&corp=2&from=1221134&wsiphost=local";
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

/**
 *  创建FSAudioStream对象
 *
 *  @return FSAudioStream对象
 */
-(FSAudioStream *)audioStream{
    if (!_audioStream) {
        NSURL *url=[self getNetworkUrl];
        //创建FSAudioStream对象
        _audioStream=[[FSAudioStream alloc]initWithUrl:url];
        _audioStream.onFailure=^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程中发生错误，错误信息：%@",description);
        };
        _audioStream.onCompletion=^(){
            NSLog(@"播放完成!");
        };
        [_audioStream setVolume:0.5];//设置声音
    }
    return _audioStream;
}


@end
