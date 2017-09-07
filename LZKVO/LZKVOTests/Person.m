//
//  Person.m
//  LZKVO
//
//  Created by Scott on 2017/9/6.
//  Copyright © 2017年 Scott. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        self.nickname = change[@"new"];
    }
}

@end
