//
//  MediaViewController.m
//  CheikDemo
//
//  Created by Cheik.chen on 16/5/17.
//  Copyright © 2016年 cheik. All rights reserved.
//

#import "MediaTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MusicViewController.h"
#import "RecordViewController.h"
#import "FSAudioStreamViewController.h"
#import "MoviePlayerControllerViewController.h"
@interface MediaTableViewController ()
{
    NSMutableArray *dataArray_;
}

@end

@implementation MediaTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray_ = [NSMutableArray array];
    [self getData];
    [self.tableView reloadData];
}
-(void)getData{
    
    [dataArray_ addObject:@"音效"];
    [dataArray_ addObject:@"音乐"];
    [dataArray_ addObject:@"录音"];
    [dataArray_ addObject:@"音频队列服务"];
    [dataArray_ addObject:@"视频-MPMoviePlayerController"];
    [dataArray_ addObject:@"视频-MPMoviePlayerViewController"];
    [dataArray_ addObject:@"视频-AVPlayer"];
    [dataArray_ addObject:@"摄像头-UIImagePickerController拍照和视频录制"];
    [dataArray_ addObject:@"摄像头-AVFoundation拍照和录制视频"];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataArray_.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" ];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = dataArray_[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            [self playSoundEffect:@"up.wav"];
        }
            break;
        case 1:
        {
            MusicViewController *music = [[MusicViewController alloc]init];
            [self.navigationController pushViewController:music animated:YES];
        }
            break;
        case 2:
        {
            RecordViewController *record = [[RecordViewController alloc]init];
            [self.navigationController pushViewController:record animated:YES];
        }
            break;
        case 3:
        {
            FSAudioStreamViewController *fsa = [[FSAudioStreamViewController alloc]init];
            [self.navigationController pushViewController:fsa animated:YES];
        }
            break;
        case 4:
        {
            MoviePlayerControllerViewController *mpVC = [[MoviePlayerControllerViewController alloc]init];
            [self.navigationController pushViewController:mpVC animated:YES];
        }
            break;
        case 5:
        {
            
        }
            break;
        case 6:
        {
            
        }
            break;
        case 7:
        {
            
        }
            break;
        default:
            break;
    }
}
#pragma mark - 音效
/**
 *  播放音乐文件
 *
 *  @param name 音乐文件的名称
 */
-(void)playSoundEffect:(NSString *)name{
    
    //1,获取音乐地址
    NSString *audioFile = [[NSBundle mainBundle]pathForResource:name ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:audioFile];
    
    //2,获得系统声音ID
    SystemSoundID soundID = 0;
    /**
     *  inFileUrl:音频文件url
     outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileURL), &soundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);

    //3.播放音频
//    AudioServicesPlaySystemSound(soundID);//播放音效
        AudioServicesPlayAlertSound(soundID);//播放音效并震动
}

/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}
@end
