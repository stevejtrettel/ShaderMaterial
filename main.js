import * as THREE from "./lib/three.module.js";


import{camera,orthoCam,renderer,controls,onWindowResize} from './components.js';

import{scene,buildScene,createEnvMap,createFragmentScene} from './scene.js';


import{loadShadersCSM,assembleShaderCode} from "./csm/loadShaders.js";

import{createCSM,createTexM,updateUniforms,updateProperties} from "./customMat.js";

import{mat1} from "./mat1/properties.js";



import {
    ui,
    createUI
} from './ui.js';




let shaderTex=new THREE.WebGLRenderTarget(2048,2048);
let time=0.;





  const animate = function () {

    requestAnimationFrame(animate);
    controls.update();

      // //render the texture for the main surface
       renderer.setRenderTarget(shaderTex);
       renderer.render(texScene,orthoCam);

      //render the main scene
       renderer.setRenderTarget(null);
       renderer.render(scene, camera);

       updateProperties(vertMat,mat1.properties);
       updateUniforms(vertMat,mat1.vertexUniforms,time);
       updateUniforms(texMat,mat1.fragmentUniforms,time);

       time+=0.01;
  };









//running things:
let vertMat,texMat;
let texScene;



loadShadersCSM(mat1.vertPaths).then((vertCode) => {
    assembleShaderCode(mat1.fragPaths).then((fragCode)=>{


        createUI();

        // listener
        window.addEventListener('resize', onWindowResize, false);


        //scene making texture
        texMat=createTexM(fragCode,mat1.fragmentUniforms);
        texScene=createFragmentScene(texMat);

    //MAIN SCENE STUFF

    let env=createEnvMap();

    //now can assign maps to the material
    mat1.maps={
        envMap:env,
        envMapIntensity:1.5,
        map:shaderTex.texture,
    }

     vertMat=createCSM(vertCode,mat1.vertexUniforms,mat1.properties,mat1.maps);

     buildScene(vertMat);

    animate();


    });
});




export{time};