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
@interface MediaTableViewController ()
{
    NSMutableArray *dataArray_;
}

@end

@implementation MediaTableViewController
/*
 音频
 在iOS中音频播放从形式上可以分为音效播放和音乐播放。前者主要指的是一些短音频播放，通常作为点缀音频，对于这类音频不需要进行进度、循环等控制。后者指的是一些较长的音频，通常是主音频，对于这些音频的播放通常需要进行精确的控制。在iOS中播放两类音频分别使用AudioToolbox.framework和AVFoundation.framework来完成音效和音乐播放。
 音效
 AudioToolbox.framework是一套基于C语言的框架，使用它来播放音效其本质是将短音频注册到系统声音服务（System Sound Service）。System Sound Service是一种简单、底层的声音播放服务，但是它本身也存在着一些限制：
 音频播放时间不能超过30s
 数据必须是PCM或者IMA4格式
 音频文件必须打包成.caf、.aif、.wav中的一种（注意这是官方文档的说法，实际测试发现一些.mp3也可以播放）
 使用System Sound Service 播放音效的步骤如下：
 调用AudioServicesCreateSystemSoundID(   CFURLRef  inFileURL, SystemSoundID*   outSystemSoundID)函数获得系统声音ID。
 如果需要监听播放完成操作，则使用AudioServicesAddSystemSoundCompletion(  SystemSoundID inSystemSoundID,
 CFRunLoopRef  inRunLoop, CFStringRef  inRunLoopMode, AudioServicesSystemSoundCompletionProc  inCompletionRoutine, void*  inClientData)方法注册回调函数。
 调用AudioServicesPlaySystemSound(SystemSoundID inSystemSoundID) 或者AudioServicesPlayAlertSound(SystemSoundID inSystemSoundID) 方法播放音效（后者带有震动效果）。
 */

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
