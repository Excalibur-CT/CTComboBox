//
//  YLCollectionCell.m
//  CTComboBox
//
//  Created by Admin on 16/7/27.
//  Copyright © 2016年 Arvin. All rights reserved.
//

#import "YLCollectionCell.h"

@interface YLCollectionCell ()

@property (nonatomic, strong) UIButton * btn;

@end

@implementation YLCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(10, 5, CGRectGetWidth(self.frame)-20, CGRectGetHeight(self.frame)-10);
        [_btn setTitleColor:[UIColor colorWithRed:0.77 green:0.78 blue:0.78 alpha:1.00] forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor colorWithRed:0.45 green:0.74 blue:0.85 alpha:1.00] forState:UIControlStateSelected];
        _btn.titleLabel.font = [UIFont systemFontOfSize:14];
        _btn.layer.cornerRadius = 5;
        _btn.layer.borderWidth = 1;
        _btn.layer.borderColor = [UIColor colorWithRed:0.77 green:0.78 blue:0.78 alpha:1.00].CGColor;
        _btn.userInteractionEnabled = NO;
        [self addSubview:_btn];
        
    }
    return self;
}

- (void)setText:(NSString *)text
{
    [_btn setTitle:text forState:UIControlStateNormal];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    _btn.selected = isSelected;
    if (isSelected)
    {
        _btn.layer.borderColor = [UIColor colorWithRed:0.45 green:0.74 blue:0.85 alpha:1.00].CGColor;
        _btn.backgroundColor = [[UIColor colorWithRed:0.45 green:0.74 blue:0.85 alpha:1.00] colorWithAlphaComponent:0.3];
        
    }else {
        _btn.layer.borderColor = [UIColor colorWithRed:0.77 green:0.78 blue:0.78 alpha:1.00].CGColor;
        _btn.backgroundColor = [UIColor whiteColor];
    }
}

@end
