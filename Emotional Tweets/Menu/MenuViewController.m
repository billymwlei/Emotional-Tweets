//
//  MenuViewController.m
//  Emotional Tweets
//
//  Created by Billy on 23/02/2014.
//  Copyright (c) 2014 Billy. All rights reserved.
//

#import "MenuViewController.h"
#import "TweetListViewController.h"
#import "Post.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UIView *loading;
@end

@implementation MenuViewController

#pragma mark - Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self setTitle:@"Test"];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [_searchText setText:@""];
}

#pragma mark - UI Action

- (IBAction)search:(id)sender {
    [self searchWithText:_searchText.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self searchWithText:textField.text];
    return NO;
}
#pragma mark - Private
-(void)searchWithText:(NSString *)text{
    if(text.length > 0){
        [_searchText resignFirstResponder];
        [_loading setHidden:NO];
        [Post fetchTweeterPostWithKeyWord:text andBlock:^(NSArray *posts, NSError *error){
			 [_loading setHidden:YES];
            if(error){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
				TweetListViewController *tweetListViewController = [[TweetListViewController alloc] init];
				tweetListViewController.posts = posts;
				[self.navigationController pushViewController:tweetListViewController animated:YES];
			}
        }];
    }
}

@end
