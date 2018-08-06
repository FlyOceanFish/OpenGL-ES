//
//  ViewController.m
//  opengl
//
//  Created by FlyOceanFish on 2018/8/1.
//  Copyright © 2018年 FlyOceanFish. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES3/gl.h>

//    self.view.transform = CGAffineTransformScale(<#CGAffineTransform t#>, <#CGFloat sx#>, <#CGFloat sy#>)
//    CGContextTranslateCTM(<#CGContextRef  _Nullable c#>, <#CGFloat tx#>, <#CGFloat ty#>)
//    CGContextScaleCTM(<#CGContextRef  _Nullable c#>, <#CGFloat sx#>, <#CGFloat sy#>)

@interface ViewController ()
{
    GLuint vertextBufferID;
    EAGLContext *context;
    GLKBaseEffect *mEffect;//着色器或光照
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
//    [EAGLContext setCurrentContext:context];
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:context];
    
    /***********************  加载顶点数据  ******************************/

//    用来开启更新深度缓冲区，OpenGL在绘制的时候就会检查，当前像素前面是否有别的像素，如果别的像素挡着了它，那它就不会绘制，也就是说，OpenGL就只绘制最前面的一层；当我们需要绘制透明图片时，就需要关闭它。
    glEnable(GL_DEPTH_TEST);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
//    前三顶点，后2纹理
    GLfloat vertextData[]={
        0.5f,-0.5f,0.0f, 1.0f,0.0f,
        0.5f,0.5f,0.0f, 1.0f,1.0f,
        -0.5f,0.5f,0.0f, 0.0f,1.0f,
        
        0.5f,-0.5f,0.0f, 1.0f,0.0f,
        -0.5f,0.5f,0.0f, 0.0f,1.0f,
        -0.5f,-0.5f,0.0f, 0.0f,0.0f,
    };
    glGenBuffers(1, &vertextBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBufferID);
    /**
    GL_STATIC_DRAW：表示该缓存区不会被修改；
    GL_DyNAMIC_DRAW：表示该缓存区会被周期性更改；
    GL_STREAM_DRAW：表示该缓存区会被频繁更改；
    **/
//    为缓存分配足够的内存（CPU数据复制到GPU）
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertextData), vertextData, GL_STATIC_DRAW);
//  告诉OpenGL ES是否使用缓存中的数据 (启用顶点位置(坐标)数组，opengl是状态机，需要什么状态就启动什么状态)
    glEnableVertexAttribArray(GLKVertexAttribPosition);
// 告诉OpenGL ES缓存数据类型和所有需要访问的数据的内存偏移值
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL);
//  启用纹理坐标(u, v)
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    设置纹理坐标
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);
    
    /***********************  加载纹理  ******************************/
//读取纹理
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
//    着色器
    mEffect = [[GLKBaseEffect alloc] init];
    mEffect.texture2d0.enabled = GL_TRUE;
    mEffect.texture2d0.name = textureInfo.name;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [mEffect prepareToDraw];
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);//清空当前的所有颜色,并设置背景色

    /**
        GL_COLOR_BUFFER_BIT:    当前可写的颜色缓冲
        GL_DEPTH_BUFFER_BIT:    深度缓冲
        GL_ACCUM_BUFFER_BIT:   累积缓冲
     　　GL_STENCIL_BUFFER_BIT: 模板缓冲
     **/
//    表示要清除颜色缓冲以及深度缓冲(将以前绘制的擦除)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
- (void)dealloc
{
    [EAGLContext setCurrentContext:nil];
    if (0 != vertextBufferID) {
        glDeleteBuffers(1, &vertextBufferID);
        vertextBufferID = 0;
    }
}
@end
