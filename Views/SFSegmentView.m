//
//  SFSegmentView.m
//  SFBestIphone
//
//  Created by SFBest on 14-2-12.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import "SFSegmentView.h"

@implementation SFSegmentView
{
    UIView *_segView;
    NSMutableArray *_cells;
    NSMutableArray *_separtors;
    NSMutableArray *_titleLabels;
    NSMutableArray *_iconViews;
}
- (id)initWithFrame:(CGRect)frame items:(NSArray *)items selectionBlock:(SelectionBlock)block
{
    if (self = [super initWithFrame:frame]) {
        _selectionBlock = block;
        _count = items.count;
        _items = items;
        [self setup];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setItems:(NSArray *)items
{
    _items = items;
    _count = items.count;
    [self updateFormat];
}
- (void)setTitle:(NSString *)title forIndex:(NSInteger)index
{
    if (!title || index<0 || index+1>self.count) {
        return;
    }
    UILabel *label = _titleLabels[index];
    label.text = title;
//    [self setSelectedIndex:index];
    [self setEnabled:YES forIndex:index];
}
- (void)setEnabled:(BOOL)flag forIndex:(NSInteger)index
{
    if (index<0 || index+1>self.count) {
        return;
    }
    UIControl *cell = _cells[index];
    cell.enabled = flag;
}
- (void)setup
{
    _cornerRadius = 3;
    _separtors = [NSMutableArray new];
    _titleLabels = [NSMutableArray new];
    _iconViews = [NSMutableArray new];
    _cells = [NSMutableArray new];
    _color = [UIColor whiteColor];
    _selectedColor = [UIColor orangeColor];
    
    _segView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_segView];
    self.backgroundColor = [UIColor clearColor];
    [self configSegCellWithWidth:40];
    _currentIndex = 0;
    [self setInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self updateFormat];
}
- (void)configSegCellWithWidth:(CGFloat)width
{
    __weak __typeof(&*self) weakSelf = self;
    [_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = obj;
        NSString *text = dict[SegText];
        UIImage *image = dict[SegIcon];
        UIControl *cell = [[UIControl alloc] initWithFrame:CGRectMake(width*idx, 0, width, CGRectGetHeight(_segView.frame))];
        [_segView addSubview:cell];
        cell.clipsToBounds = YES;
        cell.tag = idx;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:cell.bounds];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = text;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 6, 12)];
        imageView.image = image;
        [cell addSubview:imageView];
        [cell addSubview:titleLabel];
        [_segView addSubview:cell];
        [_cells addObject:cell];
        [_titleLabels addObject:titleLabel];
        [_iconViews addObject:imageView];
        if (idx+1<_items.count)
        {
            UIView *seprator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cell.frame)-1, 0, 1, CGRectGetHeight(cell.frame))];
            [_segView addSubview:seprator];
            [_separtors addObject:seprator];
        }
        [cell addTarget:weakSelf action:@selector(cellClicked:) forControlEvents:UIControlEventTouchUpInside];
    }];
}
- (void)cellClicked:(id)sender
{
    UIControl *cell = sender;
    NSInteger idx = cell.tag;
    [self setSelectedIndex:idx];
}
- (void)setSelectedIndex:(NSInteger)idx
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _selectionBlock(idx, (_currentIndex>=0)?_iconViews[idx]:nil);
        _currentIndex = idx;
        [self updateFormat];
    });
}
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    _segView.layer.cornerRadius = cornerRadius;
}
- (void)updateCellWithWidth:(CGFloat)width
{
    for (NSInteger i=0; i<_items.count; i++) {
        UIControl *cell = _cells[i];
        UILabel *titleLabel = _titleLabels[i];
        UIImageView *iconView = _iconViews[i];
        
        cell.frame = CGRectMake(width*i, 0, width, CGRectGetHeight(_segView.frame));
        // 如果没有图标label中的文字居中表示
        if (nil != iconView.image) {
            titleLabel.frame = CGRectOffset(cell.bounds, _textOffset.x, _textOffset.y);
            iconView.frame = CGRectOffset(CGRectMake(0, 0, 6, 12), _iconOffset.x, _iconOffset.y);
        }
        else {
            titleLabel.frame = cell.bounds;
            iconView.frame = CGRectMake(0, 0, 0, 0);
        }
        
        if (i == _currentIndex) {
            titleLabel.textColor = _selectedTextAttributes[SegColor];
            titleLabel.font = _selectedTextAttributes[SegFont];
            cell.backgroundColor = _selectedColor;
        } else {
            titleLabel.font = _textAttributes[SegFont];
            titleLabel.textColor = _textAttributes[SegColor];
            //iconView.image = _unSelectedIcon;
            cell.backgroundColor = _color;
        }
        if (i+1<_items.count) {
            UIView *separtor = _separtors[i];
            separtor.frame = CGRectMake(CGRectGetMaxX(cell.frame)-_borderWidth, 0, _borderWidth, CGRectGetHeight(cell.frame));
            separtor.backgroundColor = _borderColor;
        }
    }
    _segView.layer.borderColor = _borderColor.CGColor;
    _segView.layer.borderWidth = _borderWidth;
    _segView.backgroundColor = _color;
    _segView.layer.cornerRadius = _cornerRadius;
    _segView.layer.masksToBounds = YES;
}
- (void)updateFormat
{
    float segCellWidth = CGRectGetWidth(_segView.frame)/_items.count;
    [self updateCellWithWidth:segCellWidth];
}
- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    _segView.frame = UIEdgeInsetsInsetRect(self.bounds, insets);
    [self updateFormat];
}
- (void)setSelectedTextAttributes:(NSDictionary *)selectedTextAttributes
{
    _selectedTextAttributes = selectedTextAttributes;
    [self updateFormat];
}
- (void)setTextAttributes:(NSDictionary *)textAttributes
{
    _textAttributes = textAttributes;
    [self updateFormat];
}

// 强制刷新
- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = -1;
    [self setSelectedIndex:currentIndex];
}

- (void)unSelectedIcon:(UIImage *)icon index:(NSInteger)index
{
    UIImageView *iconView = [_iconViews objectAtIndex:index];
    iconView.image = icon;
}

- (void)setIndex:(NSUInteger)idx invalid:(BOOL)flag {
    
    UIControl *cell = _cells[idx];
    cell.enabled = !flag;
    cell.backgroundColor = flag ? [UIColor lightGrayColor] : [UIColor clearColor];
}
@end
