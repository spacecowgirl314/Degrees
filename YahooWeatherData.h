//
//  YahooWeatherData.h
//  WeatherDesktop
//
//  Created by Justin Dell on 10/26/08.
//  Copyright 2008 . All rights reserved.
//

//#import <Cocoa/Cocoa.h>


@interface YahooWeatherData : NSObject <NSXMLParserDelegate> {
    NSDictionary *codeToPicture;
    NSString *weather;
	NSString *units;
	NSString *sunrise;
	NSString *sunset;
    NSInteger code;
	NSInteger temperature;
	NSInteger forecastHigh;
	NSInteger forecastLow;
	NSInteger humidity;
	NSMutableArray *forecastDetails;
	int forecastNum;
}

-(YahooWeatherData *)init;
-(NSInteger)fetchDataWithZip:(NSString *)zipCode isCelsius:(BOOL)isCelsius;

// Helper methods used during parsing
-(NSError *)parseData:(NSData *)info;
-(NSString *)getPicture;
-(NSString *)getUnits;
-(NSString *)getConditions;
-(NSString *)getSunrise;
-(NSString *)getSunset;
-(NSInteger)getCode;
-(NSInteger)getTemperature;
-(NSInteger)getForecastHigh;
-(NSInteger)getForecastLow;
-(NSInteger)getHumidity;
-(NSArray *)getForecastDetails;

//@property (assign, readonly) int code;
//@property (copy, readonly) NSString *weather;

@end
