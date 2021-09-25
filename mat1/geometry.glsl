//INPUT: a point  vec3 params, having x and y coordinates in 0,1 and z=0
//OUTPUT: a point vec3 giving location in R3 for the parametric surface




//=============================================
//Components for building the surface
//=============================================


//take in polar coordinates, spit out cartesian
vec2 toZ(vec2 p){
    float r=p.x;
    float t=p.y;

    float x=r*cos(t);
    float y=r*sin(t);

    return vec2(x,y);
}


//take in cartesian, spit out polar
vec2 fromZ(vec2 q){

    float r=length(q);
    float t=atan(q.y, q.x);

    return vec2(r, t);
}





//=============================================
//Components for working with points in R4
//=============================================

vec4 translateR4(vec4 p,vec4 q){
    return p+q;
}


vec4 rotateR4(vec4 p,float x,float y,float u,float tumble){

    float cS=cos(y+0.7*tumble);
    float sS=sin(y+0.7*tumble);
    float cT=cos(x+1.5*tumble);
    float sT=sin(x+1.5*tumble);
    float cU=cos(u-1.3*tumble);
    float sU=sin(u-1.3*tumble);


    mat4 rotMatY=mat4(
    cS,0,-sS,0,
    0,cS,0,-sS,
    sS,0,cS,0,
    0,sS,0,cS
    );



    mat4 rotMatX=mat4(
    cT,0,0,-sT,
    0,cT,-sT,0,
    0,sT,cT,0,
    sT,0,0,cT
    );


    mat4 rotMatU=mat4(
    cU,-sU,0,0,
    sU,cU,0,0,
    0,0,cU,-sU,
    0,0,sU,cU
    );

    vec4 q=rotMatU*rotMatY*rotMatX*p;

    return q;
}

vec3 orthographicProj(vec4 p){
    //JUST DELETE THE W COORDINATE
    return p.xyz;
}


vec3 stereographicProj(vec4 p){

    if(p.w>-0.999){

        return p.xyz/(p.w+1.0);
    }
    else{//delete the triangle
        return vec3(0./0.);
    }
}


vec3 perspectiveProj(vec4 p){
    vec4 offset=vec4(0,0,0,2.);
    p=p+offset;

    return 2.*p.xyz/p.w;

}


vec3 combinedProj(vec4 v){

    //rotate in R4;
    v=rotateR4(v,PI/2.*roty, PI/2.*rotx,PI/2.*rotu,tumble*time);

    //project to R3
    if(proj==0){
        return 3.*stereographicProj(v);
    }
    if(proj==1){
        return 3.*perspectiveProj(v);
    }
    else{
        return 3.*orthographicProj(v);
    }
}




//=============================================
//Functions to Export: Graping Z^n in R4
//=============================================

//=============================================
//Hopf Tori From Curve
//=============================================


//get a point on the curve
vec2 sphereCurve(float t){

    // float phi=2.+0.5*(1.+sin(uTime))*sin(3.*t);

    float phi=1.+amplitude*(1.+0.3*sin(time))*sin(n*t+0.3*cos(time)+0.3*time);
   // float phi=1.+amplitude+0.3*sin(n*t);

    return vec2(phi,t);
}

vec3 sphCoords(vec2 p){
    float phi=p.x;
    float theta=p.y;

    float x=cos(theta)*sin(phi);
    float y=sin(theta)*sin(phi);
    float z=cos(phi);

    return vec3(x,y,z);
}



vec4 hopfLift(vec3 p){
    //a lift of the curve on the 2 sphere to S3
    //such that the lift lives in the S2 det'd by i-comp=0.
    float x=p.x;
    float y=p.y;
    float z=p.z;

    //this has problems when x=-1 but only there
    float a=sqrt((z+1.)/2.);

    float c=y/(2.*a);
    float d=x/(2.*a);

    return vec4(a,0,c,d);
}



vec4 hopfFiber(vec4 q, float s){
    //gives a parameterization, in terms of s, of the hopf fiber passing thru p
    //this is the curve of quaterions e^(is)*p

    //i*p
    vec4 r=vec4(q.y,-q.x,-q.w,q.z);

    return cos(s)*q+sin(s)*r;
}


vec4 hopfSurface(float t, float s){
    //t is on curve, s is fiber

    //get coordinates along curve
    vec2 coords=sphereCurve(t);

    //get point on S2
    vec3 p=sphCoords(coords);

    //lift to S2 in S3:
    vec4 q=hopfLift(p);

    //get point along fiber:
    vec4 r=hopfFiber(q,s);

    return r;

}


//GLOBAL VARIABLES: the radii rU, rV of the torus
//radii of the flat torus it lies on in S3
float rU=0.98229118401071;
float rV=0.18736069442342;






vec4 trefoil(float t){
    //gives the trefoil satisfying
    //u^3=27v^2 in C2

    //the knot lying on the Clifford torus
    float freq=3./2.;
    vec2 uCirc=vec2(cos(t),sin(t));
    vec2 vCirc=vec2(cos(freq*t),sin(freq*t));

    //rescaling to lie on the rU-rV torus
    vec4 p=vec4(rU*uCirc,rV*vCirc);

    return p;
}


vec4 trefoilTangent(float t){
    //unit tangent vector to trefoil curve

    //taking the derivative of the components of trefoil(t);
    float freq=3./2.;
    vec2 uTang=vec2(-sin(t),cos(t));
    vec2 vTang=freq*vec2(-sin(freq*t),cos(freq*t));

    vec4 tang=vec4(rU*uTang,rV*vTang);

    //this is unit length, but doesnt hurt to make sure
    return normalize(tang);
}



vec4 trefoilNormal(float t){
    //unit normal to the trefoil curve

    //get the position vector along the curve
    vec4 pos=trefoil(t);

    //the acelleration vector is the negation of this in the u directoin
    //and negation times freq^2 in the v direction
    float freq=3./2.;
    vec4 acc=-pos;
    acc.zw*=freq*freq;

    //to get the normal vector, need to subtract off the portion of this which is not in the tangent space
    float nonTangent=dot(acc,pos);

    vec4 normal=acc-nonTangent*pos;

    //make unit length
    return normalize(normal);
}


vec4 getBinormal(vec4 pos, vec4 tang, vec4 normal){
    //compute the unit vector orthogonal to the three given unit vectors in R4
    //just like cross product in R3, find by computing the "determinant"
    // of  e1,e2,e3,e4 followed by rows pos, tang, normal

    //glsl is column major, so acutally gonna compute the transpose of this
    mat3 M1=mat3(pos.yzw, tang.yzw, normal.yzw);
    mat3 M2=mat3(pos.xzw, tang.xzw, normal.xzw);
    mat3 M3=mat3(pos.xyw, tang.xyw, normal.xyw);
    mat3 M4=mat3(pos.xyz, tang.xyz, normal.xyz);

    float c1=determinant(M1);
    float c2=determinant(M2);
    float c3=determinant(M3);
    float c4=determinant(M4);

    vec4 biNorm=vec4(c1, -c2, c3, -c4);

    //again, this is already normalized but just to be safe
    return normalize(biNorm);

}





vec4 expMap(vec4 p, vec4 v, float r){
    //exponentiates the vector rv onto the sphere from point p
    return cos(r)*p+sin(r)*v;
}




vec4 trefoilSurface(float t, float s){
    //t is along the trefoil, s is around the tube

    float rad=0.03;

    //get position
    vec4 position=trefoil(t);
    //get tangential direction
    vec4 tangent=trefoilTangent(t);
    //get normal direction
    vec4 normal=trefoilNormal(t);
    //get binormal direction
    vec4 binormal=getBinormal(position,tangent,normal);

    //now that we have an orthonormal frame at each point
    //get the vector along the tube in tangent space
    vec4 tubeDir=cos(s)*normal+sin(s)*binormal;

    //now exponentiate this from the position
    vec4 tubePos=expMap(position,tubeDir,rad);

    //return this tube position
    return tubePos;

}





//=============================================
//Functions to Export
//=============================================




vec3 displace(vec3 params){

    rU=sqrt(1.-amplitude);
    rV=sqrt(amplitude);

    //params arive in (-0.5,0.5)^2: need to rescale
    params+=vec3(0.5,0.5,0.);
    //now in [0,1]^2: scale corrrectly for torus:
    float t=4.*PI*params.x;
    float s=2.*PI*params.y;
    vec4 p;

    //get the point on the surface:
    p=trefoilSurface(t, s);

    //project to R3:
    vec3 q=combinedProj(p);

    return q;
}