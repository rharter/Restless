//
//  DRConverterFactory.h
//  Restless
//
//  Created by Nate Petersen on 9/8/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#ifndef DRConverterFactory_h
#define DRConverterFactory_h

@protocol DRConverter <NSObject>

- (id)convertData:(NSData*)data toObjectOfClass:(Class)cls;

- (NSData*)convertObjectToData:(id)object;

@optional

- (NSString*)convertObjectToString:(id)object;

@end


@protocol DRConverterFactory <NSObject>

- (id<DRConverter>)converter;

@end

#endif /* DRConverterFactory_h */
