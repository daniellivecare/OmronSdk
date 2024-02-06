//
//  BSOHistoryCell.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOHistoryCell.h"
#import "NSDate+BleSampleOmron.h"

static NSString * const AlternateText = @"-";

@interface BSOHistoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *operationTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *protocolLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *localNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation BSOHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setNumber:(NSInteger)number {
    _number = number;
    [self bso_setText:[NSString stringWithFormat:@"%ld", (long)_number] toLabel:self.numberLabel];
}

- (void)setDate:(NSDate *)date {
    _date = date;
    [self bso_setText:[_date localTimeStringWithFormat:nil] toLabel:self.dateLabel];
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    [self bso_setText:_userName toLabel:self.userNameLabel];
}

- (void)setOperation:(BSOOperation)operation {
    _operation = operation;
    [self bso_setText:BSOOperationDescription(_operation) toLabel:self.operationTypeLabel];
}

- (void)setProtocol:(BSOProtocol)protocol {
    _protocol = protocol;
    [self bso_setText:BSOProtocolDescription(protocol) toLabel:self.protocolLabel];
}

- (void)setModelName:(NSString *)modelName {
    _modelName = modelName;
    [self bso_setText:_modelName toLabel:self.modelNameLabel];
}

- (void)setLocalName:(NSString *)localName {
    _localName = localName;
    [self bso_setText:_localName toLabel:self.localNameLabel];
}

- (void)setStatus:(NSString *)status {
    _status = status;
    [self bso_setText:_status toLabel:self.statusLabel];
}

- (void)bso_setText:(NSString *)text toLabel:(UILabel *)label {
    label.text = text.length ? text : AlternateText;
}

@end
