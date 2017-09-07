//
//  NSObject+LZKVC.m
//  LZKVO
//
//  Created by Scott on 2017/9/7.
//  Copyright © 2017年 Scott. All rights reserved.
//

#import "NSObject+LZKVC.h"
#import <objc/message.h>

@implementation NSObject (LZKVC)

/* getter method */
- (id)lz_valueForKey:(NSString *)key {
    
    id value = nil;
    
    SEL sel = [self selectorWithName:key];
    
    if (!sel) return nil;
    
    id (*lz_objc_msgSend)(id, SEL) = (void *)objc_msgSend;
    
    value = lz_objc_msgSend(self, sel);
    
    return value;
}


/* setter method */
- (void)lz_setValue:(id)value forKey:(NSString *)key {
    
    key = [NSString stringWithFormat:@"set%@:",[key capitalizedString]];
    
    SEL sel = [self selectorWithName:key];
    
    if (!sel) return;
    
    void (*lz_objc_msgSend)(id, SEL, id) = (void *)objc_msgSend;
    
    lz_objc_msgSend(self, sel, value);
}


- (SEL)selectorWithName:(NSString *)name {

    Class clazz = [self class];
    
    unsigned int methodCount = 0;
    
    Method *methods = class_copyMethodList(clazz, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i ++) {
        SEL sel = method_getName(methods[i]);
        if ([NSStringFromSelector(sel) isEqualToString:name]) {
            free(methods);
            return sel;
        }
    }
    
    free(methods);
    return nil;
}

@end
