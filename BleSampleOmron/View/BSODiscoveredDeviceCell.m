//
//  BSODiscoveredDeviceCell.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODiscoveredDeviceCell.h"
#import "BSODefines.h"
#import "UIColor+BleSampleOmron.h"

static NSString * const UnknownModelName = @"Unknown Device";
static NSString * const UnknownLocalName = @"---";

@interface BSODiscoveredDeviceCell ()

@property (weak, nonatomic) IBOutlet UILabel *deviceCategoryMarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *localNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *RSSILabel;
@property (weak, nonatomic) IBOutlet UILabel *RSSIUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStandardLabel;
@property (weak, nonatomic) IBOutlet UILabel *omronExtensionLabel;
@property (weak, nonatomic) IBOutlet UILabel *registeredLabel;

@end

@implementation BSODiscoveredDeviceCell

+ (CGFloat)rowHeight {
    return 80.0f;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _category = OHQDeviceCategoryAny;
    _modelName = nil;
    _localName = nil;
    _RSSI = nil;
    _supportedProtocols = nil;
    _registered = NO;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.deviceCategoryMarkLabel.backgroundColor = [UIColor whiteColor];
        self.bluetoothStandardLabel.backgroundColor = ([self.supportedProtocols containsObject:@(BSOProtocolBluetoothStandard)] ? [UIColor bluetoothBaseColor] : [UIColor lightGrayColor]);
        self.omronExtensionLabel.backgroundColor = [UIColor colorWithProtocol:BSOProtocolOmronExtension];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.deviceCategoryMarkLabel.backgroundColor = [UIColor whiteColor];
        self.bluetoothStandardLabel.backgroundColor = ([self.supportedProtocols containsObject:@(BSOProtocolBluetoothStandard)] ? [UIColor bluetoothBaseColor] : [UIColor lightGrayColor]);
        self.omronExtensionLabel.backgroundColor = [UIColor colorWithProtocol:BSOProtocolOmronExtension];
    }
}

- (void)setCategory:(OHQDeviceCategory)category {
    _category = category;
    self.deviceCategoryMarkLabel.backgroundColor = [UIColor whiteColor];
}

- (void)setModelName:(NSString *)modelName {
    _modelName = modelName;
    self.modelNameLabel.text = _modelName ? _modelName : UnknownModelName;
    [self.modelNameLabel sizeToFit];
}

- (void)setLocalName:(NSString *)localName {
    _localName = localName;
    self.localNameLabel.text = _localName ? _localName : UnknownLocalName;
    [self.modelNameLabel sizeToFit];
}

- (void)setRSSI:(NSNumber *)RSSI {
    _RSSI = RSSI;
    if (_RSSI) {
        self.RSSILabel.hidden = NO;
        self.RSSIUnitLabel.hidden = NO;
        self.RSSILabel.text = [NSString stringWithFormat:@"%d", RSSI.intValue];
        [self.RSSILabel sizeToFit];
    }
    else {
        self.RSSILabel.hidden = YES;
        self.RSSIUnitLabel.hidden = YES;
    }
}

- (void)setSupportedProtocols:(NSArray *)supportedProtocols {
    _supportedProtocols = [supportedProtocols copy];
    self.bluetoothStandardLabel.backgroundColor = ([_supportedProtocols containsObject:@(BSOProtocolBluetoothStandard)] ? [UIColor bluetoothBaseColor] : [UIColor lightGrayColor]);
    self.omronExtensionLabel.hidden = ![_supportedProtocols containsObject:@(BSOProtocolOmronExtension)];
}

- (void)setRegistered:(BOOL)registered {
    _registered = registered;
    self.registeredLabel.hidden = !_registered;
    self.accessoryType = (!_registered ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDetailButton);
    self.selectionStyle = (!_registered ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone);
}

@end
