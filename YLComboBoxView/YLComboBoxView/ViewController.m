//
//  ViewController.m
//  CTComboBox
//
//  Created by Admin on 16/7/26.
//  Copyright © 2016年 Arvin. All rights reserved.
//

#import "ViewController.h"
#import "YLComboBoxView.h"

@interface ViewController ()<YLComboBoxDataSource, YLComboBoxDelegate>
{
    NSInteger _selectIndex;
}

@property (nonatomic, strong)NSMutableArray * dataAry;
@property (nonatomic, strong)NSMutableArray * selectTwoAry;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataAry = [NSMutableArray arrayWithCapacity:1];
    self.selectTwoAry = [NSMutableArray arrayWithCapacity:1];
    
    _selectIndex = -1;
    NSArray * temp1Ary = @[@"北京",@"上海",@"深圳",@"广州",@"哈尔滨",@"青岛",@"乌鲁木齐",@"大连",@"南京",@"杭州",@"武汉",@"合肥"];
    NSArray * temp2Ary = @[@"养护",@"洗车",@"打蜡",@"护理",@"维修"];
    
    
    [_dataAry addObject:temp1Ary];
    [_dataAry addObject:temp2Ary];
    
    
    YLComboBoxView * boxView = [[YLComboBoxView alloc] initWithOrigin:CGPointMake(0, 64) andHeight:50];
    boxView.selectedBoxBgColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    boxView.highltedTextColor = [UIColor colorWithRed:0.45 green:0.74 blue:0.85 alpha:1.00];
    boxView.maxDropHeight = 300;
    boxView.separatorVerticalSpace = 10;
    boxView.delegate = self;
    boxView.dataSource = self;
    [self.view addSubview:boxView];
}

- (NSInteger)numberOfColumnsInBoxView:(YLComboBoxView *)box
{
    return _dataAry.count;
}

- (BOOL)displayByCollectionViewInColumn:(NSInteger)column
{
    if (column == 1) {
        return YES;
    }else {
        return NO;
    }
}

- (NSString *)boxView:(YLComboBoxView *)boxView titleForColumn:(NSInteger)column
{
    if (column == 0)
    {
        return @"区域";
    }
    return @"服务类型";
}


- (NSInteger )boxView:(YLComboBoxView *)boxView numberOfRowsInColumn:(NSInteger)column
{
    return [_dataAry[column] count];
}

- (NSString *)boxView:(YLComboBoxView *)boxView titleForRowAtIndexPath:(YLIndexPath *)indexPath
{
    NSString * text = _dataAry[indexPath.column][indexPath.row];
    return text;
}

- (BOOL)boxView:(YLComboBoxView *)boxView selectedWithIndexPath:(YLIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        return indexPath.row == _selectIndex ? YES:NO;
    }else {
        
        NSString * text = _dataAry[indexPath.column][indexPath.row];
        if ([_selectTwoAry containsObject:text]) {
            return YES;
        }else {
            return NO;
        }
    }
}

- (void)boxView:(YLComboBoxView *)menu didSelectItemAtIndexPath:(YLIndexPath *)indexPath
{
    if (indexPath.column == 0)
    {
        _selectIndex = indexPath.row;
        NSLog(@" _selectOne --- %@", _dataAry[0][indexPath.row]);
    }
    else
    {
        NSString * text = _dataAry[indexPath.column][indexPath.row];
        if ([_selectTwoAry containsObject:text]) {
            [_selectTwoAry removeObject:text];
        }else {
            [_selectTwoAry addObject:text];
        }
    }
}

- (void)boxView:(YLComboBoxView *)menu clickType:(YLCollectionFooterClickType)type column:(NSInteger)column
{
    if (type == YLCollectionFooterClickResetType) {
        [_selectTwoAry removeAllObjects];
    }else
    {
        NSLog(@" _selectTwoAry --- %@", _selectTwoAry);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
