//
//  OCDemoTableViewController.m
//  CheikDemo
//
//  Created by Cheik.chen on 16/5/17.
//  Copyright © 2016年 cheik. All rights reserved.
//

#import "OCDemoTableViewController.h"
#import "MediaTableViewController.h"

@interface OCDemoTableViewController ()
{
    NSMutableArray *dataArray_;
}
@end

@implementation OCDemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray_ = [NSMutableArray array];
    [self getData];
    [self.tableView reloadData];
}
-(void)getData{
    
    [dataArray_ addObject:@"音频播放、录音、视频播放、拍照、视频录制"];
    [dataArray_ addObject:@"OCdemo"];
    [dataArray_ addObject:@"Switf语法"];
    [dataArray_ addObject:@"SwiftDemo"];
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
            MediaTableViewController *media = [[MediaTableViewController alloc]init];
            [self.navigationController pushViewController:media animated:YES];
        }
        break;
            
        default:
            break;
    }
}

@end
