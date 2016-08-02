//
//  YLComboBoxView.m
//  YLComboBox
//
//  Created by Admin on 16/7/26.
//  Copyright © 2016年 Arvin. All rights reserved.
//

#import "YLComboBoxView.h"
#import "YLCollectionCell.h"

static NSString * const tableViewCellIndentifier      = @"tableViewCellIndentifier";
static NSString * const collectionViewCellIndentifier = @"collectionCellIndentifier";
static NSString * const collectionViewFooterIndentifier = @"collectionViewFooterIndentifier";



#pragma mark - YLIndexPath implementation -
@implementation YLIndexPath

- (instancetype)initWithColumn:(NSInteger)column  row:(NSInteger)row
{
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
    }
    return self;
}

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row
{
    YLIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}

@end


@implementation UICollectionFooterView

-  (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton * (^ button)(CGRect frame, NSString * title, NSInteger tag) = ^(CGRect frame, NSString * title, NSInteger tag) {
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = tag;
            btn.frame = frame;
            [btn setTitleColor:[UIColor colorWithRed:0.77 green:0.78 blue:0.78 alpha:1.00] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitle:title forState:UIControlStateNormal];
            btn.layer.borderColor = [UIColor colorWithRed:0.77 green:0.78 blue:0.78 alpha:1.00].CGColor;
            btn.layer.borderWidth = 1;
            btn.layer.cornerRadius = 5;
            [self addSubview:btn];
            return btn;
        };
        
       self.reSetBtn = button(CGRectMake(15, 0, (CGRectGetWidth(self.frame)-50)/2.0, 30), @"重置", 100);
       self.sureBtn  = button(CGRectMake(CGRectGetMaxX(_reSetBtn.frame)+20, 0, (CGRectGetWidth(self.frame)-50)/2.0, 30), @"确定", 101);
        self.sureBtn.backgroundColor = [UIColor colorWithRed:0.77 green:0.78 blue:0.78 alpha:1.00];
        [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];


    }
    return self;
}

@end




#pragma mark - YLComboBoxView -
@interface YLComboBoxView ()

@property (nonatomic, assign) NSInteger          currentSelectedBoxIndex;
@property (nonatomic, assign) BOOL               isAnimation;
@property (nonatomic, assign) BOOL               isShow;
@property (nonatomic, assign) NSInteger          numOfBox;
@property (nonatomic, assign) CGPoint            origin;

@property (nonatomic, strong) UIView           * backGroundView;
@property (nonatomic, strong) CALayer          * topLineLayer;
@property (nonatomic, strong) CALayer          * bottomLineLayer;
@property (nonatomic, strong) UITableView      * tableView;
@property (nonatomic, strong) UICollectionView * collectionView;
//data source
@property (nonatomic, copy  ) NSArray   * dataArray;
//layers array
@property (nonatomic, copy  ) NSArray   * titleLayerAry;
@property (nonatomic, copy  ) NSArray   * indicatorAry;
@property (nonatomic, copy  ) NSArray   * bgLayerAry;
@end

@implementation YLComboBoxView

- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, height)];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _maxDropHeight = 300;
        _collectionInsets = UIEdgeInsetsMake(20, 5, 20, 5);
        
        
        _origin = origin;
        _currentSelectedBoxIndex = -1;
        _isShow = NO;
        
        _isAnimation = NO;
        
        //tableView init
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, 0, 0) style:UITableViewStylePlain];
        _tableView.rowHeight = 38;
        _tableView.separatorColor = [UIColor colorWithRed:220.f/255.0f green:220.f/255.0f blue:220.f/255.0f alpha:1.0];
        _tableView.dataSource = self;
        _tableView.delegate = self;

        
        
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.footerReferenceSize = CGSizeMake(CGRectGetWidth(self.frame), 40);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[YLCollectionCell class] forCellWithReuseIdentifier:collectionViewCellIndentifier];
        [_collectionView registerClass:[UICollectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:collectionViewFooterIndentifier];
        
        self.autoresizesSubviews            = NO;
        _tableView.autoresizesSubviews      = NO;
        _collectionView.autoresizesSubviews = NO;
        
        //self tappep
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y+height, screenSize.width, screenSize.height - origin.y+height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        
        //add top bottom shadow
        _topLineLayer = [CALayer layer];
        _topLineLayer.frame = CGRectMake(0, 0, screenSize.width, 1/[UIScreen mainScreen].scale);
        [self.layer addSublayer:_topLineLayer];
        
        
        _bottomLineLayer = [CALayer layer];
        _bottomLineLayer.frame = CGRectMake(0, CGRectGetHeight(self.frame)-0.5, screenSize.width, 1/[UIScreen mainScreen].scale);
        [self.layer addSublayer:_bottomLineLayer];
    }
    return self;
}


#pragma mark - getter
- (UIColor *)indicatorColor
{
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor
{
    if (!_textColor) {
        _textColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.44 alpha:1.00];
    }
    return _textColor;
}

- (UIColor *)highltedTextColor
{
    if (!_highltedTextColor) {
        _highltedTextColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.44 alpha:1.00];
    }
    return _highltedTextColor;
}

- (UIColor *)separatorColor
{
    if (!_separatorColor) {
        _separatorColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    }
    return _separatorColor;
}

#pragma mark - setter
- (void)setDataSource:(id<YLComboBoxDataSource>)dataSource
{
    _dataSource = dataSource;
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInBoxView:)]) {
        _numOfBox = [_dataSource numberOfColumnsInBoxView:self];
    } else {
        _numOfBox = 1;
    }
    
    CGFloat textLayerWidth = self.frame.size.width / ( _numOfBox * 2);
    
    CGFloat bgLayerWidth = self.frame.size.width / _numOfBox;
    
    NSMutableArray * tempTitlesAry = [[NSMutableArray alloc] initWithCapacity:_numOfBox];
    NSMutableArray * tempIndicatorsAry = [[NSMutableArray alloc] initWithCapacity:_numOfBox];
    NSMutableArray * tempBgLayersAry = [[NSMutableArray alloc] initWithCapacity:_numOfBox];

    for (int i = 0; i < _numOfBox; i++)
    {
        // bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerWidth, CGRectGetHeight(self.frame)/2);
        CALayer *bgLayer = [self createBgLayerWithColor:KBoxTitleBackColor andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayersAry addObject:bgLayer];
        
        // title
        CGPoint titlePosition = CGPointMake((i * 2 + 1) * textLayerWidth -(KIndatiorSize.width+KTitleIndatiorDistance)/2.0, self.frame.size.height / 2);
        NSString *titleString = [_dataSource boxView:self titleForColumn:i];
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitlesAry addObject:title];
        
        // indicator
        CGPoint indicatorPosition =CGPointMake(titlePosition.x + CGRectGetWidth(title.frame) / 2 + KIndatiorSize.width/2.0+KTitleIndatiorDistance, self.frame.size.height / 2);
        CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:indicatorPosition type:0];
        [self.layer addSublayer:indicator];
        [tempIndicatorsAry addObject:indicator];

    }
    
    for (int i = 0; i < _numOfBox-1; i++) {
        // separator
        CGPoint separatorPosition = CGPointMake((i + 1) * bgLayerWidth, self.frame.size.height/2);
        CALayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
        [self.layer addSublayer:separator];
    }
    
    _topLineLayer.backgroundColor = self.separatorColor.CGColor;
    _bottomLineLayer.backgroundColor = self.separatorColor.CGColor;
    
    _titleLayerAry = [tempTitlesAry copy];
    _indicatorAry = [tempIndicatorsAry copy];
    _bgLayerAry = [tempBgLayersAry copy];
}

- (void)reloadTitleData
{
    for (int i = 0; i < _numOfBox; i++)
    {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(boxView:titleForColumn:)])
        {
            NSString * string = [self.dataSource boxView:self titleForColumn:i];
            CATextLayer * titleLayer = ((CATextLayer *)_titleLayerAry[i]);
            titleLayer.string = string;
            CGSize size = [self calculateTitleSizeWithString:string];
            CGFloat sizeWidth = fminf(size.width, CGRectGetWidth(self.frame) / _numOfBox - KIndatiorSize.width-KTitleIndatiorDistance);
            ((CATextLayer *)_titleLayerAry[i]).bounds = CGRectMake(0, 1, sizeWidth, size.height);
            
            CAShapeLayer *indicator = (CAShapeLayer *)_indicatorAry[_currentSelectedBoxIndex];
            indicator.position = CGPointMake(titleLayer.position.x + titleLayer.frame.size.width / 2 + 8, indicator.position.y);
        }
    }
    [self reloadData];
}

- (void)reloadData
{
    [_tableView reloadData];
    [_collectionView reloadData];
}

- (NSString *)titleForRowAtIndexPath:(YLIndexPath *)indexPath
{
    return [self.dataSource boxView:self titleForRowAtIndexPath:indexPath];
}

#pragma mark - init support -
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position
{
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, CGRectGetWidth(self.frame)/self.numOfBox, CGRectGetHeight(self.frame)-1);
    layer.backgroundColor = color.CGColor;
    return layer;
}

- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point type:(NSInteger)type
{
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    
    if (type == 0)   // 空心箭头
    {
        [path moveToPoint:CGPointMake(0, KIndatiorSize.height)];
        [path addLineToPoint:CGPointMake(KIndatiorSize.width/2.0, 0)];
        
        path.lineJoinStyle = kCGLineCapRound; //终点处理
        
        UIBezierPath *path1 = [UIBezierPath new];
        [path1 moveToPoint:CGPointMake(KIndatiorSize.width/2.0, 0)];
        [path1 addLineToPoint:CGPointMake(KIndatiorSize.width, KIndatiorSize.height)];
        
        path1.lineJoinStyle = kCGLineCapRound; //终点处理
        [path appendPath:path1];
        layer.strokeColor = color.CGColor;

    }else if(type == 1) // 实心箭头
    {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(KIndatiorSize.width, 0)];
        [path addLineToPoint:CGPointMake(KIndatiorSize.width/2.0, KIndatiorSize.height)];
        [path closePath];
        
        layer.fillColor = color.CGColor;
    }
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
  
    
    layer.bounds = CGRectMake(0, 0, KIndatiorSize.width, KIndatiorSize.height);
    layer.position = point;
    
    return layer;
}

- (CALayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point
{
    CALayer *layer = [CALayer new];
    layer.backgroundColor = color.CGColor;
    CGFloat width = 1.0/[[UIScreen mainScreen] scale];
    layer.frame = CGRectMake(0, 0, width, CGRectGetHeight(self.frame)-2*self.separatorVerticalSpace);
    layer.position = point;
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point
{
    CGSize size = [self calculateTitleSizeWithString:string];
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = fminf(size.width, (self.frame.size.width / _numOfBox) - KIndatiorSize.width - KTitleIndatiorDistance) ;
    layer.bounds = CGRectMake(0, 1, sizeWidth, size.height);
    layer.string = string;
    layer.truncationMode = kCATruncationEnd;
    layer.fontSize = KTitleFontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    layer.position = point;
    
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    CGFloat fontSize = KTitleFontSize;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(320, 30) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}


#pragma mark - gesture handle -
- (void)menuTapped:(UITapGestureRecognizer *)paramSender
{
    if (_isAnimation)
    {
        return;
    }
    
    @synchronized (self)
    {
        _isAnimation = YES;
        CGPoint touchPoint = [paramSender locationInView:self];
        // calculate index
        NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfBox);
        
        for (int i = 0; i < _numOfBox; i++) {
            if (i != tapIndex) {
                [self animateIndicator:_indicatorAry[i] Forward:NO complete:^{
                    [self animateTitle:_titleLayerAry[i] show:NO complete:nil];
                }];
                [(CALayer *)self.bgLayerAry[i] setBackgroundColor:KBoxTitleBackColor.CGColor];
            }
        }
        
        BOOL displayByCollectionView = NO;
        
        if ([_dataSource respondsToSelector:@selector(displayByCollectionViewInColumn:)])
        {
            displayByCollectionView = [_dataSource displayByCollectionViewInColumn:tapIndex];
        }
        
        if (displayByCollectionView)
        {
            UICollectionView *collectionView = _collectionView;
            // 当前Box 选中且处于展开状态
            if (tapIndex == _currentSelectedBoxIndex && _isShow)
            {
                [self animateIndicator:_indicatorAry[_currentSelectedBoxIndex]
                        backgroundView:_backGroundView
                        collectionView:collectionView
                            titleLayer:_titleLayerAry[_currentSelectedBoxIndex]
                               forward:NO
                             complecte:^{
                                 _currentSelectedBoxIndex = tapIndex;
                                 _isShow = NO;
                             }];
                
                [(CALayer *)self.bgLayerAry[tapIndex] setBackgroundColor:KBoxTitleBackColor.CGColor];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isAnimation = NO;
                });
            }
            else
            {
                _currentSelectedBoxIndex = tapIndex;
                [_collectionView reloadData];
                if (_currentSelectedBoxIndex != -1)
                {
                    // 需要隐藏tableview
                    [self animateTableView:_tableView show:NO complete:^
                    {
                        [self animateIndicator:_indicatorAry[tapIndex]
                                backgroundView:_backGroundView
                                collectionView:collectionView
                                    titleLayer:_titleLayerAry[tapIndex]
                                       forward:YES complecte:^{
                                           _isShow = YES;
                                       }];
                    }];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _isAnimation = NO;
                    });

                }
                else
                {
                    [self animateIndicator:_indicatorAry[tapIndex]
                            backgroundView:_backGroundView
                            collectionView:collectionView
                                titleLayer:_titleLayerAry[tapIndex]
                                   forward:YES
                                 complecte:^{
                                       _isShow = YES;
                                   }];
                }
                [(CALayer *)self.bgLayerAry[tapIndex] setBackgroundColor:self.selectedBoxBgColor.CGColor];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isAnimation = NO;
                });
            }
            
        } else{
            
            if (tapIndex == _currentSelectedBoxIndex && _isShow)
            {
                [self animateIndicator:_indicatorAry[_currentSelectedBoxIndex]
                        backgroundView:_backGroundView
                             tableView:_tableView
                            titleLayer:_titleLayerAry[_currentSelectedBoxIndex]
                               forward:NO
                             complecte:^{
                                 _currentSelectedBoxIndex = tapIndex;
                                 _isShow = NO;
                             }];
                [(CALayer *)self.bgLayerAry[tapIndex] setBackgroundColor:KBoxTitleBackColor.CGColor];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isAnimation = NO;
                });

            } else
            {
                _currentSelectedBoxIndex = tapIndex;
                if (_tableView)
                {
                    _tableView.frame = CGRectMake(_tableView.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
                }
                
                if (_currentSelectedBoxIndex != -1)
                {
                    // 需要隐藏collectionview
                    [self animateCollectionView:_collectionView show:NO complete:^{
                        
                        [self animateIndicator:_indicatorAry[tapIndex]
                                backgroundView:_backGroundView
                                     tableView:_tableView
                                    titleLayer:_titleLayerAry[tapIndex]
                                       forward:YES
                                     complecte:^{
                                         _isShow = YES;
                                     }];
                    }];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _isAnimation = NO;
                    });
                } else{
                    [self animateIndicator:_indicatorAry[tapIndex]
                            backgroundView:_backGroundView
                                 tableView:_tableView
                                titleLayer:_titleLayerAry[tapIndex]
                                   forward:YES
                                 complecte:^{
                                     _isShow = YES;
                                 }];
                }
                [_tableView reloadData];
                [(CALayer *)self.bgLayerAry[tapIndex] setBackgroundColor:self.selectedBoxBgColor.CGColor];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isAnimation = NO;
                });
            }
        }
        
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    BOOL displayByCollectionView = NO;
    if ([_dataSource respondsToSelector:@selector(displayByCollectionViewInColumn:)])
    {
        displayByCollectionView = [_dataSource displayByCollectionViewInColumn:_currentSelectedBoxIndex];
    }
    if (displayByCollectionView)
    {
        [self animateIndicator:_indicatorAry[_currentSelectedBoxIndex]
                backgroundView:_backGroundView
                collectionView:_collectionView
                    titleLayer:_titleLayerAry[_currentSelectedBoxIndex]
                       forward:NO
                     complecte:^{
                         _isShow = NO;
                     }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isAnimation = NO;
        });
    } else
    {
        [self animateIndicator:_indicatorAry[_currentSelectedBoxIndex]
                backgroundView:_backGroundView
                     tableView:_tableView
                    titleLayer:_titleLayerAry[_currentSelectedBoxIndex]
                       forward:NO
                     complecte:^{
                         _isShow = NO;
                     }];
    }
    [(CALayer *)self.bgLayerAry[_currentSelectedBoxIndex] setBackgroundColor:KBoxTitleBackColor.CGColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isAnimation = NO;
    });
}


#pragma mark - animation method
- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    if (complete) {
        complete();
    }
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete
{
    if (show) {
        [self.superview addSubview:view];
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    
    if (complete) {
        complete();
    }
}

/**
 *动画显示下拉 TableView 菜单
 */
- (void)animateTableView:(UITableView *)tableView
                    show:(BOOL)show
                complete:(void(^)())complete
{
    if (show)
    {
        CGFloat tableViewHeight = 0;
        
        tableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
        [self.superview addSubview:tableView];
        
        tableViewHeight = fminf(self.maxDropHeight,[tableView numberOfRowsInSection:0] * tableView.rowHeight);
        
        [UIView animateWithDuration:0.2 animations:^{
            if (tableView)
            {
                tableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, tableViewHeight);
            }
        }];
    } else
    {
        [UIView animateWithDuration:0.2 animations:^{
            tableView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
        } completion:^(BOOL finished) {
            if (tableView) {
                [tableView removeFromSuperview];
            }
        }];
    }
    if (complete) {
        complete();
    }
}

/**
 *动画显示下拉 CollectionView 菜单
 */
- (void)animateCollectionView:(UICollectionView *)collectionView
                         show:(BOOL)show
                     complete:(void(^)())complete
{
    if (show) {
        
        CGFloat collectionViewHeight = 0;
        
        if (collectionView) {
            
            collectionView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            [self.superview addSubview:collectionView];
            
            UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
            NSInteger num = ceilf([collectionView numberOfItemsInSection:0]/3.0);
            CGFloat height = num * 35 + self.collectionInsets.top+self.collectionInsets.bottom;
            height += layout.footerReferenceSize.height;
            
            collectionViewHeight = fminf(self.maxDropHeight, height);
            
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            if (collectionView) {
                collectionView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, collectionViewHeight);
            }
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            
            if (collectionView) {
                collectionView.frame = CGRectMake(_origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
            }
        } completion:^(BOOL finished) {
            
            if (collectionView) {
                [collectionView removeFromSuperview];
            }
        }];
    }
    if (complete) {
        complete();
    }
}

- (void)animateTitle:(CATextLayer *)title
                show:(BOOL)show
            complete:(void(^)())complete
{
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = fminf(size.width, CGRectGetWidth(self.frame) / _numOfBox - KIndatiorSize.width-KTitleIndatiorDistance);
    title.bounds = CGRectMake(0, 1, sizeWidth, size.height);
    if (complete) {
        complete();
    }
}

- (void)animateIndicator:(CAShapeLayer *)indicator
         backgroundView:(UIView *)background
              tableView:(UITableView *)tableView
             titleLayer:(CATextLayer *)title
                forward:(BOOL)forward
              complecte:(void(^)())complete
{
    
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateTableView:tableView show:forward complete:nil];
            }];
        }];
    }];

    if (complete) {
        complete();
    }
}

- (void)animateIndicator:(CAShapeLayer *)indicator
          backgroundView:(UIView *)background
          collectionView:(UICollectionView *)collectionView
              titleLayer:(CATextLayer *)title
                 forward:(BOOL)forward
               complecte:(void(^)())complete
{
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateCollectionView:collectionView show:forward complete:nil];
            }];
        }];
    }];
    
    if (complete) {
        complete();
    }
}


#pragma mark - table datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(boxView:numberOfRowsInColumn:)])
    {
        return [self.dataSource boxView:self numberOfRowsInColumn:_currentSelectedBoxIndex];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIndentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor whiteColor];
//        cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
//        cell.backgroundView.backgroundColor = self.selectedBoxBgColor;
//        cell.backgroundView.hidden = YES;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(cell.frame))];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = self.textColor;
        titleLabel.highlightedTextColor = self.highltedTextColor;
        titleLabel.tag = 1001;
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        [cell addSubview:titleLabel];
    }

    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1001];
    YLIndexPath * index = [YLIndexPath indexPathWithCol:_currentSelectedBoxIndex row:indexPath.row];
    
    if ([self.dataSource respondsToSelector:@selector(boxView:titleForRowAtIndexPath:)])
    {
        titleLabel.text = [self.dataSource boxView:self titleForRowAtIndexPath:index];
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(boxView:selectedWithIndexPath:)]) {
        BOOL highlted = [self.dataSource boxView:self selectedWithIndexPath:index];
//        cell.backgroundView.hidden = !highlted;
        titleLabel.highlighted = highlted;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - tableview delegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate || [self.delegate respondsToSelector:@selector(boxView:didSelectItemAtIndexPath:)])
    {
        [self.delegate boxView:self didSelectItemAtIndexPath:[YLIndexPath indexPathWithCol:_currentSelectedBoxIndex row:indexPath.row]];
    }
    [self configBoxTableViewWithSelectRow:indexPath.row];
}

- (void)configBoxTableViewWithSelectRow:(NSInteger)row
{
    CATextLayer *title = (CATextLayer *)_titleLayerAry[_currentSelectedBoxIndex];
    title.string = [self.dataSource boxView:self titleForRowAtIndexPath:[YLIndexPath indexPathWithCol:_currentSelectedBoxIndex row:row]];
    
    [self animateIndicator:_indicatorAry[_currentSelectedBoxIndex]
            backgroundView:_backGroundView
                 tableView:_tableView
                titleLayer:_titleLayerAry[_currentSelectedBoxIndex]
                   forward:NO
                 complecte:^{
                     _isShow = NO;
                    }];
    [(CALayer *)self.bgLayerAry[_currentSelectedBoxIndex] setBackgroundColor:KBoxTitleBackColor.CGColor];

    CAShapeLayer *indicator = (CAShapeLayer *)_indicatorAry[_currentSelectedBoxIndex];
    indicator.position = CGPointMake(title.position.x + title.frame.size.width / 2 + KTitleIndatiorDistance+KIndatiorSize.width/2.0, indicator.position.y);
}
#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 为collectionview时
    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(boxView:numberOfRowsInColumn:)])
    {
        return [self.dataSource boxView:self numberOfRowsInColumn:_currentSelectedBoxIndex];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellIndentifier forIndexPath:indexPath];
    YLIndexPath * index = [YLIndexPath indexPathWithCol:_currentSelectedBoxIndex row:indexPath.item];
    if ([self.dataSource respondsToSelector:@selector(boxView:titleForRowAtIndexPath:)]) {
        cell.text = [self.dataSource boxView:self titleForRowAtIndexPath:index];
    } else {
        NSAssert(0 == 1, @"dataSource method needs to be implemented");
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(boxView:selectedWithIndexPath:)]) {
        cell.isSelected = [self.dataSource boxView:self selectedWithIndexPath:index];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter)
    {
        UICollectionFooterView * view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionViewFooterIndentifier forIndexPath:indexPath];
        view.backgroundColor = [UIColor whiteColor];
        [view.reSetBtn addTarget:self action:@selector(collectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [view.sureBtn  addTarget:self action:@selector(collectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        return view;

    }else
    {
        return nil;
    }
    
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.frame.size.width - self.collectionInsets.left - _collectionInsets.right)/3;
    return CGSizeMake(width, 35);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.collectionInsets;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 0.5;
}
#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(boxView:didSelectItemAtIndexPath:)]) {
        [self.delegate boxView:self didSelectItemAtIndexPath:[YLIndexPath indexPathWithCol:_currentSelectedBoxIndex row:indexPath.item]];
    }
    
    YLCollectionCell * cell = (YLCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected =  !cell.isSelected;
}


- (void)collectionButtonClick:(UIButton *)btn
{
    // 重置
    if (btn.tag == 100) {
        
    }else {
        
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(boxView:clickType:column:)]) {
        [self.delegate boxView:self clickType:btn.tag -100 column:_currentSelectedBoxIndex];
    }
    
    [self configCollectionView];
}


- (void)configCollectionView
{
//    CATextLayer *title = (CATextLayer *)_titleLayerAry[_currentSelectedBoxIndex];
//    title.string = [self.dataSource boxView:self titleForColumn:_currentSelectedBoxIndex];
//    
    [self animateIndicator:_indicatorAry[_currentSelectedBoxIndex]
            backgroundView:_backGroundView
            collectionView:_collectionView
                titleLayer:_titleLayerAry[_currentSelectedBoxIndex]
                   forward:NO
                 complecte:^{
                     _isShow = NO;
                 }];
    
    [(CALayer *)self.bgLayerAry[_currentSelectedBoxIndex] setBackgroundColor:KBoxTitleBackColor.CGColor];

//    CAShapeLayer *indicator = (CAShapeLayer *)_indicatorAry[_currentSelectedBoxIndex];
//    indicator.position = CGPointMake(title.position.x + title.frame.size.width / 2 + 8, indicator.position.y);
}


@end
