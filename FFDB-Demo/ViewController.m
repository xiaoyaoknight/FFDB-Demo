//
//  ViewController.m
//  FFDB-Demo
//
//  Created by zzzz on 2019/10/8.
//  Copyright © 2019 zzzz. All rights reserved.
//

#import "ViewController.h"
#import <FMDB/FMDB.h>

@interface ViewController ()

/// database
@property (nonatomic, strong) FMDatabase *database;

/// 路径
@property (nonatomic, copy) NSString *databasePath;

/// 队列
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self createSqlite];
//    [self createTable];
//    [self insert];
//    [self delete];
//    [self update];
//    [self select];
    [self queue];
}

/// 创建数据库
- (void)createSqlite {
    NSString *lidDirPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *databasePath = [lidDirPath stringByAppendingPathComponent:@"DatabaseDemo1.sqlite"];
    NSLog(@"%@", databasePath);
    // 根据指定的沙盒路径来创建数据对象，如果路径下的数据库不存在，就创建，如果存在就不创建
    self.database = [FMDatabase databaseWithPath:databasePath];
    if (self.database != nil) {
        NSLog(@"数据库创建成功!");
    } else {
        NSLog(@"数据库创建失败!");
    }
}

/// 创建表
- (void)createTable {
    // 所有的数据库SQL语句，都需要数据库打开之后才能操作
    if ([self.database open]) {
        NSString *createTableSql = @"create table if not exists User(id integer primary key autoincrement, username text not null, phone text not null, age integer)";
        BOOL result = [self.database executeUpdate:createTableSql];
        if (result) {
            NSLog(@"创建表成功");
        } else {
            NSLog(@"创建表失败");
        }
        // 每次执行完对应SQL之后，要关闭数据库
        [self.database close];
    }
}

/// 插入
- (void)insert {
    
    if ([self.database open]) {
        NSString *insertSql = @"insert into User(username, phone, age) values(?, ?, ?)";
        BOOL result = [self.database executeUpdate:insertSql, @"user01", @"110", @(18)];
        if (result) {
            NSLog(@"插入数据成功");
        } else {
            NSLog(@"插入数据失败");
        }
        [self.database close];
    }
}


/// 删除
- (void)delete {
    if ([self.database open]) {
        NSString *deleteSql = @"delete from User where username = ?";
        BOOL result = [self.database executeUpdate:deleteSql, @"user01"];
        if (result) {
            NSLog(@"删除数据成功");
        } else {
            NSLog(@"删除数据失败");
        }
        [self.database close];
    }
}

/// 更新
- (void)update {
    if ([self.database open]) {
        NSString *updateSql = @"update User set phone = ? where username = ?";
        BOOL result = [self.database executeUpdate:updateSql, @"15823456789", @"user01"];
        if (result) {
            NSLog(@"更新数据成功");
        } else {
            NSLog(@"更新数据失败");
        }
        [self.database close];
    }
}

/// 查询
- (void)select {
    if ([self.database open]) {
        NSString *selectSql = @"select * from User";
        FMResultSet *resultSet = [self.database executeQuery:selectSql];
        while ([resultSet next]) {
            NSString *username = [resultSet stringForColumn:@"username"];
            NSString *phone = [resultSet stringForColumn:@"phone"];
            NSInteger age = [resultSet intForColumn:@"age"];
            NSLog(@"username=%@, phone=%@, age=%ld \n", username, phone, age);
        }
        [self.database close];
    }
}


/*
  在多个线程中同时使用一个`FMDatabase`实例是不明智的。
  现在你可以为每个线程创建一个`FMDatabase`对象，不要让多个线程分享同一个实例，他无法在多个线程中同时使用。
  否则程序会时不时崩溃或者报告异常。所以，不要初始化FMDatabase对象，然后在多个线程中使用。
  这时候，我们就需要使 用FMDatabaseQueue来创建队列执行事务。
 */
- (void)queue {
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
    // // 要执行的SQL语句，要放在Block里执行，用inDatabase不用手动打开和关闭数据库
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        // 创建表，增加，删除，更新，查询 操作
        [self createSqlite];
        [self createTable];
        [self insert];
        [self update];
        [self select];
    }];
}
@end
