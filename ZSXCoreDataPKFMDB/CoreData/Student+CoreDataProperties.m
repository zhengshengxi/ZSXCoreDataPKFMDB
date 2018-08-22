//
//  Student+CoreDataProperties.m
//  ZSXCoreDataPKFMDB
//
//  Created by yh-zsx on 2018/8/22.
//  Copyright © 2018年 yh-zsx. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Student"];
}

@dynamic name;
@dynamic age;
@dynamic sex;

@end
