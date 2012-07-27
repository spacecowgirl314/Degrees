//
//  Weather.h
//  Degrees
//
//  Created by Chloe Stars on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "NSString+URLEncoding.h"

@interface Weather : NSObject {
    NSString *weather;
	NSString *sunrise;
	NSString *sunset;
    NSInteger code;
	NSInteger temperature;
	NSInteger forecastHigh;
	NSInteger forecastLow;
	NSInteger humidity;
}

-(NSInteger) fetchDataWithURL:(NSString*)url isCelsius:(BOOL)celsius;
-(NSInteger)fetchDataWithName:(NSString*)name isCelsius:(BOOL)celsius;
-(NSInteger)fetchDataWithLatidude:(double)latitude withLongitude:(double)longitude isCelsius:(BOOL)celsius;
-(NSString *)getConditions;
-(NSInteger)getCode;
-(NSInteger)getTemperature;
-(NSInteger)getForecastHigh;
-(NSInteger)getForecastLow;
-(NSInteger)getHumidity;
-(NSArray *)getForecastDetails;

@end
