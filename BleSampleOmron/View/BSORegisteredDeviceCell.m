//
//  BSORegisteredDeviceCell.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSORegisteredDeviceCell.h"
#import "UIColor+BleSampleOmron.h"

static NSString * const UnknownModelName = @"Unknown Device";
static NSString * const UnknownLocalName = @"---";

@interface BSORegisteredDeviceCell ()

@property (weak, nonatomic) IBOutlet UILabel *deviceCategoryMarkLabel;
@property (weak, nonatomic) IBOutlet UIImageView *updatedDataMarkImage;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *localNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *protocolLabel;

@end

@implementation BSORegisteredDeviceCell

+ (CGFloat)rowHeight {
    return 80.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _category = OHQDeviceCategoryAny;
    _hasUpdatedData = NO;
    _isBreakdown =  NO;
    _modelName = nil;
    _localName = nil;
    _userIndex = @1;
    _protocol = BSOProtocolNone;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.deviceCategoryMarkLabel.backgroundColor = [UIColor colorWithDeviceCategory:self.category];
    self.protocolLabel.backgroundColor = [UIColor colorWithProtocol:self.protocol];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.deviceCategoryMarkLabel.backgroundColor = [UIColor colorWithDeviceCategory:self.category];
    self.protocolLabel.backgroundColor = [UIColor colorWithProtocol:self.protocol];
}

- (void)setCategory:(OHQDeviceCategory)category {
    if (_category != category) {
        _category = category;
        UIColor *categoryColor = [UIColor colorWithDeviceCategory:category];
        if (categoryColor) {
            self.deviceCategoryMarkLabel.backgroundColor = categoryColor;
        }
        else {
            self.deviceCategoryMarkLabel.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)setHasUpdatedData:(BOOL)hasUpdatedData {
    if (_hasUpdatedData != hasUpdatedData) {
        _hasUpdatedData = hasUpdatedData;
        self.updatedDataMarkImage.hidden = !_hasUpdatedData;
    }
}

- (void)setModelName:(NSString *)modelName {
    if (![_modelName isEqualToString:modelName]) {
        _modelName = modelName;
        self.modelNameLabel.text = _modelName ? _modelName : UnknownModelName;
        [self.modelNameLabel sizeToFit];
    }
}

- (void)setLocalName:(NSString *)localName {
    if (![_localName isEqualToString:localName]) {
        _localName = localName;
        self.localNameLabel.text = _localName ? _localName : UnknownLocalName;
        [self.modelNameLabel sizeToFit];
    }
}

- (void)setUserIndex:(NSNumber *)userIndex {
    _userIndex = userIndex;
    self.userIndexLabel.text = (userIndex ? [NSString stringWithFormat:@"%d", userIndex.intValue] : @"");
    [self.userIndexLabel sizeToFit];
}

- (void)setProtocol:(BSOProtocol)protocol {
    _protocol = protocol;
    
    self.protocolLabel.text = BSOProtocolDescription(_protocol);
    self.protocolLabel.backgroundColor = [UIColor colorWithProtocol:_protocol];
    [self.protocolLabel sizeToFit];
    CGRect bounds = self.protocolLabel.bounds;
    self.protocolLabel.bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width + 10.0, bounds.size.height + 2.0);
}

@end
