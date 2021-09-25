import * as THREE from "./lib/three.module.js";


import{camera,orthoCam,renderer,controls,onWindowResize} from './components.js';

import{scene,buildScene,createEnvMap,createFragmentScene} from './scene.js';


import{loadShadersCSM,assembleShaderCode} from "./csm/loadShaders.js";

import{createCSM,createTexM,updateUniforms,updateProperties} from "./customMat.js";

import{mat1} from "./mat1/properties.js";

import{mat2} from "./mat2/properties.js";



import {
    ui,
    createUI
} from './ui.js';




let shaderTex=new THREE.WebGLRenderTarget(2048,2048);
let shaderTex2=new THREE.WebGLRenderTarget(2048,2048);

let time=0.;





  const animate = function () {

    requestAnimationFrame(animate);
    controls.update();

      // //render the texture for the mfirst surface
       renderer.setRenderTarget(shaderTex);
       renderer.render(texScene,orthoCam);

      //render the texture for the second surface
      renderer.setRenderTarget(shaderTex2);
      renderer.render(texScene2,orthoCam);




      //render the main scene
       renderer.setRenderTarget(null);
       renderer.render(scene, camera);







      updateProperties(vertMat2,mat2.properties);
      updateUniforms(vertMat2,mat2.vertexUniforms,time);
      updateUniforms(texMat2,mat2.fragmentUniforms,time);

      updateProperties(vertMat,mat1.properties);
      updateUniforms(vertMat,mat1.vertexUniforms,time);
      updateUniforms(texMat,mat1.fragmentUniforms,time);


       time+=0.01;
  };









//running things:
let vertMat,texMat,texScene;
let vertMat2,texMat2,texScene2;




loadShadersCSM(mat1.vertPaths).then((vertCode) => {
    loadShadersCSM(mat2.vertPaths).then((vertCode2) => {
    assembleShaderCode(mat1.fragPaths).then((fragCode)=>{
            assembleShaderCode(mat2.fragPaths).then((fragCode2)=>{



        createUI();

        // listener
        window.addEventListener('resize', onWindowResize, false);


        //scene making texture
        texMat=createTexM(fragCode,mat1.fragmentUniforms);
        texScene=createFragmentScene(texMat);

        texMat2=createTexM(fragCode2,mat2.fragmentUniforms);
        texScene2=createFragmentScene(texMat2);

    //MAIN SCENE STUFF

    let env=createEnvMap();

    //now can assign maps to the material
    mat1.maps={
        envMap:env,
        envMapIntensity:1.,
        map:shaderTex.texture,
    }

    mat2.maps={
        envMap:env,
        envMapIntensity:1.,
        map:shaderTex2.texture,
    }

    buildScene();


    vertMat=createCSM(vertCode,mat1.vertexUniforms,mat1.properties,mat1.maps);
    vertMat2=createCSM(vertCode2,mat2.vertexUniforms,mat2.properties,mat2.maps);


                const geometry2 = new THREE.PlaneGeometry(1,1, 30,50);
                const surf2 = new THREE.Mesh(geometry2, vertMat2);
                scene.add(surf2);


    const geometry = new THREE.PlaneGeometry(1,1, 300,200);
    const surf = new THREE.Mesh(geometry, vertMat);
    scene.add(surf);




                animate();

            });
        });

    });
});




export{time};