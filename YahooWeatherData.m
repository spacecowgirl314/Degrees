//
//  YahooWeatherData.m
//  WeatherDesktop
//
//  Created by Justin Dell on 10/26/08.
//  Copyright 2008 . All rights reserved.
//

#import "YahooWeatherData.h"

//static NSString *weatherURL = @"http://weather.yahooapis.com/forecastrss?p=";
static NSString *weatherURL = @"http://xml.weather.yahoo.com/forecastrss/";
static NSString *testZip = @"99999";

@implementation YahooWeatherData

//@synthesize weather, code;

/**
 *  Initializes a new instance of YahooWeatherData and sets up the dictionary
 */
-(YahooWeatherData *)init {
    if ( self = [super init] ) {
        code = -1;
		forecastNum = 0;
		forecastDetails = [[NSMutableArray alloc] init];
        codeToPicture = [NSDictionary dictionaryWithObjectsAndKeys:
            @"tornado.jpg", @"0",       @"thunderstorm.jpg", @"1",      @"thunderstorm.jpg", @"2",
            @"thunderstorm.jpg", @"3",  @"thunderstorm.jpg", @"4",      @"rain.jpg", @"5",
            @"rain.jpg", @"6",          @"rain.jpg", @"7",              @"lightrain.jpg", @"8",
            @"lightrain.jpg", @"9",     @"lightrain.jpg", @"10",        @"lightrain.jpg", @"11",
            @"lightrain.jpg", @"12",    @"snow.jpg", @"13",             @"snow.jpg", @"14",
            @"heavysnow.jpg", @"15",    @"heavysnow.jpg", @"16",        @"rain.jpg", @"17",
            @"rain.jpg", @"18",         @"fog.jpg", @"19",              @"fog.jpg", @"20",
            @"fog.jpg", @"21",          @"fog.jpg", @"22",              @"wind.jpg", @"23",
            @"wind.jpg", @"24",         @"heavysnow.jpg", @"25",        @"cloudy.jpg", @"26",
            @"cloudynight.jpg", @"27",  @"cloudyday.jpg", @"28",        @"cloudynight.jpg", @"29",
            @"cloudyday.jpg", @"30",    @"night.jpg", @"31",            @"day.jpg", @"32",
            @"night.jpg", @"33",        @"day.jpg", @"34",              @"rain.jpg", @"35",
            @"hot.jpg", @"36",          @"thunderstorm.jpg", @"37",     @"thunderstorm.jpg", @"38",
            @"thunderstorm.jpg", @"39", @"rain.jpg", @"40",             @"heavysnow.jpg", @"41",
            @"snow.jpg", @"42",         @"heavysnow.jpg", @"43",        @"cloudy.jpg", @"44",
            @"thunderstorm.jpg", @"45", @"snow.jpg", @"46",             @"thunderstorm.jpg", @"47",
            nil];
    }

    return self;
}

/**
 *  Fetches data from yahoo weather given the zip code.
 *  Returns nil on success and the error pointer if failed, along with an alert pop-up
 */
-(NSInteger)fetchDataWithZip:(NSString *)zipCode isCelsius:(BOOL)isCelsius {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURLRequest *request;
	if (isCelsius == FALSE) {
		request = [NSURLRequest requestWithURL:
								 [NSURL URLWithString:[NSString stringWithFormat:@"%@%@_f.xml", weatherURL, zipCode]]
												 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	}
	else {
		request = [NSURLRequest requestWithURL:
								 [NSURL URLWithString:[NSString stringWithFormat:@"%@%@_c.xml", weatherURL, zipCode]]
												 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	}
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    NSData *returnedData = [[NSData alloc] init];
    if ([zipCode compare:testZip] == NSOrderedSame) {
        returnedData = [NSData 
            dataWithContentsOfFile:@"/Users/justindell/Desktop/Weather Desktop/SampleFetchData"];
    }
    else {
        returnedData = [NSURLConnection sendSynchronousRequest:request 
            returningResponse:&response error:&error];
    }
    
    if (returnedData == nil) {
        [pool release];
        return -1;
    }
    else {
        if ([self parseData:returnedData] != nil) {
            [pool release];
            return -1;
        }
        [pool release];
        return 0;
    }
}

/**
 *  Parses the retrieved data from yahoo
 */
- (NSError *)parseData:(NSData *)info {
    BOOL success;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:info];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    success = [parser parse];
    if (success == NO) {
        return [parser parserError];
    }
    //[parser release];
    return nil;
}

/**
 *  Gets the picture using the lookup dictionary
 */
-(NSString *)getPicture {
    if (code != -1) {
        NSString *codeStr  = [NSString stringWithFormat:@"%d", code];
        NSString *pic = [codeToPicture objectForKey:codeStr];
        return pic;
    }
    else return @"";
}

/**
 * Returns temperature measurement units
 */
-(NSString *)getUnits {
	return units;
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

-(NSString *)getSunrise {
	return sunrise;
}

-(NSString *)getSunset {
	return sunset;
}

-(NSArray *)getForecastDetails {
	return [[forecastDetails copy] autorelease];
}

// Delegate method called when XML node is found
- (void)parser:(NSXMLParser *)parser 
    didStartElement:(NSString *)elementName 
    namespaceURI:(NSString *)namespaceURI 
    qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {
    if ( [elementName isEqualToString:@"yweather:condition"]) {
        weather = [[attributeDict objectForKey:@"text"] retain];
        code = [[attributeDict objectForKey:@"code"] integerValue];
		temperature = [[attributeDict objectForKey:@"temp"] integerValue];
    }
	else if ( [elementName isEqualToString:@"yweather:units"]) {
		units = [[attributeDict objectForKey:@"temperature"] retain];
	}
	else if ( [elementName isEqualToString:@"yweather:forecast"]) {
		// Only use the first forecast for today.
		if (forecastNum == 0) {
			forecastHigh = [[attributeDict objectForKey:@"high"] integerValue];
			forecastLow = [[attributeDict objectForKey:@"low"] integerValue];
		}
		[forecastDetails addObject:[[NSString alloc] initWithFormat:@"%@ - %@. High: %@ Low: %@", 
									[[attributeDict objectForKey:@"day"] retain],
									[[attributeDict objectForKey:@"text"] retain],
									[[attributeDict objectForKey:@"high"] retain],
									[[attributeDict objectForKey:@"low"] retain]]];
		forecastNum++;
	}
	else if ( [elementName isEqualToString:@"yweather:astronomy"]) {
		sunrise = [[attributeDict objectForKey:@"sunrise"] retain];
		sunset = [[attributeDict objectForKey:@"sunset"] retain];
	}
	else if ( [elementName isEqualToString:@"yweather:atmosphere"]) {
		humidity = [[attributeDict objectForKey:@"humidity"] integerValue];
	}
}

@end
