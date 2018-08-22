//
//  AppDelegate.h
//  ZSXCoreDataPKFMDB
//
//  Created by yh-zsx on 2018/8/22.
//  Copyright © 2018年 yh-zsx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

