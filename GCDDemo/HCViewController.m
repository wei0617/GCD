//
//  HCViewController.m
//  GCDDemo
//
//  Created by Hungry Wolf on 15-7-2.
//  Copyright (c) 2015年 Hungry Wolf. All rights reserved.
//

#import "HCViewController.h"

@interface HCViewController ()

@end

@implementation HCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// GCD, grand centrol dispatch 调度中心,用于控制和操作多线程
    
    _queue = dispatch_queue_create("queue", NULL);
    for (int i = 0; i < 10; ++i) {
        dispatch_async(_queue, ^{
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%d",i);
        });
    }
    
//    [self gcdUsingContine];
//    [self gcdUsingContinue2];
//    [self gcdUsingContinue3];
    [self gcdUsingContinue4];
//    [self gcdUsingContinue5];
}

- (IBAction)serialQueueClick:(id)sender {
    
    // dispatch_queue_t 线程队列
    // dispatch_queue_create 创建一个线程队列,第一个参数是队列名字,第二个参数是队列类型
    // DISPATCH_QUEUE_SERIAL 或用(NULL) 串行队列
    dispatch_queue_t queue = dispatch_queue_create("wei", DISPATCH_QUEUE_SERIAL);
    // 串行队列中block只能一个一个执行
    
    
    // dispatch_async 在一个队列中异步放入一个block(把block放入队列后不等待block执行完毕,当前代码继续执行)
    dispatch_async(queue, ^{
        NSLog(@"%@",[NSThread isMainThread] ? @"主线程" : @"分线程");
        // 让线程休眠多长时间
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%@",[NSThread currentThread]);
    });
    
    
    // dispatch_sync 在一个队列中同步放入一个block(把block放入队列后,等待block执行完毕,当前代码再继续执行)
    //    dispatch_sync(queue, ^{
    //        NSLog(@"%@",[NSThread isMainThread] ? @"主线程" : @"分线程");
    //        //
    //        [NSThread sleepForTimeInterval:2];
    //        NSLog(@"123");
    //    });
    //    dispatch_sync(queue, ^{
    //        [NSThread sleepForTimeInterval:2];
    //        NSLog(@"123");
    //    });
    //    dispatch_sync(queue, ^{
    //        [NSThread sleepForTimeInterval:2];
    //        NSLog(@"123");
    //    });
    
 
    // _sync会卡主, 改成 _async 就不会卡住
    //    dispatch_sync(queue, ^{
    //        NSLog(@"1");
    //        dispatch_sync(queue, ^{
    //            NSLog(@"2");
    //        });
    //        NSLog(@"3");
    //    });
    //    NSLog(@"4");
    
    dispatch_async(queue, ^{
        NSLog(@"1");
        dispatch_async(queue, ^{
            NSLog(@"2");
        });
        NSLog(@"3");
    });
    NSLog(@"4");
    // 输出顺序是 4 1 3 2

    
    // 非ARC下队列需要release
    //dispatch_release(queue);
}

- (IBAction)concurrentQueueClick:(id)sender {
    
    // 并行队列使用时一般不需要创建,直接找到系统并行队列即可
    // 第一个参数是队列的优先级
    // 放入并行队列的block会被立刻开启一个新的线程执行
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSLog(@"%@",[NSThread isMainThread] ? @"主线程" : @"分线程");
        //
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%@",[NSThread currentThread]);
    });
    
    //    dispatch_sync(queue, ^{
    //        NSLog(@"%@",[NSThread isMainThread] ? @"主线程" : @"分线程");
    //        //
    //        [NSThread sleepForTimeInterval:2];
    //        NSLog(@"123");
    //    });
    //    dispatch_sync(queue, ^{
    //        [NSThread sleepForTimeInterval:2];
    //        NSLog(@"123");
    //    });
    //    dispatch_sync(queue, ^{
    //        [NSThread sleepForTimeInterval:2];
    //        NSLog(@"123");
    //    });
}

- (IBAction)mainQueueClick:(id)sender {
    // dispatch_get_main_queue 获得主线程队列
    // 主线程队列是串行队列
    
    // 串行队列的代码中,不能再同步再往本队列中添加block,否则会导致线程和block互相等待,造成线程卡死
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 一定不要写成 dispatch_sync,会卡死主线程
    dispatch_async(queue, ^{
        NSLog(@"%@",[NSThread isMainThread] ? @"主线程" : @"分线程");
    });
    
    NSLog(@"123");
    // 会先输出123,主线程里的block代码等主线程闲置时最后执行
    
}

- (IBAction)suspendQueueClick:(id)sender {
    // 暂停一个队列,暂停队列时继续执行的block会继续执行,处于等待中的block不再执行,直到继续为止
    dispatch_suspend(_queue);
}

- (IBAction)resumeQueqeClick:(id)sender {
    // 继续一个队列
    dispatch_resume(_queue);
}

- (void)gcdUsingContine
{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray *arr = [NSMutableArray array];
    //  准备数组
    for (int i=0; i<100; i++) {
        [arr addObject:[NSNumber numberWithInt:i]];
    }
    for (int i=0; i<arr.count; i++) {
        dispatch_async(queue1, ^{
            //  平行运算，执行
//            NSLog(@"%@", [arr objectAtIndex:i]);
            NSLog(@"后执行");
        });
    }
    
    NSLog(@"先执行，在for循环还没执行完就输出了");
}

//  使用dispatch_group_async + dispatch_group_wait
- (void)gcdUsingContinue2
{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group1 = dispatch_group_create();
    NSMutableArray *arr = [NSMutableArray array];
    //  准备数组
    for (int i=0; i<100; i++) {
        [arr addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i=0; i<arr.count; i++) {
        dispatch_group_async(group1, queue1, ^{
            //  平行运算，执行
//            NSLog(@"%@", [arr objectAtIndex:i]);
            NSLog(@"先执行");
        });
    }
    
    //  等上面的for循环(等待group里的线程)都执行完了，再执行下面的内容
    dispatch_group_wait(group1, DISPATCH_TIME_FOREVER);
    NSLog(@"后执行 ,for循环执行完后，再输出");
}

//  使用dispatch_group_async + dispatch_group_notify
- (void)gcdUsingContinue3
{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group1 = dispatch_group_create();
    NSMutableArray *arr = [NSMutableArray array];
    //  准备数组
    for (int i=0; i<100; i++) {
        [arr addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i=0; i<arr.count; i++) {
        dispatch_group_async(group1, queue1, ^{
            //  平行运算，执行
//            NSLog(@"%@", [arr objectAtIndex:i]);
            NSLog(@"先执行");
        });
    }
    
    dispatch_group_notify(group1, queue1, ^{
        
        //  如果是等上面的线程都操作完，更改UI，那么queue1换成主线程即可
        NSLog(@"for循环执行完后，再输出");
    });
}

//  使用dispatch_apply，同步版
- (void)gcdUsingContinue4
{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group1 = dispatch_group_create();
    NSMutableArray *arr = [NSMutableArray array];
    //  准备数组
    for (int i=0; i<100; i++) {
        [arr addObject:[NSNumber numberWithInt:i]];
    }
    
    //  dispatch_apply是同步的，没有异步版本。
    dispatch_apply(arr.count, queue1, ^(size_t index) {
        //  平行运算，执行
//        NSLog(@"%@", [arr objectAtIndex:index]);
        NSLog(@"22222-------先执行");
    });
    NSLog(@"222222-------后执行，执行完上面的再执行此行");
    
    
}

//  使用dispatch_apply，异步版
- (void)gcdUsingContinue5
{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray *arr = [NSMutableArray array];
    //  准备数组
    for (int i=0; i<100; i++) {
        [arr addObject:[NSNumber numberWithInt:i]];
    }
    
    //  如果要让dispatch_apply异步，达到上述同样效果，那么
    dispatch_async(queue1, ^{
        dispatch_apply(arr.count, queue1, ^(size_t index) {
            //  平行运算，执行
            NSLog(@"%@", [arr objectAtIndex:index]);
            NSLog(@"333333-------先执行");
        });
        NSLog(@"3333333--------后执行，执行完上面的再执行此行");
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
