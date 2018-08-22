//
//  ViewController.m
//  ZSXCoreDataPKFMDB
//
//  Created by yh-zsx on 2018/8/22.
//  Copyright © 2018年 yh-zsx. All rights reserved.
//

#import "ViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Student+CoreDataProperties.h"
#import "FMDatabase.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *txtView;

@end

@implementation ViewController {
    FMDatabase *db;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDB];
}

-(void)createDB {
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docuPath stringByAppendingPathComponent:@"test.db"];
    NSLog(@"!!!dbPath = %@",dbPath);
    //创建对应路径下数据库
    db = [FMDatabase databaseWithPath:dbPath];
    //3.在数据库中进行增删改查操作时，需要判断数据库是否open，如果open失败，可能是权限或者资源不足，数据库操作完成通常使用close关闭数据库
    [db open];
    if (![db open]) {
        NSLog(@"db open fail");
        return;
    }
    //4.数据库中创建表（可创建多张）
    NSString *sql = @"create table if not exists t_student ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,'name' TEXT NOT NULL, 'age' INTEGER NOT NULL,'sex' INTEGER NOT NULL)";
    //5.执行更新操作 此处database直接操作，不考虑多线程问题，多线程问题，用FMDatabaseQueue 每次数据库操作之后都会返回bool数值，YES，表示success，NO，表示fail,可以通过 @see lastError @see lastErrorCode @see lastErrorMessage
    BOOL result = [db executeUpdate:sql];
    if (result) {
        NSLog(@"create table success");
    }
    [db close];
}

- (IBAction)runAction:(UIButton *)sender {
    NSDate* tmpStartData = [NSDate date];
    int count = 1000;
    for (int i = 0; i < count; i++) {
        Student *entity = [Student MR_createEntity];
        entity.name = [NSString stringWithFormat:@"%d",i];
        entity.sex = 1;
        entity.age = 20;
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    }
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@",_txtView.text,[NSString stringWithFormat:@"CoreData(多次保存)写入%d条数据耗时 = %f",count,deltaTime]];
    
    
    tmpStartData = [NSDate date];
    for (int i = 0; i < count; i++) {
        Student *entity = [Student MR_createEntity];
        entity.name = [NSString stringWithFormat:@"%d",i];
        entity.sex = 1;
        entity.age = 20;
    }
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@",_txtView.text,[NSString stringWithFormat:@"CoreData(一次性保存)写入%d条数据耗时 = %f",count,deltaTime]];
    
    
    tmpStartData = [NSDate date];
    [db open];
    for (int i = 0; i < count; i++) {
        [db executeUpdate:@"insert into 't_student'(name,age,sex) values(?,?,?)" withArgumentsInArray:@[[NSString stringWithFormat:@"%d",i],@20,@1]];
    }
    [db close];
    deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    NSLog(@"FMDB(非事务方式处理)写入%d条数据耗时 = %f",count,deltaTime);
    _txtView.text = [NSString stringWithFormat:@"%@\n%@",_txtView.text,[NSString stringWithFormat:@"FMDB(一次性保存)写入%d条数据耗时 = %f",count,deltaTime]];
    
    
    tmpStartData = [NSDate date];
    [db open];
    //1.开启事务
    [db beginTransaction];
    BOOL rollBack = NO;
    @try {
        for (int i = 0; i < count; i++) {
            [db executeUpdate:@"insert into 't_student'(name,age,sex) values(?,?,?)" withArgumentsInArray:@[[NSString stringWithFormat:@"%d",i],@20,@1]];
        }
    } @catch(NSException *exception){
        //3.在事务中执行任务失败，退回开启事务之前的状态
        rollBack = YES;
        [db rollback];
    } @finally{
        //4. 在事务中执行任务成功之后
        rollBack = NO;
        [db commit];
    }
    [db close];
    deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@\n\n",_txtView.text,[NSString stringWithFormat:@"FMDB(事务方式处理)写入%d条数据耗时 = %f",count,deltaTime]];
}
- (IBAction)findAction:(UIButton *)sender {
    NSDate* tmpStartData = [NSDate date];
    NSArray *arr = [Student MR_findByAttribute:@"sex" withValue:@1];
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@",_txtView.text,[NSString stringWithFormat:@"CoreData查询到%ld条数据耗时 = %f",arr.count,deltaTime]];
    
    
    tmpStartData = [NSDate date];
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from 't_student' where sex = ?" withArgumentsInArray:@[@1]];
    NSMutableArray *mArr = [NSMutableArray new];
    while ([result next]) {
        int age = [result intForColumn:@"age"];
        [mArr addObject:@(age)];
    }
    [db close];
    deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@\n\n",_txtView.text,[NSString stringWithFormat:@"FMDB查询到%ld条数据耗时 = %f",mArr.count,deltaTime]];
}
- (IBAction)deleteAction:(UIButton *)sender {
    NSDate* tmpStartData = [NSDate date];
    NSArray *arr = [Student MR_findByAttribute:@"sex" withValue:@1];
    for (Student *entity in arr) {
        [entity MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@",_txtView.text,[NSString stringWithFormat:@"CoreData删除所有数据耗时 = %f",deltaTime]];
    
    
    tmpStartData = [NSDate date];
    [db open];
    [db executeUpdate:@"delete from 't_student' where sex = ?" withArgumentsInArray:@[@1]];
    deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    [db close];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@\n\n",_txtView.text,[NSString stringWithFormat:@"FMDB删除所有数据耗时 = %f",deltaTime]];
}
- (IBAction)updateAction:(UIButton *)sender {
    NSDate* tmpStartData = [NSDate date];
    NSArray *arr = [Student MR_findByAttribute:@"sex" withValue:@1];
    for (Student *entity in arr) {
        entity.age = 21;
    }
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@",_txtView.text,[NSString stringWithFormat:@"CoreData更新所有数据1个字段耗时 = %f",deltaTime]];
    
    
    tmpStartData = [NSDate date];
    [db open];
    [db executeUpdate:@"update 't_student' set age = ? where sex = ?" withArgumentsInArray:@[@21,@1]];
    deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    [db close];
    _txtView.text = [NSString stringWithFormat:@"%@\n%@\n\n",_txtView.text,[NSString stringWithFormat:@"FMDB更新所有数据1个字段耗时 = %f",deltaTime]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
