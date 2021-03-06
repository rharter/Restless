//
//  DRMethodDescriptionTests.m
//  Restless
//
//  Created by Nate Petersen on 9/21/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DRMethodDescription.h"
#import "Restless.h"
#import "GitHubService.h"

@interface DRMethodDescriptionTests : XCTestCase

@end

@implementation DRMethodDescriptionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testResultSubtypeParsing
{
	DRMethodDescription* desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray<NSURL*>*" }];
	XCTAssertEqual([desc resultSubtype], [NSURL class]);
	
	desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray<NSURL *> *" }];
	XCTAssertEqual([desc resultSubtype], [NSURL class]);
	
	desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray *" }];
	XCTAssertNil([desc resultSubtype]);
}

- (void)testHeaderParameterization
{
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	
	NSURLSessionUploadTask* task = [service updateProfilePic:[NSData data]
													   agent:@"test"
													callback:^(NSString *result, NSURLResponse *response, NSError *error) {}];
	
	NSDictionary* expectedHeaders = @{ @"Accept" : @"application/vnd.github.v3.full+json", @"User-Agent" : @"Sub: test" };
	NSDictionary* processedHeaders = task.originalRequest.allHTTPHeaderFields;
	
	XCTAssertEqualObjects(processedHeaders, expectedHeaders);
}

- (void)testQueryParameters
{
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	
	NSURLSessionUploadTask* task = [service updateProfilePic:[NSData data]
													   agent:@"test"
													  query1:@"firstQuery"
													  query2:@"secondQuery"
													callback:^(NSString *result, NSURLResponse *response, NSError *error) {}];
	
	NSURLComponents* comps = [NSURLComponents componentsWithURL:task.originalRequest.URL
										resolvingAgainstBaseURL:NO];
	
	NSArray* queryItems = comps.queryItems;
	
	XCTAssertEqual(queryItems.count, 2);
	
	NSURLQueryItem* item1 = queryItems.firstObject;
	XCTAssertEqualObjects(item1.name, @"query1");
	XCTAssertEqualObjects(item1.value, @"firstQuery");
	
	NSURLQueryItem* item2 = queryItems.lastObject;
	XCTAssertEqualObjects(item2.name, @"query2");
	XCTAssertEqualObjects(item2.value, @"secondQuery");
}

@end
