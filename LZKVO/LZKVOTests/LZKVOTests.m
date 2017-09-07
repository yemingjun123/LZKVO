//
//  LZKVOTests.m
//  LZKVOTests
//
//  Created by Scott on 2017/9/6.
//  Copyright © 2017年 Scott. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Person.h"
@import LZKVO;

@interface LZKVOTests : XCTestCase

@property (strong, nonatomic) Person *person;

@end

@implementation LZKVOTests

- (void)setUp {
    [super setUp];
    
    self.person = [[Person alloc] init];
    
    [self.person lz_addObserver:self.person forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)testExample {
    
    // KVC
    [self.person lz_setValue:@"scott" forKey:@"name"];
    XCTAssertTrue([self.person.name isEqualToString:@"scott"], @"kvc 赋值失败");
    
    NSString *name = [self.person lz_valueForKey:@"name"];
    XCTAssertTrue([name isEqualToString:@"scott"], @"kvc 取值失败");
    
    // KVO
    XCTAssertTrue([self.person.nickname isEqualToString:@"scott"], @"kvo 添加失败");
    
    [self.person lz_removeObserver:self.person forKeyPath:@"name" context:nil];
    [self.person lz_setValue:@"ryan" forKey:@"name"];
    
    XCTAssertTrue([self.person.nickname isEqualToString:@"scott"], @"kvo 移除失败");
}



@end
