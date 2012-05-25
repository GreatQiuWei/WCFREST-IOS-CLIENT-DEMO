//
//  ViewController.m
//  consumerest
//
//  Created by Damiano Fusco on 5/18/12.
//  Copyright (c) 2012 Shallow Waters Group LLC. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

// The following are constants for the URLs of our API.
// Please update these to point to your Visual Studio WCFREST.WebAppAPI application.
// My suggestion is to create an IIS website on your PC and use host headers, so that you can have a friendly name like WCFREST.
// To use host headers on the PC, navigate to "C:\Windows\System32\drivers\etc". Open the file "hosts" with Notepad and add an entry like this "127.0.0.1   WCFREST"
// In IIS, make sure you have setup a Website pointing to the WCFREST.WebAppAPI, and that you update the site bindings to have Port 80 and the Host Name value as "WCFREST".

// I prefer to always use hosts headers when I develop Websites or Web Applications in Visual Studio (and also on OSX). This allows me to have friendly URLs like "http://wcfrest/Login.ashx", instead of using localhost or an IP address.

// In OSX, the "hosts" file is located under "/private/etc/" and it is called "hosts"
// You might want to add an entry like "192.168.2.6     wcfrest", where the IP address is the address of your PC running the WCFREST demo app.
// Please note that you might have Windows running in VirtualBox or Parallels on the Mac, and this setup will work as well in those cases.

#define kApiLoginURL @"http://wcfrest/Login.ashx"
#define kApiGetPeopleURL @"http://wcfrest/CustomService/GetPeopleWithPOST"


@interface ViewController ()

@end

@implementation ViewController
@synthesize textFieldUser;
@synthesize textFieldPassword;
@synthesize textFieldDebug;


@synthesize 
textFieldOutput,
textHttpStatus;

- (void)viewDidLoad
{
    self.textHttpStatus.text = @"";
    self.textFieldDebug.text = @"";
    self.textFieldOutput.text = @"";
    
    self.textHttpStatus.enabled = false;
    self.textFieldDebug.editable = false;
    self.textFieldOutput.editable = false;
    
    self.textFieldUser.text = @"me@you.com";
    self.textFieldPassword.text = @"pw";
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTextFieldOutput:nil];
    [self setTextHttpStatus:nil];
    [self setTextFieldDebug:nil];
    [self setTextFieldUser:nil];
    [self setTextFieldPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)addToTextFieldDebug:(NSString*)str
{
    NSLog(@"%@", str);
    self.textFieldDebug.text = [str stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", self.textFieldDebug.text]];  
}

-(void)getCookieFromResponse:(NSURLResponse*)response
                        data:(NSData*)data
                       error:(NSError*)error
{
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self addToTextFieldDebug:[NSString stringWithFormat:@"getCookieFromResponse %@", jsonData]];
    
    NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpURLResponse statusCode];
    self.textHttpStatus.text = [NSString stringWithFormat:@"%d", statusCode];
    
    int errorCode = 0;
    if(error)
    {
        errorCode = [error code];
        [self addToTextFieldDebug:[NSString stringWithFormat:@"getCookieFromResponse %d: %@", errorCode, [error localizedDescription]]];  
    }
    
    //NSHTTPURLResponse statusCode -1012 is the same as 401 unauthorized
    if (errorCode < 0 && errorCode != -1012) 
    {
        [self addToTextFieldDebug:[NSString stringWithFormat:@"getCookieFromResponse UNHANDLED errorCode %d: %@", errorCode, [error localizedDescription]]];  
    } 
    else if (errorCode == -1012) 
    {
        [self addToTextFieldDebug:@"getCookieFromResponse WRONG user and/or password"];  
    } 
    else 
    {
        NSDictionary *fields = [httpURLResponse allHeaderFields];
        NSString *setCookie = [fields valueForKey:@"Set-Cookie"]; // It is your cookie
        [self addToTextFieldDebug:[NSString stringWithFormat:@"getCookieFromResponse setCookie %@", setCookie]];
        
        for(id item in fields)
        {
            [self addToTextFieldDebug:[NSString stringWithFormat:@"getCookieFromResponse header item %@", item]];
        }
        
        [[AppDelegate instance] setCookie:setCookie];
        [self callServiceGetPeople:[AppDelegate instance].cookie];
    }
}

-(void)requestCookie
{
    NSString *user = self.textFieldUser.text;
    NSString *pwd = self.textFieldPassword.text;
    
    NSArray *keys = [NSArray arrayWithObjects:@"UserName", @"Password", nil];
    NSArray *objects = [NSArray arrayWithObjects:user, pwd, nil];
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects 
                                                               forKeys:keys];
    NSData *jsonData = nil;
    NSString *jsonString = nil;
    
    if([NSJSONSerialization isValidJSONObject:jsonDictionary])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self addToTextFieldDebug:[NSString stringWithFormat:@"requestCookie %@", jsonString]];
    }
    
    NSURL *url = [NSURL URLWithString:kApiLoginURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    //[request setValue:jsonString forHTTPHeaderField:@"json"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    //NSError *errorReturned = nil;
    //NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    //NSData *data = [NSURLConnection sendSynchronousRequest:request 
    //                                     returningResponse:&theResponse error:&errorReturned];
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self getCookieFromResponse:response
                                                      data:data
                                                     error:error];
                           }];
}

-(void)readResponse:(NSURLResponse*)response
               data:(NSData*)data
              error:(NSError*)error
{
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.textFieldOutput.text = jsonData;
    
    NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpURLResponse statusCode];
    
    self.textHttpStatus.text = [NSString stringWithFormat:@"%d", statusCode];
    
    if(statusCode != 200)
    {
        [self requestCookie];
    }
    else 
    {
        NSError* error;
        NSArray* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions 
                                                               error:&error];
        id person = [json objectAtIndex:0];
        NSString* firstName = [person objectForKey:@"FirstName"];
        NSString* lastName = [person objectForKey:@"LastName"];
        NSString* personID = [person objectForKey:@"PersonID"];
        NSLog(@"Person: %@ %@ %@", personID, firstName, lastName);
        
        NSDictionary *fields = [httpURLResponse allHeaderFields];
        for(id item in fields)
        {
            [self addToTextFieldDebug:[NSString stringWithFormat:@"readResponse header %@", item]];
        }
    }
}

-(void)callServiceGetPeople:(NSString*)strCookie
{
    //NSArray *keys = [NSArray arrayWithObjects:@"referenceName", nil];
    //NSArray *objects = [NSArray arrayWithObjects:@"test", nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"Keyword", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"o", nil];
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects 
                                                               forKeys:keys];
    
    NSData *jsonData = nil;
    NSString *jsonString = nil;
    
    if([NSJSONSerialization isValidJSONObject:jsonDictionary])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self addToTextFieldDebug:[NSString stringWithFormat:@"callServiceGetPeople %@", jsonString]];
    }
    
    NSURL *url = [NSURL URLWithString:kApiGetPeopleURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    //[request setValue:jsonString forHTTPHeaderField:@"json"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setValue:strCookie forHTTPHeaderField:@"Cookie"];
    
    //NSError *errorReturned = nil;
    //NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    //NSData *data = [NSURLConnection sendSynchronousRequest:request 
    //                                     returningResponse:&theResponse error:&errorReturned];
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self readResponse:response
                                             data:data
                                            error:error];
                           }];
}


- (IBAction)btnCallService:(id)sender 
{
    self.textHttpStatus.text = @"";
    self.textFieldDebug.text = @"";
    self.textFieldOutput.text = @"";
    
    [self callServiceGetPeople:[[AppDelegate instance] cookie]];
    
    //NSURL *url = [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"];
    
}

- (IBAction)btnClearCookie:(id)sender 
{
    self.textHttpStatus.text = @"";
    self.textFieldDebug.text = @"";
    self.textFieldOutput.text = @"";

    [[AppDelegate instance] setCookie:@""];
}

- (IBAction)btnBackground:(id)sender 
{
    [self.textFieldUser resignFirstResponder];
    [self.textFieldPassword resignFirstResponder];
}
@end
