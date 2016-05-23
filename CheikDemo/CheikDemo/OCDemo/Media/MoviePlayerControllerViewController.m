//
//  MoviePlayerControllerViewController.m
//  CheikDemo
//
//  Created by Cheik.chen on 16/5/23.
//  Copyright © 2016年 cheik. All rights reserved.
//
/*
 MPMoviePlayerController
 在iOS中播放视频可以使用MediaPlayer.framework种的MPMoviePlayerController类来完成，它支持本地视频和网络视频播放。这个类实现了MPMediaPlayback协议，因此具备一般的播放器控制功能，例如播放、暂停、停止等。但是MPMediaPlayerController自身并不是一个完整的视图控制器，如果要在UI中展示视频需要将view属性添加到界面中。下面列出了MPMoviePlayerController的常用属性和方法：
 属性	说明
 @property (nonatomic, copy) NSURL *contentURL	播放媒体URL，这个URL可以是本地路径，也可以是网络路径
 @property (nonatomic, readonly) UIView *view	播放器视图，如果要显示视频必须将此视图添加到控制器视图中
 @property (nonatomic, readonly) UIView *backgroundView	播放器背景视图
 @property (nonatomic, readonly) MPMoviePlaybackState playbackState	媒体播放状态，枚举类型：
 MPMoviePlaybackStateStopped：停止播放
 MPMoviePlaybackStatePlaying：正在播放
 MPMoviePlaybackStatePaused：暂停
 MPMoviePlaybackStateInterrupted：中断
 MPMoviePlaybackStateSeekingForward：向前定位
 MPMoviePlaybackStateSeekingBackward：向后定位
 @property (nonatomic, readonly) MPMovieLoadState loadState	网络媒体加载状态，枚举类型：
 MPMovieLoadStateUnknown：位置类型
 MPMovieLoadStatePlayable：
 MPMovieLoadStatePlaythroughOK：这种状态如果shouldAutoPlay为YES将自动播放
 MPMovieLoadStateStalled：停滞状态
 @property (nonatomic) MPMovieControlStyle controlStyle	控制面板风格，枚举类型：
 MPMovieControlStyleNone：无控制面板
 MPMovieControlStyleEmbedded：嵌入视频风格
 MPMovieControlStyleFullscreen：全屏
 MPMovieControlStyleDefault：默认风格
 @property (nonatomic) MPMovieRepeatMode repeatMode;	重复播放模式，枚举类型:
 MPMovieRepeatModeNone:不重复，默认值
 MPMovieRepeatModeOne:重复播放
 @property (nonatomic) BOOL shouldAutoplay	当网络媒体缓存到一定数据时是否自动播放，默认为YES
 @property (nonatomic, getter=isFullscreen) BOOL fullscreen	是否全屏展示，默认为NO，注意如果要通过此属性设置全屏必须在视图显示完成后设置，否则无效
 @property (nonatomic) MPMovieScalingMode scalingMode	视频缩放填充模式，枚举类型：
 MPMovieScalingModeNone：不进行任何缩放
 MPMovieScalingModeAspectFit：固定缩放比例并且尽量全部展示视频，不会裁切视频
 MPMovieScalingModeAspectFill：固定缩放比例并填充满整个视图展示，可能会裁切视频
 MPMovieScalingModeFill：不固定缩放比例压缩填充整个视图，视频不会被裁切但是比例失衡
 @property (nonatomic, readonly) BOOL readyForDisplay	是否有相关媒体被播放
 @property (nonatomic, readonly) MPMovieMediaTypeMask movieMediaTypes	媒体类别，枚举类型：
 MPMovieMediaTypeMaskNone：未知类型
 MPMovieMediaTypeMaskVideo：视频
 MPMovieMediaTypeMaskAudio：音频
 @property (nonatomic) MPMovieSourceType movieSourceType	媒体源，枚举类型：
 MPMovieSourceTypeUnknown：未知来源
 MPMovieSourceTypeFile：本地文件
 MPMovieSourceTypeStreaming：流媒体（直播或点播）
 @property (nonatomic, readonly) NSTimeInterval duration	媒体时长，如果未知则返回0
 @property (nonatomic, readonly) NSTimeInterval playableDuration	媒体可播放时长，主要用于表示网络媒体已下载视频时长
 @property (nonatomic, readonly) CGSize naturalSize	视频实际尺寸，如果未知则返回CGSizeZero
 @property (nonatomic) NSTimeInterval initialPlaybackTime	起始播放时间
 @property (nonatomic) NSTimeInterval endPlaybackTime	终止播放时间
 @property (nonatomic) BOOL allowsAirPlay	是否允许无线播放，默认为YES
 @property (nonatomic, readonly, getter=isAirPlayVideoActive) BOOL airPlayVideoActive	当前媒体是否正在通过AirPlay播放
 @property(nonatomic, readonly) BOOL isPreparedToPlay	是否准备好播放
 @property(nonatomic) NSTimeInterval currentPlaybackTime	当前播放时间，单位：秒
 @property(nonatomic) float currentPlaybackRate	当前播放速度，如果暂停则为0，正常速度为1.0，非0数据表示倍率
 对象方法	说明
 - (instancetype)initWithContentURL:(NSURL *)url	使用指定的URL初始化媒体播放控制器对象
 - (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated	设置视频全屏，注意如果要通过此方法设置全屏则必须在其视图显示之后设置，否则无效
 - (void)requestThumbnailImagesAtTimes:(NSArray *)playbackTimes timeOption:(MPMovieTimeOption)option	获取在指定播放时间的视频缩略图，第一个参数是获取缩略图的时间点数组；第二个参数代表时间点精度，枚举类型：
 MPMovieTimeOptionNearestKeyFrame：时间点附近
 MPMovieTimeOptionExact：准确时间
 - (void)cancelAllThumbnailImageRequests	取消所有缩略图获取请求
 - (void)prepareToPlay	准备播放，加载视频数据到缓存，当调用play方法时如果没有准备好会自动调用此方法
 - (void)play	开始播放
 - (void)pause	暂停播放
 - (void)stop	停止播放
 - (void)beginSeekingForward	向前定位
 - (void)beginSeekingBackward	向后定位
 - (void)endSeeking	停止快进/快退
 通知	说明
 MPMoviePlayerScalingModeDidChangeNotification	视频缩放填充模式发生改变
 MPMoviePlayerPlaybackDidFinishNotification	媒体播放完成或用户手动退出，具体完成原因可以通过通知userInfo中的key为MPMoviePlayerPlaybackDidFinishReasonUserInfoKey的对象获取
 MPMoviePlayerPlaybackStateDidChangeNotification	播放状态改变，可配合playbakcState属性获取具体状态
 MPMoviePlayerLoadStateDidChangeNotification	媒体网络加载状态改变
 MPMoviePlayerNowPlayingMovieDidChangeNotification	当前播放的媒体内容发生改变
 MPMoviePlayerWillEnterFullscreenNotification	将要进入全屏
 MPMoviePlayerDidEnterFullscreenNotification	进入全屏后
 MPMoviePlayerWillExitFullscreenNotification	将要退出全屏
 MPMoviePlayerDidExitFullscreenNotification	退出全屏后
 MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification	当媒体开始通过AirPlay播放或者结束AirPlay播放
 MPMoviePlayerReadyForDisplayDidChangeNotification	视频显示状态改变
 MPMovieMediaTypesAvailableNotification	确定了媒体可用类型后
 MPMovieSourceTypeAvailableNotification	确定了媒体来源后
 MPMovieDurationAvailableNotification	确定了媒体播放时长后
 MPMovieNaturalSizeAvailableNotification	确定了媒体的实际尺寸后
 MPMoviePlayerThumbnailImageRequestDidFinishNotification	缩略图请求完成之后
 MPMediaPlaybackIsPreparedToPlayDidChangeNotification	做好播放准备后
 注意MPMediaPlayerController的状态等信息并不是通过代理来和外界交互的，而是通过通知中心，因此从上面的列表中可以看到常用的一些通知。由于MPMoviePlayerController本身对于媒体播放做了深度的封装，使用起来就相当简单：创建MPMoviePlayerController对象，设置frame属性，将MPMoviePlayerController的view添加到控制器视图中。
 */
#import "MoviePlayerControllerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface MoviePlayerControllerViewController ()
    
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器


@end

@implementation MoviePlayerControllerViewController


#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //播放
    [self.moviePlayer play];
    
    //添加通知
    [self addNotification];
    
}

-(void)dealloc{
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 私有方法
/**
 *  取得本地文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getFileUrl{
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"小视屏.mp4" ofType:nil];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

/**
 *  取得网络文件路径
 *
 *  @return 文件路径
 */
-(NSURL *)getNetworkUrl{
    NSString *urlStr=@"http://192.168.1.161/The New Look of OS X Yosemite.mp4";
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlStr];
    return url;
}

/**
 *  创建媒体播放控制器
 *
 *  @return 媒体播放控制器
 */
-(MPMoviePlayerController *)moviePlayer{
    if (!_moviePlayer) {
        NSURL *url=[self getFileUrl];
        _moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
        _moviePlayer.view.frame=self.view.bounds;
        _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_moviePlayer.view];
    }
    return _moviePlayer;
}

/**
 *  添加通知监控媒体播放控制器状态
 */
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    
}

/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停播放.");
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止播放.");
            break;
        default:
            NSLog(@"播放状态:%li",self.moviePlayer.playbackState);
            break;
    }
}

/**
 *  播放完成
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{
    NSLog(@"播放完成.%li",self.moviePlayer.playbackState);
}


@end
