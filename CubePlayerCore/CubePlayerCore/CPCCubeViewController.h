//
//  GameViewController.h
//  CubePlayerCoreGL
//
//  Created by Kenta Akimoto on 2014/12/29.
//  Copyright (c) 2014年 Kenta Akimoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;

@interface CPCCubeViewController : GLKViewController
{
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    GLfloat _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _texture0ID;
    GLuint _texture1ID;
}

@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer
*vertexBuffer;

@end
