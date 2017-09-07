//
//  NSObject+LZKVO.m
//  LZKVO
//
//  Created by Scott on 2017/9/6.
//  Copyright © 2017年 Scott. All rights reserved.
//

/*
 1.改变原有isa指针的指向
 2.重写setter方法
 3.通过消息发送机制执行回调函数（或者重写回调方法block）
 */

#import "NSObject+LZKVO.h"
#import <objc/message.h>

NSString *const LZKVOClassNamePrefix  = @"LZKVO";
NSString *const LZKVOAAssociatedInfos = @"LZVOAAssociatedInfos";

@implementation NSObject (LZKVO)

static Class kvo_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}


static NSString * setterSELWithKey(NSString *getter) {
    if (getter.length <= 0) return  nil;
    
    return [NSString stringWithFormat:@"set%@:",[getter capitalizedString]];
}


static NSString * keyWithSetterSEL(NSString *setter) {
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    return [[setter substringWithRange:NSMakeRange(3, setter.length - 4)] lowercaseString];
}


static void kvo_setter(id self, SEL _cmd, id newValue) {
    NSString *setterSEL = NSStringFromSelector(_cmd);
    NSString *key = keyWithSetterSEL(setterSEL);
    
    NSAssert(key != nil, @"Object does not have setter");
    
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    NSDictionary *currentInfo;
    NSMutableArray *infos = objc_getAssociatedObject(self, &LZKVOAAssociatedInfos);
    for (NSDictionary *info in infos) {
        if ([info[@"keyPath"] isEqualToString:key]) {
            currentInfo = info;
            break;
        };
    }
    
    void (*lz_objc_msgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;
    lz_objc_msgSendSuper(&superClazz, _cmd, newValue);
    
    if (!currentInfo) return;
    
    NSMutableDictionary * change = [NSMutableDictionary dictionary];
    
    NSUInteger options = [currentInfo[@"options"] unsignedIntegerValue];
    
    if (options & NSKeyValueObservingOptionNew) {
        [change setObject:newValue forKey:@"new"];
    }
    
    if (options & NSKeyValueObservingOptionOld) {
        [change setObject:[self valueForKey:key] forKey:@"old"];
    }
    
    void (*lz_objc_msgSend)(id, SEL, NSString *, id, NSDictionary *, void *) = (void *)objc_msgSend;
    lz_objc_msgSend(currentInfo[@"observer"],
                    @selector(observeValueForKeyPath:ofObject:change:context:),
                    key,
                    self,
                    [change copy],
                    nil);
}


- (void)lz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    Class originClass = object_getClass(self);
    NSString *originClassName = NSStringFromClass(originClass);
    
    if (![originClassName hasPrefix:LZKVOClassNamePrefix]) {
        Class kvoClazz = [self makeKVOClassWithOriginClassName:originClassName];
        object_setClass(self, kvoClazz);
    }
    
    SEL setterSelector = NSSelectorFromString(setterSELWithKey(keyPath));
    
    if (![self hasSelector: setterSelector]) {
        Method setterMethod = class_getInstanceMethod(originClass, setterSelector);
        const char *types = method_getTypeEncoding(setterMethod);
        class_addMethod(object_getClass(self), setterSelector, (IMP)kvo_setter, types);
        
        NSMutableArray *infos = objc_getAssociatedObject(self, &LZKVOAAssociatedInfos);
        
        if (!infos) {
            infos = [NSMutableArray array];
            objc_setAssociatedObject(self, &LZKVOAAssociatedInfos, infos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        [infos addObject:@{
                           @"observer": observer,
                           @"keyPath" : keyPath,
                           @"options" : @(options)
                           }];
    }
}


-(void)lz_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    NSMutableArray *infos = objc_getAssociatedObject(self, &LZKVOAAssociatedInfos);
    
    NSDictionary *infoRemove;
    
    for (NSDictionary *info in infos) {
        NSObject *infoObsever = info[@"observer"];
        NSString *infoKeyPath = info[@"keyPath"];
        if (infoObsever == observer && infoKeyPath == keyPath) {
            infoRemove = info;
        }
    }
    if (!infoRemove) return;
    [infos removeObject:infoRemove];
}


- (Class)makeKVOClassWithOriginClassName:(NSString *)originClassName {
    Class originClass = NSClassFromString(originClassName);
    
    NSString *kvoClassName = [LZKVOClassNamePrefix stringByAppendingString:originClassName];
    Class clazz = NSClassFromString(kvoClassName);
    
    if (clazz) return clazz;
    
    Class kvoClass = objc_allocateClassPair(originClass, kvoClassName.UTF8String, 0);
    
    Method method = class_getInstanceMethod(originClass, @selector(class));
    const char *types = method_getTypeEncoding(method);
    class_addMethod(kvoClass, @selector(class), (IMP)kvo_class, types);
    
    objc_registerClassPair(kvoClass);
    
    return kvoClass;
}


- (BOOL)hasSelector:(SEL)selector {
    
    Class clazz = object_getClass(self);
    
    unsigned int methodCount = 0;
    
    Method *methodList = class_copyMethodList(clazz, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL thisSetector = method_getName(methodList[i]);
        if (thisSetector == selector) {
            free(methodList);
            return YES;
        }
    }
    
    free(methodList);
    return NO;
}

@end
