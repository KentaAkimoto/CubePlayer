//
//  Shader.fsh
//  CubePlayerCoreGL
//
//  Created by Kenta Akimoto on 2014/12/29.
//  Copyright (c) 2014年 Kenta Akimoto. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
