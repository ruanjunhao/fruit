//
//  NSString+IACExtensions.h
//  IACSample
//
//  Created by Antonio Cabezuelo Vivo on 10/02/13.
//  Copyright (c) 2013 Antonio Cabezuelo Vivo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IACExtensions)

- (NSString*)stringByAppendingURLParams:(NSDictionary*)params;

- (NSString *)stringByAppendingSubUrl:(NSString *)subUrl;

- (NSDictionary*)parseURLParams;

@end
