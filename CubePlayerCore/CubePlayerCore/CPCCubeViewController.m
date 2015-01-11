//
//  GameViewController.m
//  CubePlayerCoreGL
//
//  Created by Kenta Akimoto on 2014/12/29.
//  Copyright (c) 2014年 Kenta Akimoto. All rights reserved.
//

#import "CPCCubeViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import <AVFoundation/AVFoundation.h>

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;

@end


@implementation GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;
{
    glBindTexture(self.target, self.name);
    
    glTexParameteri(
                    self.target,
                    parameterID, 
                    value);
}

@end

@interface CPCCubeViewController ()

@property (strong, nonatomic) AVURLAsset *asset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVMutableComposition *comp;
@property (strong, nonatomic) AVMutableCompositionTrack *track;
@property (strong, nonatomic) AVAssetImageGenerator *imageGen;
@property (assign, nonatomic) CGContextRef cgContext;

@property (strong, nonatomic) UIImage *testImage;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation CPCCubeViewController
@synthesize baseEffect;
@synthesize vertexBuffer;

static const NSString* itemStatusContext;

/////////////////////////////////////////////////////////////////
// GLSL program uniform indices.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE0_SAMPLER2D,
    UNIFORM_TEXTURE1_SAMPLER2D,
    NUM_UNIFORMS
};


/////////////////////////////////////////////////////////////////
// GLSL program uniform IDs.
GLint uniforms[NUM_UNIFORMS];


/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
    GLKVector3  positionCoords;
    GLKVector3  normalCoords;
    GLKVector2  textureCoords;
}
SceneVertex;

/////////////////////////////////////////////////////////////////
// Define vertex data for a triangle to use in example
static const SceneVertex vertices[] =
{
    {{ 0.5f, -0.5f, -0.5f}, { 1.0f,  0.0f,  0.0f}, {0.0f,    0.0f}},
    {{ 0.5f,  0.5f, -0.5f}, { 1.0f,  0.0f,  0.0f}, {0.166f*1, 0.0f}},
    {{ 0.5f, -0.5f,  0.5f}, { 1.0f,  0.0f,  0.0f}, {0.0f,    1.0f}},
    {{ 0.5f, -0.5f,  0.5f}, { 1.0f,  0.0f,  0.0f}, {0.0f,    1.0f}},
    {{ 0.5f,  0.5f,  0.5f}, { 1.0f,  0.0f,  0.0f}, {0.166f*1, 1.0f}},
    {{ 0.5f,  0.5f, -0.5f}, { 1.0f,  0.0f,  0.0f}, {0.166f*1, 0.0f}},
    
    {{ 0.5f,  0.5f, -0.5f}, { 0.0f,  1.0f,  0.0f}, {0.166f*2, 0.0f}},
    {{-0.5f,  0.5f, -0.5f}, { 0.0f,  1.0f,  0.0f}, {0.166f*1, 0.0f}},
    {{ 0.5f,  0.5f,  0.5f}, { 0.0f,  1.0f,  0.0f}, {0.166f*2, 1.0f}},
    {{ 0.5f,  0.5f,  0.5f}, { 0.0f,  1.0f,  0.0f}, {0.166f*2, 1.0f}},
    {{-0.5f,  0.5f, -0.5f}, { 0.0f,  1.0f,  0.0f}, {0.166f*1, 0.0f}},
    {{-0.5f,  0.5f,  0.5f}, { 0.0f,  1.0f,  0.0f}, {0.166f*1, 1.0f}},
    
    {{-0.5f,  0.5f, -0.5f}, {-1.0f,  0.0f,  0.0f}, {0.166f*3, 0.0f}},
    {{-0.5f, -0.5f, -0.5f}, {-1.0f,  0.0f,  0.0f}, {0.166f*2, 0.0f}},
    {{-0.5f,  0.5f,  0.5f}, {-1.0f,  0.0f,  0.0f}, {0.166f*3, 1.0f}},
    {{-0.5f,  0.5f,  0.5f}, {-1.0f,  0.0f,  0.0f}, {0.166f*3, 1.0f}},
    {{-0.5f, -0.5f, -0.5f}, {-1.0f,  0.0f,  0.0f}, {0.166f*2, 0.0f}},
    {{-0.5f, -0.5f,  0.5f}, {-1.0f,  0.0f,  0.0f}, {0.166f*2, 1.0f}},
    
    {{-0.5f, -0.5f, -0.5f}, { 0.0f, -1.0f,  0.0f}, {0.166f*3, 0.0f}},
    {{ 0.5f, -0.5f, -0.5f}, { 0.0f, -1.0f,  0.0f}, {0.166f*4, 0.0f}},
    {{-0.5f, -0.5f,  0.5f}, { 0.0f, -1.0f,  0.0f}, {0.166f*3, 1.0f}},
    {{-0.5f, -0.5f,  0.5f}, { 0.0f, -1.0f,  0.0f}, {0.166f*3, 1.0f}},
    {{ 0.5f, -0.5f, -0.5f}, { 0.0f, -1.0f,  0.0f}, {0.166f*4, 0.0f}},
    {{ 0.5f, -0.5f,  0.5f}, { 0.0f, -1.0f,  0.0f}, {0.166f*4, 1.0f}},
    
    {{ 0.5f,  0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.166f*5, 1.0f}},
    {{-0.5f,  0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.166f*4, 1.0f}},
    {{ 0.5f, -0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.166f*5, 0.0f}},
    {{ 0.5f, -0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.166f*5, 0.0f}},
    {{-0.5f,  0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.166f*4, 1.0f}},
    {{-0.5f, -0.5f,  0.5f}, { 0.0f,  0.0f,  1.0f}, {0.166f*4, 0.0f}},
    
    {{ 0.5f, -0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.166f*6, 0.0f}},
    {{-0.5f, -0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.166f*5, 0.0f}},
    {{ 0.5f,  0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.166f*6, 1.0f}},
    {{ 0.5f,  0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.166f*6, 1.0f}},
    {{-0.5f, -0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.166f*5, 0.0f}},
    {{-0.5f,  0.5f, -0.5f}, { 0.0f,  0.0f, -1.0f}, {0.166f*5, 1.0f}},
};


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.testImage = [UIImage imageNamed:@"test.png" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
    self.testImage = [UIImage imageNamed:@"beetle.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];

    
    // Verify the type of view created automatically by the
    // Interface Builder storyboard
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    
    // Create an OpenGL ES 2.0 context and provide it to the
    // view
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // Make the new context current
    [AGLKContext setCurrentContext:view.context];
    
    [self loadShaders];
    
    // Create a base effect that provides standard OpenGL ES 2.0
    // shading language programs and set constants to be used for
    // all subsequent rendering
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         0.7f, // Red
                                                         0.7f, // Green
                                                         0.7f, // Blue
                                                         1.0f);// Alpha
    
    glEnable(GL_DEPTH_TEST);
    
    // Set the background color stored in the current context
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.65f, // Red
                                                              0.65f, // Green
                                                              0.65f, // Blue
                                                              1.0f);// Alpha
    
    // Create vertex buffer containing vertices to draw
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices
                         usage:GL_STATIC_DRAW];

    // Setup texture0
    CGImageRef imageRef0 =
    [[UIImage imageNamed:@"leaves.gif" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] CGImage];
/*
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader
                                    textureWithCGImage:imageRef0
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:YES],
                                             GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S
                                           value:GL_REPEAT];
    [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_T
                                           value:GL_REPEAT];

    // Setup texture1
    CGImageRef imageRef1 =
    [[UIImage imageNamed:@"beetle.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] CGImage];
    
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader
                                    textureWithCGImage:imageRef1
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:YES],
                                             GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S
                                           value:GL_REPEAT];
    [self.baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_T
                                           value:GL_REPEAT];
*/
    
    [self setupPlayer];
}


/////////////////////////////////////////////////////////////////
//
- (void)update
{
    [self captureSnapImage];
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.baseEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
/*
    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, NULL));
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
*/
    _rotation += self.timeSinceLastUpdate * 0.5f;

}

/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    // Clear back frame buffer (erase previous drawing)
    [(AGLKContext *)view.context clear:
     GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, normalCoords)
                                  shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];

    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];

    [self.baseEffect prepareToDraw];
    
    // Draw triangles using baseEffect
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_TEXTURE0_SAMPLER2D], 0);
    glUniform1i(uniforms[UNIFORM_TEXTURE1_SAMPLER2D], 1);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexBuffer = nil;
    
    self.baseEffect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle bundleForClass:[self class]] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle bundleForClass:[self class]] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "aPosition");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "aNormal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "aTextureCoord0");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord1, "aTextureCoord1");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "uModelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "uNormalMatrix");
    uniforms[UNIFORM_TEXTURE0_SAMPLER2D] = glGetUniformLocation(_program, "uSampler0");
    uniforms[UNIFORM_TEXTURE1_SAMPLER2D] = glGetUniformLocation(_program, "uSampler1");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - initializer

+(instancetype)cubeViewControllerWithUrl:(NSURL*)assetUrl
{
    CPCCubeViewController *cubeViewController = [[CPCCubeViewController alloc] initWithNibName:@"CPCCubeView" bundle:[NSBundle bundleForClass:[self class]]];
    NSDictionary* assetOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                             forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:assetUrl options:assetOptions];
    cubeViewController.asset = asset;
    return cubeViewController;
}

-(void)setupPlayer
{
    [_asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        NSError* error = nil;
        AVKeyValueStatus status = [_asset statusOfValueForKey:@"tracks" error:&error];
        if (status == AVKeyValueStatusLoaded) {
            self.playerItem = [[AVPlayerItem alloc] initWithAsset:_asset];
            [_playerItem addObserver:self forKeyPath:@"status" options:0 context:&itemStatusContext];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:_playerItem];
            self.player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    AVAssetTrack* srcTrack = [[_asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    self.comp = [AVMutableComposition composition];
    self.track = [_comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError* error = nil;
    BOOL ok = [_track insertTimeRange:srcTrack.timeRange ofTrack:srcTrack atTime:kCMTimeZero error:&error];
    if (!ok) {
        NSLog(@"%@", [error localizedDescription]);
    }
    self.imageGen = [[AVAssetImageGenerator alloc] initWithAsset:_comp];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                        change:(NSDictionary*)change context:(void*)ctx
{
    if (ctx == &itemStatusContext) {
        if (_playerItem.status == AVPlayerItemStatusReadyToPlay && _player.rate == 0) {
            for (AVPlayerItemTrack* itemTrack in _playerItem.tracks) {
                if (![itemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicAudible]) {
                    itemTrack.enabled = NO;
                }
            }
            [_player play];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:ctx];
    }
}

- (void)playerItemDidReachEnd:(NSNotification*)notification
{
    [_player seekToTime:kCMTimeZero];
    [_player play];
    //[player pause];
}

- (void)captureSnapImage
{
    CMTime time = [_player currentTime];
    CMTime actualTime;
    NSError* error = nil;
    
    CGImageRef cgImage = [_imageGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    NSArray *images = @[[NSValue valueWithPointer:cgImage],
                        [NSValue valueWithPointer:cgImage],
                        [NSValue valueWithPointer:cgImage],
                        [NSValue valueWithPointer:cgImage],
                        [NSValue valueWithPointer:cgImage],
                        [NSValue valueWithPointer:cgImage]];
    
    CGImageRef combinedCgImage = [self createCombinedImages:images];
    //CGImageRef combinedCgImage = cgImage;

    CGImageRelease(cgImage);
    
    if (combinedCgImage != nil) {
        
        // テクスチャバッファを新規に作り続けてしまって落ちるため、古いものを削除する
        GLuint prevTextureName = self.baseEffect.texture2d0.name;
        glDeleteTextures(1, &prevTextureName);
        GLKTextureInfo *textureInfo0 = [GLKTextureLoader
                                        textureWithCGImage:combinedCgImage
                                        options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:YES],
                                                 GLKTextureLoaderOriginBottomLeft, nil]
                                        error:NULL];

//        GLKTextureInfo *textureInfo0 = [GLKTextureLoader
//                                        textureWithCGImage:self.testImage.CGImage
//                                        options:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                 [NSNumber numberWithBool:YES],
//                                                 GLKTextureLoaderOriginBottomLeft, nil]
//
//                                        error:NULL];
        
        self.baseEffect.texture2d0.name = textureInfo0.name;
        self.baseEffect.texture2d0.target = textureInfo0.target;
        self.baseEffect.texture2d0.envMode = GLKTextureEnvModeReplace;
        [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S
                                               value:GL_CLAMP_TO_EDGE];
        [self.baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_T
                                               value:GL_CLAMP_TO_EDGE];


        CGImageRelease(combinedCgImage);
    } else {
        NSLog(@"time:%f actualTime:%f error:%@", CMTimeGetSeconds(time), CMTimeGetSeconds(actualTime), [error localizedDescription]);
    }

}

- (CGImageRef)createCombinedImages:(NSArray*)images
{
    int totalWidth = 0;
    int maxWidth = 0;
    int maxHeight = 0;

    CGContextRef bitmapContext = nil;
    unsigned char *bitmap = nil;
    
    for (int i = 0; i < [images count]; i++) {
        
        CGImageRef image = ((NSValue*)images[i]).pointerValue;
        
        if (i == 0) {
            
            maxWidth = (int)CGImageGetWidth(image) * (int)[images count];
            maxHeight = (int)CGImageGetHeight(image);

            //CGContextを作成
//            bitmap = malloc(maxWidth * maxHeight * sizeof(unsigned char) * 4);
            bitmap = calloc(maxWidth * maxHeight * 4 , sizeof(unsigned char));

            CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little;
            switch (CGImageGetAlphaInfo(image)) {
                case kCGImageAlphaPremultipliedLast:
                case kCGImageAlphaPremultipliedFirst:
                    bitmapInfo |= kCGImageAlphaPremultipliedFirst;
                    break;
                case kCGImageAlphaLast:
                case kCGImageAlphaFirst:
                    bitmapInfo |= kCGImageAlphaPremultipliedLast;
                    break;
                case kCGImageAlphaNoneSkipFirst:
                    bitmapInfo |= kCGImageAlphaNoneSkipFirst;
                    break;
                default:
                    bitmapInfo |= kCGImageAlphaNoneSkipLast;
                    break;
            }

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            bitmapContext = CGBitmapContextCreate(bitmap,
                                                               maxWidth,
                                                               maxHeight,
                                                               8,
                                                               maxWidth * 4,
                                                               colorSpace,
                                                                  // kCGImageAlphaPremultipliedFirst);
                                                               //kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
                                                  bitmapInfo);
            CGColorSpaceRelease(colorSpace);
        }
        
        if (bitmapContext != nil) {
            //imgAをbitmapContextに描画
            CGContextDrawImage(bitmapContext, CGRectMake(totalWidth, 0, (int)CGImageGetWidth(image), maxHeight), image);
            totalWidth += (int)CGImageGetWidth(image);
        }
    }
    
    CGImageRef imgRef = nil;
    if (bitmapContext != nil) {
        
        //CGContextからCGImageを作成
        imgRef = CGBitmapContextCreateImage (bitmapContext);
    }
/*
    //CGImageからUIImageを作成
    UIImage *imgC = [UIImage imageWithCGImage:imgRef];
    NSData *data = UIImagePNGRepresentation(imgC);
    NSString *filePath = [NSString stringWithFormat:@"%@/test2.png" , [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    NSLog(@"%@", filePath);
    if ([data writeToFile:filePath atomically:YES]) {
        NSLog(@"OK");
    } else {
        NSLog(@"Error");
    }
*/
    
    //bitmapを解放
    free(bitmap);
    CGContextRelease(bitmapContext);
    
    return imgRef;
}

@end
