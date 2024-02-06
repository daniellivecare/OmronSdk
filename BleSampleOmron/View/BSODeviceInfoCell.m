//
//  BSODeviceInfoCell.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODeviceInfoCell.h"
#import "NSDate+BleSampleOmron.h"
#import "UIColor+BleSampleOmron.h"

static NSNumberFormatter *_percentStyleFormatter = nil;

@interface BSODeviceInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *protocolLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *localNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;

@end

@implementation BSODeviceInfoCell

+ (void)initialize {
    if (self == [BSODeviceInfoCell class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _percentStyleFormatter = [NSNumberFormatter new];
            _percentStyleFormatter.numberStyle = NSNumberFormatterPercentStyle;
            _percentStyleFormatter.nilSymbol = @"-";
            _percentStyleFormatter.minimumFractionDigits = 0;
            _percentStyleFormatter.maximumFractionDigits = 1;
        });
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCategory:(OHQDeviceCategory)category {
    _category = category;
    self.categoryLabel.text = OHQDeviceCategoryDescription(category);
    self.categoryLabel.textColor = [UIColor colorWithDeviceCategory:category];
}

- (void)setProtocol:(BSOProtocol)protocol {
    _protocol = protocol;
    self.protocolLabel.text = BSOProtocolDescription(_protocol);
    self.protocolLabel.backgroundColor = [UIColor colorWithProtocol:_protocol];
    [self.protocolLabel sizeToFit];
    CGRect bounds = self.protocolLabel.bounds;
    self.protocolLabel.bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width + 10.0, bounds.size.height + 2.0);
}

- (void)setModelName:(NSString *)modelName {
    _modelName = modelName;
    self.modelNameLabel.text = (modelName ? modelName : @"-");
}

- (void)setLocalName:(NSString *)localName {
    _localName = localName;
    self.localNameLabel.text = (localName ? localName : @"-");
}

- (void)setDeviceTime:(NSDate *)deviceTime {
    _deviceTime = deviceTime;
    self.deviceTimeLabel.text = (deviceTime ? [deviceTime localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : @"-");
}

- (void)setBatteryLevel:(NSNumber *)batteryLevel {
    _batteryLevel = batteryLevel;
    self.batteryLevelLabel.text = [_percentStyleFormatter stringForObjectValue:_batteryLevel];
}

@end
