//
//  NSObject+LZKVO.h
//  LZKVO
//
//  Created by Scott on 2017/9/6.
//  Copyright © 2017年 Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LZKVO)


- (void)lz_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context;

-(void)lz_removeObserver:(NSObject *)observer
              forKeyPath:(NSString *)keyPath
                 context:(void *)context;

@end
