//
//  YLComboBoxView.h
//  YLComboBox
//
//  Created by Admin on 16/7/26.
//  Copyright © 2016年 Arvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;  // 菜单索引
@property (nonatomic, assign) NSInteger row;     // 行数

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row;

@end


@interface UICollectionFooterView : UICollectionReusableView

@property (nonatomic, strong) UIButton * reSetBtn;
@property (nonatomic, strong) UIButton * sureBtn;

@end


typedef NS_ENUM(NSInteger, YLCollectionFooterClickType)
{
    YLCollectionFooterClickResetType,  // 重置
    YLCollectionFooterClickSureType    // 确认
};

#pragma mark - data source protocol -
@class YLComboBoxView;

@protocol YLComboBoxDataSource <NSObject>

@required
- (NSInteger )boxView:(YLComboBoxView *)boxView numberOfRowsInColumn:(NSInteger)column;

- (NSString *)boxView:(YLComboBoxView *)boxView titleForRowAtIndexPath:(YLIndexPath *)indexPath;

- (NSString *)boxView:(YLComboBoxView *)boxView titleForColumn:(NSInteger)column;

- (BOOL)boxView:(YLComboBoxView *)boxView selectedWithIndexPath:(YLIndexPath *)indexPath;

@optional
/**
 *  default value is 1
 *
 */
- (NSInteger)numberOfColumnsInBoxView:(YLComboBoxView *)box;
/**
 * 是否需要显示为UICollectionView 默认为否
 */
- (BOOL)displayByCollectionViewInColumn:(NSInteger)column;

@end

#pragma mark - delegate
@protocol YLComboBoxDelegate <NSObject>

@optional
- (void)boxView:(YLComboBoxView *)menu didSelectItemAtIndexPath:(YLIndexPath *)indexPath;

- (void)boxView:(YLComboBoxView *)menu clickType:(YLCollectionFooterClickType)type column:(NSInteger)column;

@end




@interface YLComboBoxView : UIView <UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id <YLComboBoxDataSource> dataSource;
@property (nonatomic, weak) id <YLComboBoxDelegate>   delegate;

@property (nonatomic, strong) UIColor * indicatorColor;
@property (nonatomic, strong) UIColor * textColor;
@property (nonatomic, strong) UIColor * highltedTextColor;
@property (nonatomic, assign) CGFloat   separatorVerticalSpace;
@property (nonatomic, strong) UIColor * separatorColor;
@property (nonatomic, strong) UIColor * selectedBoxBgColor;
@property (nonatomic, assign) CGFloat   maxDropHeight;
@property (nonatomic, assign) UIEdgeInsets  collectionInsets;

/**
 *  the width of menu will be set to screen width defaultly
 *
 *  @param origin the origin of this view's frame
 *  @param height menu's height
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

- (NSString *)titleForRowAtIndexPath:(YLIndexPath *)indexPath;

@end
