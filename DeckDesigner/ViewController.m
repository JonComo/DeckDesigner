//
//  ViewController.m
//  DeckDesigner
//
//  Created by Jon Como on 8/15/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "ViewController.h"

#import "CellGraphic.h"

@import SceneKit;

NSString *cellGraphic = @"cellGraphic";

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SCNSceneRendererDelegate>

@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNView *sceneView;

@property (nonatomic, strong) SCNNode *skateboard, *trucks;

@property (nonatomic, strong) UICollectionView *collectionViewDecks;
@property (nonatomic, copy) NSArray *graphics;

@property (nonatomic, assign) SCNVector3 spin;
@property (nonatomic, assign) CGPoint lastPosition;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.scene = [SCNScene sceneNamed:@"art.scnassets/Skateboard.dae"];
    
    self.sceneView = [[SCNView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, self.view.bounds.size.width)];
    [self.view addSubview:self.sceneView];
    
    self.sceneView.scene = self.scene;
    self.sceneView.delegate = self;
    
    self.skateboard = [self.scene.rootNode childNodeWithName:@"board" recursively:YES];
    SCNMaterial *graphic = [self.skateboard.geometry.materials firstObject];
    graphic.diffuse.contents = [UIImage imageNamed:@"board_d.tga"];
    
    self.trucks = [self.scene.rootNode childNodeWithName:@"trucks" recursively:YES];
    SCNMaterial *mat = [self.trucks.geometry.materials firstObject];
    mat.diffuse.contents = [UIImage imageNamed:@"trucks_d.tga"];
    
    SCNNode *light = [self.scene.rootNode childNodeWithName:@"LightTop" recursively:YES];
    light.light.castsShadow = YES;
    //light.light.shadowSampleCount = 2;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 0.f;
    layout.minimumLineSpacing = 0.f;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    float cellSize = self.view.bounds.size.width;
    
    layout.itemSize = CGSizeMake(cellSize, cellSize / 2.f);
    
    self.collectionViewDecks = [[UICollectionView alloc] initWithFrame:CGRectMake(0.f, self.sceneView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.sceneView.bounds.size.height) collectionViewLayout:layout];
    [self.view addSubview:self.collectionViewDecks];
    
    self.collectionViewDecks.delegate = self;
    self.collectionViewDecks.dataSource = self;
    
    [self.collectionViewDecks registerClass:[CellGraphic class] forCellWithReuseIdentifier:cellGraphic];
    
    self.graphics = [[NSBundle mainBundle] pathsForResourcesOfType:@"tga" inDirectory:@"Decks"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTrucks)];
    tap.numberOfTapsRequired = 2;
    [self.sceneView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)renderer:(id<SCNSceneRenderer>)aRenderer updateAtTime:(NSTimeInterval)time {
    float decay = 0.99f;
    self.spin = SCNVector3Make(self.spin.x * decay, self.spin.y * decay, self.spin.z * decay);
    [self.skateboard runAction:[SCNAction rotateByX:self.spin.x y:self.spin.y z:self.spin.z duration:0.f]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (touch.view == self.sceneView) {
            self.lastPosition = [touch locationInView:self.sceneView];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        if (touch.view == self.sceneView) {
            CGPoint position = [touch locationInView:self.sceneView];
            
            float xDiff = position.x - self.lastPosition.x;
            float yDiff = position.y - self.lastPosition.y;
            
            xDiff *= 1e-2f;
            yDiff *= 1e-2f;
            
            self.spin = SCNVector3Make(self.spin.x + yDiff, self.spin.y + xDiff, self.spin.z);
            
            self.lastPosition = position;
        }
    }
}

- (void)toggleTrucks {
    self.trucks.hidden = !self.trucks.hidden;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma UICollectionViewDataSource

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *graphicName = self.graphics[indexPath.row];
    UIImage *newTex = [UIImage imageNamed:graphicName];
    
    SCNMaterial *mat = [self.skateboard.geometry.materials firstObject];
    mat.diffuse.contents = newTex;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.graphics.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CellGraphic *cell = (CellGraphic *)[collectionView dequeueReusableCellWithReuseIdentifier:cellGraphic forIndexPath:indexPath];
    
    NSString *graphicName = self.graphics[indexPath.row];
    cell.image = [UIImage imageNamed:graphicName];
    
    return cell;
}

@end
