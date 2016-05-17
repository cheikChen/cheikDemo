//
//  OCDemoTableViewController.m
//  CheikDemo
//
//  Created by Cheik.chen on 16/5/17.
//  Copyright © 2016年 cheik. All rights reserved.
//

#import "OCDemoTableViewController.h"

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
    
    [dataArray_ addObject:@"OC语法"];
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

@end
