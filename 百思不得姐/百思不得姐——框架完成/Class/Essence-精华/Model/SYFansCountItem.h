//
//  SYFansCountItem.h
//  百思不得姐——框架完成
//
//  Created by 码农界四爷__King on 16/7/4.
//  Copyright © 2016年 码农界四爷__King. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYHeaderItems;
@interface SYFansCountItem : NSObject
//头像
@property (nonatomic,strong) SYHeaderItems *header;

//名字
@property (nonatomic,strong) NSString *name;

//是否VIP
@property (nonatomic,assign,getter=isVip) BOOL jie_v;

//昨日涨粉数
@property (nonatomic,strong) NSString *fans_count;
@end
