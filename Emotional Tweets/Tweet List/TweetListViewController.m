//
//  TweetListViewController.m
//  Emotional Tweets
//
//  Created by Billy on 23/02/2014.
//  Copyright (c) 2014 Billy. All rights reserved.
//

#import "TweetListViewController.h"
#import "Post.h"

#define kUITagLabelUserName 1000
#define kUITagTextUserTweet 1001
#define kUITagLabelDate 1002
#define kUITagLabelStatus 1003

@interface TweetListViewController ()

@end

@implementation TweetListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [self setTitle:@"Tweet"];
     [self.tableView registerNib:[UINib nibWithNibName:@"TweetListCellView" bundle:nil] forCellReuseIdentifier:@"TweetListCellView"];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetListCellView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TweetListCellView" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    Post *post=[_posts objectAtIndex:indexPath.row];
    
    UILabel *user = (UILabel *)[cell viewWithTag:kUITagLabelUserName];
    [user setText:post.user];
    UITextField *text = (UITextField*)[cell viewWithTag:kUITagTextUserTweet];
    [text setText:post.text];
	UILabel *time = (UILabel *)[cell viewWithTag:kUITagLabelDate];
    [time setText:post.time];
    [post getStatusWithBlock:^(NSString *status, NSError *error) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		UILabel *statsLabel = (UILabel *)[cell viewWithTag:kUITagLabelStatus];
        if (!error && [[tableView indexPathsForVisibleRows] containsObject:indexPath]) {
            [statsLabel setText:status];
        } else {
			[statsLabel setText:@"N/A"];
		}
    }];
    return cell;
}

@end
