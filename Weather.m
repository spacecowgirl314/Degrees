//
//  Weather.m
//  Degrees
//
//  Created by Chloe Stars on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Weather.h"

#define WEATHER_SERVICE @"http://free.worldweatheronline.com/feed/weather.ashx?q=%f,%f&format=json&num_of_days=3&key=d8e7c62167235127111805"
#define WEATHER_SERVICE_2 @"http://free.worldweatheronline.com/feed/weather.ashx?q=%@&format=json&num_of_days=3&key=d8e7c62167235127111805"

@implementation Weather

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

// maybe now would be a good time to learn block code
- (NSInteger)fetchDataWithName:(NSString*)name isCelsius:(BOOL)celsius {
    // world weather online understands common sense input like Torrance, CA or London, UK
    NSString *url = [NSString stringWithFormat:WEATHER_SERVICE_2 , [name URLEncodedString]];
    return [self fetchDataWithURL:url isCelsius:celsius];
}

- (NSInteger) fetchDataWithLatidude:(double)latitude withLongitude:(double)longitude isCelsius:(BOOL)celsius  {
    NSString *url = [NSString stringWithFormat:WEATHER_SERVICE , latitude, longitude];
    return [self fetchDataWithURL:url isCelsius:celsius];
}

- (NSInteger) fetchDataWithURL:(NSString*)url isCelsius:(BOOL)celsius {
    NSArray *temperatureArray;
    NSArray *wind;
    
    //url is now passed through different types of requests
    //NSString *url = [NSString stringWithFormat:WEATHER_SERVICE , latitude, longitude];
    
    NSError *error;
    
    NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSASCIIStringEncoding error:&error];
    NSLog(@"jsonData: %@", jsonString);
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *weatherData = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
    
    NSDictionary *weatherData2 = [weatherData valueForKey:@"data"];
    NSDictionary *currentWeather = [weatherData2 valueForKey:@"current_condition"];
    NSDictionary *iconUrl = [currentWeather valueForKey:@"weatherIconUrl"];
    //NSDictionary *nextWeather = [weatherData2 valueForKey:@"weather"];
    
    
    // get conditions
    NSArray *conditionsA, *conditionsB;
    NSDictionary *weatherDesc = [currentWeather valueForKey:@"weatherDesc"];
    conditionsA = [weatherDesc valueForKey:@"value"];
    conditionsB = [conditionsA objectAtIndex:0];
    weather = [NSString stringWithFormat:@"%@",[conditionsB objectAtIndex:0]];
    
    // apply isCelsius stuff right here
    if (celsius) {
        temperatureArray = [currentWeather valueForKey:@"temp_C"];
    }
    else {
        temperatureArray = [currentWeather valueForKey:@"temp_F"];
    }
    wind = [currentWeather valueForKey:@"windspeedKmph"];
    
    // get code
    NSArray *codeArray = [currentWeather valueForKey:@"weatherCode"];
    code = [[NSString stringWithFormat:@"%@",[codeArray objectAtIndex:0]] intValue];
    
    // detecting night in the icon url name could be an advanced way of determing to use the moon or moon clouds
    NSArray *iconUrl2 = [iconUrl valueForKey:@"value"];
    NSArray *url2 = [iconUrl2 objectAtIndex:0];
    NSString *url3 = [url2 objectAtIndex:0];
    
    // set temperature
    temperature = [[NSString stringWithFormat:@"%@",[temperatureArray objectAtIndex:0]] intValue];
    
    
    //temperaturLabel.text = [NSString stringWithFormat:@"%@ %@",[temperatur objectAtIndex:0], @"°C"];
    //windLabel.text = [NSString stringWithFormat:@"%@ %@", [wind objectAtIndex:0],@"km/h"];
    
    //NSURL *urlIcon = [NSURL URLWithString: url3];
    //NSData *data = [NSData dataWithContentsOfURL:urlIcon];
    //UIImage *image = [[UIImage alloc] initWithData:data]; 
    //weatherIcon.image = image;
    //[image release];
    return 0;
}

/**
 * Returns weather conditions
 */
-(NSString *)getConditions {
	return weather;
}

/**
 * Returns the code
 */
-(NSInteger)getCode {
    return code;
}

/**
 * Returns the temperature
 */
-(NSInteger)getTemperature {
	return temperature;
}

-(NSInteger)getForecastHigh {
	return forecastHigh;
}

-(NSInteger)getForecastLow {
	return forecastLow;
}

-(NSInteger)getHumidity {
	return humidity;
}

- (void)dealloc
{
    [super dealloc];
}

@end
