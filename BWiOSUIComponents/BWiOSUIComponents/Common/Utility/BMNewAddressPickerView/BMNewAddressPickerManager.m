//
//  BMNewAddressPickerManager.m
//  BMWash
//
//  Created by BobWong on 2017/5/26.
//  Copyright © 2017年 月亮小屋（中国）有限公司. All rights reserved.
//

#import "BMNewAddressPickerManager.h"
#import "BMNewAddressPickerView.h"
#import "BWAddressSourceManager.h"
#import "BMAddressModel.h"

@interface BMNewAddressPickerManager ()

/* UI */
@property (strong, nonatomic) BMNewAddressPickerView *pickerView;

/* Data */
@property (strong, nonatomic) BWAddressSourceManager *addressSourceManager;  ///< address source manager

@property (strong, nonatomic) NSMutableArray<NSArray *> *addressArray;  ///< 地址数据源

@end

@implementation BMNewAddressPickerManager

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        [self setData];
    }
    return self;
}

#pragma mark - Public Method

- (void)show {
    if (_addressArray.count > 0) {
        [_pickerView show];
        return;
    }
    
    [self getRegionDataWithParentModel:nil];
}

- (void)dismiss {
    [_pickerView dismiss];
}

#pragma mark - Private Method

- (void)setData {
    self.addressArray = [NSMutableArray new];
    self.addressSourceManager = [BWAddressSourceManager new];
    
    _pickerView = [BMNewAddressPickerView new];
    
    __weak typeof(self) weakSelf = self;
    _pickerView.getDataBlock = ^(NSUInteger selectedSection, NSUInteger selectedRow) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        BMAddressModel *model = strongSelf.addressArray[selectedSection][selectedRow];
        [strongSelf getRegionDataWithParentModel:model];
    };
    
    _pickerView.removeAddressArrayObjectBlock = ^(NSRange range) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.addressArray removeObjectsInRange:range];
    };
    
    _pickerView.didSelectBlock = ^(NSMutableArray *selectedIndexArray) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"selected index array is %@", selectedIndexArray);
        
        // 选中的BMAddressModel添加进数组
        NSMutableArray *arrayM = [NSMutableArray new];
        [strongSelf.addressArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull selectedAddressSourceArray, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger selectedIndex = [selectedIndexArray[idx] integerValue];
            [arrayM addObject:selectedAddressSourceArray[selectedIndex]];
        }];
        
        if (strongSelf.didSelectBlock) strongSelf.didSelectBlock(arrayM);
        [strongSelf dismiss];
    };
}

- (void)getRegionDataWithParentModel:(BMAddressModel *)parentModel {
    NSArray *typeArray = @[BMAddressTypeProvince, BMAddressTypeCity, BMAddressTypeCounty];
    NSInteger typeIndex = _addressArray.count;
    if (typeIndex > typeArray.count - 1) return;
    
    // 用数据去刷新pickerView
    NSInteger parentCode = parentModel ? parentModel.code : 0;
    NSArray<BMAddressModel *> *array = [self.addressSourceManager addressSourceArrayWithParentCode:parentCode addressType:typeArray[typeIndex]];
    [self.addressArray addObject:array];
    
    NSMutableArray *nameArray = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(BMAddressModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [nameArray addObject:model.name];
    }];
    
    [_pickerView addNextAddressDataWithNewAddressArray:nameArray];
    
    // 第一次显示
    if (_addressArray.count == 1) {
        [_pickerView show];
    }
}

#pragma mark - Setter and Getter

@end
