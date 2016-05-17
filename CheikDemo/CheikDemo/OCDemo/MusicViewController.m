//
//  MusicViewController.m
//  CheikDemo
//
//  Created by Cheik.chen on 16/5/17.
//  Copyright © 2016年 cheik. All rights reserved.
//

#import "MusicViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kMusicFile @"原来你也在这里-刘若英.mp3"
#define kMusicSinger @"刘若英"
#define kMusicTitle @"原来你也在这里"

@interface MusicViewController ()<AVAudioPlayerDelegate>
@property (nonatomic,strong)UIImageView *backImageView;//背景图片
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//播放器
@property (strong, nonatomic) UILabel *controlPanel; //控制面板
@property (strong, nonatomic) UIProgressView *playProgress;//播放进度
@property (strong, nonatomic) UILabel *musicSinger; //演唱者
@property (strong, nonatomic) UIButton *playOrPause; //播放/暂停按钮(如果tag为0认为是暂停状态，1是播放状态)

@property (weak ,nonatomic) NSTimer *timer;//进度更新定时器
@end

@implementation MusicViewController
/*
 音乐
 如果播放较大的音频或者要对音频有精确的控制则System Sound Service可能就很难满足实际需求了，通常这种情况会选择使用AVFoundation.framework中的AVAudioPlayer来实现。AVAudioPlayer可以看成一个播放器，它支持多种音频格式，而且能够进行进度、音量、播放速度等控制。首先简单看一下AVAudioPlayer常用的属性和方法：
 属性	说明
 @property(readonly, getter=isPlaying) BOOL playing	是否正在播放，只读
 @property(readonly) NSUInteger numberOfChannels	音频声道数，只读
 @property(readonly) NSTimeInterval duration	音频时长
 @property(readonly) NSURL *url	音频文件路径，只读
 @property(readonly) NSData *data	音频数据，只读
 @property float pan	立体声平衡，如果为-1.0则完全左声道，如果0.0则左右声道平衡，如果为1.0则完全为右声道
 @property float volume	音量大小，范围0-1.0
 @property BOOL enableRate	是否允许改变播放速率
 @property float rate	播放速率，范围0.5-2.0，如果为1.0则正常播放，如果要修改播放速率则必须设置enableRate为YES
 @property NSTimeInterval currentTime	当前播放时长
 @property(readonly) NSTimeInterval deviceCurrentTime	输出设备播放音频的时间，注意如果播放中被暂停此时间也会继续累加
 @property NSInteger numberOfLoops	循环播放次数，如果为0则不循环，如果小于0则无限循环，大于0则表示循环次数
 @property(readonly) NSDictionary *settings	音频播放设置信息，只读
 @property(getter=isMeteringEnabled) BOOL meteringEnabled	是否启用音频测量，默认为NO，一旦启用音频测量可以通过updateMeters方法更新测量值
 对象方法	说明
 - (instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError **)outError	使用文件URL初始化播放器，注意这个URL不能是HTTP URL，AVAudioPlayer不支持加载网络媒体流，只能播放本地文件
 - (instancetype)initWithData:(NSData *)data error:(NSError **)outError	使用NSData初始化播放器，注意使用此方法时必须文件格式和文件后缀一致，否则出错，所以相比此方法更推荐使用上述方法或- (instancetype)initWithData:(NSData *)data fileTypeHint:(NSString *)utiString error:(NSError **)outError方法进行初始化
 - (BOOL)prepareToPlay;	加载音频文件到缓冲区，注意即使在播放之前音频文件没有加载到缓冲区程序也会隐式调用此方法。
 - (BOOL)play;	播放音频文件
 - (BOOL)playAtTime:(NSTimeInterval)time	在指定的时间开始播放音频
 - (void)pause;	暂停播放
 - (void)stop;	停止播放
 - (void)updateMeters	更新音频测量值，注意如果要更新音频测量值必须设置meteringEnabled为YES，通过音频测量值可以即时获得音频分贝等信息
 - (float)peakPowerForChannel:(NSUInteger)channelNumber;	获得指定声道的分贝峰值，注意如果要获得分贝峰值必须在此之前调用updateMeters方法
 - (float)averagePowerForChannel:(NSUInteger)channelNumber	获得指定声道的分贝平均值，注意如果要获得分贝平均值必须在此之前调用updateMeters方法
 @property(nonatomic, copy) NSArray *channelAssignments	获得或设置播放声道
 代理方法	说明
 - (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag	音频播放完成
 - (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error	音频解码发生错误
 AVAudioPlayer的使用比较简单：
 初始化AVAudioPlayer对象，此时通常指定本地文件路径。
 设置播放器属性，例如重复次数、音量大小等。
 调用play方法播放。
 */

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //开启远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //离开页面关闭播放
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [_audioPlayer stop];
    _audioPlayer = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
/**
 *  初始化UI
 */
-(void)setupUI{
    self.title=kMusicTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backImageView];
    [self.view addSubview:self.controlPanel];
    [self.view addSubview:self.musicSinger];
    [self.view addSubview:self.playProgress];
    [self.view addSubview:self.playOrPause];
}
-(UIImageView *)backImageView{
    if(!_backImageView){
        _backImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _backImageView.image = [UIImage imageNamed:@"Ren'eLiu.jpg"];
    }
    return _backImageView;
}
-(UILabel *)controlPanel{
    if(!_controlPanel){
        _controlPanel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/3*2, self.view.frame.size.height, self.view.frame.size.height/3)];
        _controlPanel.alpha = 0.8;
        _controlPanel.backgroundColor = [UIColor grayColor];
    }
    return _controlPanel;
}
-(UILabel *)musicSinger{
    if(!_musicSinger){
        _musicSinger = [[UILabel alloc]initWithFrame:CGRectMake(10, _controlPanel.frame.origin.y+10, 200, 30)];
        _musicSinger.text = kMusicSinger;
        _musicSinger.textColor = [UIColor whiteColor];
    }
    return _musicSinger;
}
-(UIProgressView *)playProgress{
    if(!_playProgress){
        _playProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(10, self.musicSinger.frame.origin.y+50, self.view.frame.size.width-20, 20)];
    }
    return _playProgress;
}
-(UIButton *)playOrPause{
    if(!_playOrPause){
        _playOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPause.frame = CGRectMake(self.view.frame.size.width/2-30, self.playProgress.frame.origin.y+50, 65, 65);
        [_playOrPause setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [_playOrPause setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
        [_playOrPause addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPause;
}
-(void)btnClick:(UIButton *)sender{

    if(sender.tag){
//        sender.tag=0;
//        [sender setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
//        [sender setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
        [self pause];
    }else{
//        sender.tag=1;
//        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
//        [sender setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];
        [self play];
    }
}
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
}
/**
 *  更新播放进度
 */
-(void)updateProgress{
    float progress= self.audioPlayer.currentTime /self.audioPlayer.duration;
    [self.playProgress setProgress:progress animated:true];
}

/**
 *  创建播放器
 *
 *  @return 音频播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSString *urlStr=[[NSBundle mainBundle]pathForResource:kMusicFile ofType:nil];
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        _audioPlayer.numberOfLoops=0;//设置为0不循环
        _audioPlayer.delegate=self;
        [_audioPlayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
        
        //设置后台播放模式
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//                [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [audioSession setActive:YES error:nil];
        //添加通知，拔出耳机后暂停播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    }
    return _audioPlayer;
}
/**
 *  播放音频
 */
-(void)play{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
        self.timer.fireDate=[NSDate distantPast];//恢复定时器
        _playOrPause.tag=1;
        [_playOrPause setImage:[UIImage imageNamed:@"playing_btn_pause_n"] forState:UIControlStateNormal];
        [_playOrPause setImage:[UIImage imageNamed:@"playing_btn_pause_h"] forState:UIControlStateHighlighted];

    }
}

/**
 *  暂停播放
 */
-(void)pause{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
        self.timer.fireDate=[NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        _playOrPause.tag=0;
        [_playOrPause setImage:[UIImage imageNamed:@"playing_btn_play_n"] forState:UIControlStateNormal];
        [_playOrPause setImage:[UIImage imageNamed:@"playing_btn_play_h"] forState:UIControlStateHighlighted];
    }
}
/**
 *  一旦输出改变则执行此方法
 *
 *  @param notification 输出改变通知对象
 */
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            [self pause];
        }
    }
    
    //    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    //        NSLog(@"%@:%@",key,obj);
    //    }];
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
    //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
    [[AVAudioSession sharedInstance]setActive:NO error:nil];
}

@end
