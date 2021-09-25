import * as THREE from "../lib/three.module.js";

import{TYPES} from "../csm/three-csm.module.js";

import{ui} from "../ui.js";

let properties={
    type: TYPES.PHYSICAL,
    clearcoat:1.,
    roughness:1.,
    metalness:0.,
    side:THREE.DoubleSide,
    transparent:true,
    transmission:ui.transmission,
}









let vertexUniforms={
    //three_noise_seed: { value: 2 },
    time: {value: 0},
    rotx: {value: ui.rotx},
    roty: {value: ui.roty},
    rotu  : {value: ui.rotu},
    tumble: {value: ui.tumble},
    amplitude:{value:ui.amplitude},
    n: {value: ui.n},
    proj: {value: ui.proj},
};


let fragmentUniforms={
    time: {value: 0},
    grid: {value: ui.grid},
    hue: {value: ui.hue},
    res: {value: 2048.},
    rotx: {value: ui.rotx},
    roty: {value: ui.roty},
    rotu  : {value: ui.rotu},
    tumble: {value: ui.tumble},
    amplitude:{value:ui.amplitude},
    n: {value: ui.n},
    proj: {value: ui.proj},
};



//IMPORTANT NOTE:
//these file names need to be relative to the main folder, where they are called in main.js

const vertPaths = {
    defines: './mat2/vertex/uniforms.glsl',
    header: './mat2/geometry.glsl',
    main: './mat2/vertex/main.glsl',
};


const fragPaths={
    uniforms:'./mat2/fragment/uniforms.glsl',
    geometry:'./mat2/geometry.glsl',
    main:'./mat2/fragment/main.glsl'
};








//EXPORT ALL OF THIS BUNDLED UP TOGETHER
let mat2={
    properties:properties,
    vertexUniforms:vertexUniforms,
    fragmentUniforms:fragmentUniforms,
    vertPaths:vertPaths,
    fragPaths:fragPaths,
    maps:undefined,
}








export{mat2}