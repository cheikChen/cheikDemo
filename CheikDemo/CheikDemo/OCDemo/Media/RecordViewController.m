//
//  RecordViewController.m
//  CheikDemo
//
//  Created by Cheik.chen on 16/5/17.
//  Copyright © 2016年 cheik. All rights reserved.
//
/*
 录音
 除了上面说的，在AVFoundation框架中还要一个AVAudioRecorder类专门处理录音操作，它同样支持多种音频格式。与AVAudioPlayer类似，你完全可以将它看成是一个录音机控制类，下面是常用的属性和方法：
 属性	说明
 @property(readonly, getter=isRecording) BOOL recording;	是否正在录音，只读
 @property(readonly) NSURL *url	录音文件地址，只读
 @property(readonly) NSDictionary *settings	录音文件设置，只读
 @property(readonly) NSTimeInterval currentTime	录音时长，只读，注意仅仅在录音状态可用
 @property(readonly) NSTimeInterval deviceCurrentTime	输入设置的时间长度，只读，注意此属性一直可访问
 @property(getter=isMeteringEnabled) BOOL meteringEnabled;	是否启用录音测量，如果启用录音测量可以获得录音分贝等数据信息
 @property(nonatomic, copy) NSArray *channelAssignments	当前录音的通道
 对象方法	说明
 - (instancetype)initWithURL:(NSURL *)url settings:(NSDictionary *)settings error:(NSError **)outError	录音机对象初始化方法，注意其中的url必须是本地文件url，settings是录音格式、编码等设置
 - (BOOL)prepareToRecord	准备录音，主要用于创建缓冲区，如果不手动调用，在调用record录音时也会自动调用
 - (BOOL)record	开始录音
 - (BOOL)recordAtTime:(NSTimeInterval)time	在指定的时间开始录音，一般用于录音暂停再恢复录音
 - (BOOL)recordForDuration:(NSTimeInterval) duration	按指定的时长开始录音
 - (BOOL)recordAtTime:(NSTimeInterval)time forDuration:(NSTimeInterval) duration	在指定的时间开始录音，并指定录音时长
 - (void)pause;	暂停录音
 - (void)stop;	停止录音
 - (BOOL)deleteRecording;	删除录音，注意要删除录音此时录音机必须处于停止状态
 - (void)updateMeters;	更新测量数据，注意只有meteringEnabled为YES此方法才可用
 - (float)peakPowerForChannel:(NSUInteger)channelNumber;	指定通道的测量峰值，注意只有调用完updateMeters才有值
 - (float)averagePowerForChannel:(NSUInteger)channelNumber	指定通道的测量平均值，注意只有调用完updateMeters才有值
 代理方法	说明
 - (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag	完成录音
 - (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error	录音编码发生错误
 AVAudioRecorder很多属性和方法跟AVAudioPlayer都是类似的,但是它的创建有所不同，在创建录音机时除了指定路径外还必须指定录音设置信息，因为录音机必须知道录音文件的格式、采样率、通道数、每个采样点的位数等信息，但是也并不是所有的信息都必须设置，通常只需要几个常用设置。关于录音设置详见帮助文档中的“AV Foundation Audio Settings Constants”。
 下面就使用AVAudioRecorder创建一个录音机，实现了录音、暂停、停止、播放等功能，
 */

/*=====================================================*/
/*
 自动播放录音文件。程序的构建主要分为以下几步：
 设置音频会话类型为AVAudioSessionCategoryPlayAndRecord，因为程序中牵扯到录音和播放操作。
 创建录音机AVAudioRecorder，指定录音保存的路径并且设置录音属性，注意对于一般的录音文件要求的采样率、位数并不高，需要适当设置以保证录音文件的大小和效果。
 设置录音机代理以便在录音完成后播放录音，打开录音测量保证能够实时获得录音时的声音强度。（注意声音强度范围-160到0,0代表最大输入）
 创建音频播放器AVAudioPlayer，用于在录音完成之后播放录音。
 创建一个定时器以便实时刷新录音测量值并更新录音强度到UIProgressView中显示。
 添加录音、暂停、恢复、停止操作，需要注意录音的恢复操作其实是有音频会话管理的，恢复时只要再次调用record方法即可，无需手动管理恢复时间等。
 */

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"

@interface RecordViewController ()<AVAudioRecorderDelegate>
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@property (strong, nonatomic)  UIButton *record;//开始录音
@property (strong, nonatomic)  UIButton *pause;//暂停录音
@property (strong, nonatomic)  UIButton *resume;//恢复录音
@property (strong, nonatomic)  UIButton *stop;//停止录音
@property (strong, nonatomic)  UIProgressView *audioPower;//音频波动
@property (nonatomic, strong)  UIImageView *backImageView;//背景图片
@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backImageView];
    [self.view addSubview:self.audioPower];
    [self.view addSubview:self.record];
    [self.view addSubview:self.pause];
    [self.view addSubview:self.resume];
    [self.view addSubview:self.stop];
    
    [self setAudioSession];
}
-(void)btnClick:(UIButton *)sender{

    switch (sender.tag) {
        case 1:
        {
            if (![self.audioRecorder isRecording]) {
                [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
                self.timer.fireDate=[NSDate distantPast];
            }
        }
            break;
        case 2:
        {
            if ([self.audioRecorder isRecording]) {
                [self.audioRecorder pause];
                self.timer.fireDate=[NSDate distantFuture];
            }
        }
            break;
        case 3:
        {
            if (![self.audioRecorder isRecording]) {
                [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
                self.timer.fireDate=[NSDate distantPast];
            }
        }
            break;
        case 4:
        {
            [self.audioRecorder stop];
            self.timer.fireDate=[NSDate distantFuture];
            self.audioPower.progress=0.0;
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 私有方法
/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    [self.audioPower setProgress:progress];
}
#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
    NSLog(@"录音完成!");
}
#pragma mark -- 懒加载控件
-(UIImageView *)backImageView{
    if(!_backImageView){
        _backImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _backImageView.image = [UIImage imageNamed:@"lyjbjt"];
    }
    return _backImageView;
}
-(UIProgressView *)audioPower{
    if(!_audioPower){
        _audioPower = [[UIProgressView alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height/2, self.view.frame.size.width-20, 20)];
    }
    return _audioPower;
}
-(UIButton *)record{
    if(!_record){
        _record = [UIButton buttonWithType:UIButtonTypeCustom];
        _record.frame = CGRectMake((self.view.frame.size.width-52*4)/5, self.view.frame.size.height-100, 52, 52);
        _record.tag = 1;
        [_record setImage:[UIImage imageNamed:@"lyj_lyan"] forState:UIControlStateNormal];
        [_record addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _record;
}
-(UIButton *)pause{
    if(!_pause){
        _pause = [UIButton buttonWithType:UIButtonTypeCustom];
        _pause.frame = CGRectMake(((self.view.frame.size.width-52*4)/5)*2+52, self.view.frame.size.height-100, 52, 52);
        _pause.tag = 2;
        [_pause setImage:[UIImage imageNamed:@"lyj_atan"] forState:UIControlStateNormal];
        [_pause addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pause;
}
-(UIButton *)resume{
    if(!_resume){
        _resume = [UIButton buttonWithType:UIButtonTypeCustom];
        _resume.frame = CGRectMake(((self.view.frame.size.width-52*4)/5)*3+52*2, self.view.frame.size.height-100, 52, 52);
        _resume.tag = 3;
        [_resume setImage:[UIImage imageNamed:@"lyj_bfq_bfan"] forState:UIControlStateNormal];
        [_resume addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resume;
}
-(UIButton *)stop{
    if(!_stop){
        _stop = [UIButton buttonWithType:UIButtonTypeCustom];
        _stop.frame = CGRectMake(((self.view.frame.size.width-52*4)/5)*4+52*3, self.view.frame.size.height-100, 52, 52);
        _stop.tag = 4;
        [_stop setImage:[UIImage imageNamed:@"lyj_tian"] forState:UIControlStateNormal];
        [_stop addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stop;
}

@end
