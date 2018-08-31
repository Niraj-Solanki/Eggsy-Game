//
//  HomeViewController.m
//  SpriteKitDemo
//
//  Created by Neeraj Solanki on 20/04/17.
//  Copyright © 2017 Neeraj Solanki. All rights reserved.
//


#import "HomeViewController.h"
#import "GameViewController.h"

@interface HomeViewController ()
@property (strong, nonatomic) IBOutlet UIView *hiddenBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *alertViewEggsyGame;
@property (strong, nonatomic) IBOutlet UIButton *eggsyGameButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self screenSchanges];
    
    // Do any additional setup after loading the view.
}


-(void)screenSchanges
{
    
    _alertViewEggsyGame.layer.shadowColor=[UIColor blackColor].CGColor;
    _alertViewEggsyGame.layer.shadowOffset = CGSizeMake(-3, 4);
    _alertViewEggsyGame.layer.shadowOpacity=.55;
    _alertViewEggsyGame.layer.shadowRadius=2;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)eggsyGameStartButton:(id)sender {
    _alertViewEggsyGame.hidden=YES;
    _hiddenBackgroundView.hidden=YES;
    GameViewController *eggsyGame= [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([GameViewController class])];
    [self.navigationController pushViewController:eggsyGame animated:YES];
    
}
- (IBAction)eggsyGameCancelButton:(id)sender {
    _alertViewEggsyGame.hidden=YES;
    _hiddenBackgroundView.hidden=YES;
}
- (IBAction)eggsyGameButtonOnTap:(id)sender {
    _alertViewEggsyGame.hidden=NO;
    _hiddenBackgroundView.hidden=NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
