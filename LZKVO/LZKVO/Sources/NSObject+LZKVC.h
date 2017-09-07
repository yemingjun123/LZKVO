//
//  NSObject+LZKVC.h
//  LZKVO
//
//  Created by Scott on 2017/9/7.
//  Copyright © 2017年 Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LZKVC)

- (id)lz_valueForKey:(NSString *)key;

- (void)lz_setValue:(id)value forKey:(NSString *)key;

@end
