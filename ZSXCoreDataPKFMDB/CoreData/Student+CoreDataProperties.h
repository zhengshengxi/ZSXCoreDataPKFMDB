//
//  Student+CoreDataProperties.h
//  ZSXCoreDataPKFMDB
//
//  Created by yh-zsx on 2018/8/22.
//  Copyright © 2018年 yh-zsx. All rights reserved.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int32_t age;
@property (nonatomic) int16_t sex;

@end

NS_ASSUME_NONNULL_END
