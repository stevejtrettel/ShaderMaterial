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











//the first 15 values of the sigma3 function
//this function sends n to the sum of the cubes of all divisors of n
const float sigma3[25] = float[25](1., 9., 28., 73., 126., 252., 344., 585., 757., 1134., 1332., 2044., 2198., 3096.,
3528.,4681., 4914., 6813., 6860., 9198., 9632., 11988., 12168., 16380., 15751.);

//the first 15 values of the sigma5 function
//this function sends n to the sum of the 5th powers of all divisors of n
const float sigma5[25] = float[25](1., 33., 244., 1057., 3126., 8052., 16808., 33825., 59293., 103158., 161052.,
257908., 371294., 554664., 762744.,1082401., 1419858., 1956669., 2476100.,
3304182., 4101152., 5314716., 6436344., 8253300., 9768751.);

//normalizing constants which go in front of the fourier series for g2 and g3
const float g2Const=(1./16.)*(4./3.)*PI*PI*PI*PI;
const float g3Const=(1./64.)*(8./27.)*PI*PI*PI*PI*PI*PI;


//complex exponentiation
vec2 cExp(vec2 z){
    return exp(z.x)*vec2(cos(z.y),sin(z.y));
}


//complex division
vec2 cDiv(vec2 z, vec2 w){
    //return z/w;
    float mag2=w.x*w.x+w.y*w.y;
    float re=z.x*w.x+z.y*w.y;
    float im=z.y*w.x-z.x*w.y;

    return vec2(re,im)/mag2;
}


vec2 cMult(vec2 z, vec2 w){
    float re=z.x*w.x-z.y*w.y;
    float im=z.x*w.y+z.y*w.x;
    return vec2(re,im);
}

//float depressedCubicRoot(float a, float b){
//    //get the real root of the cubic x^3-ax-b=0;
//
//    float disc=81.*b*b-12.*a*a*a;
//    float term=9.*b+sqrt(abs(disc));
//
//    float term23=pow(abs(term),2./3.);
//    float term13=pow(abs(term),1./3.);
//
//    float c1=2.884499140614;//2*3^(1/3)
//    float c2=1.2599210498948;//2^(1/3)
//    float c3=3.3019272488946;//6^(2/3)
//    float num=c1*a+c2*term23;
//    float denom=c3*term13;
//
//    return num/denom;
//}


float depressedCubicRoot(float a, float b){
    //get the real root of the cubic x^3-ax-b=0;
    float lower=0.;
    float upper=500.;
    float x;
    float val;

    for(int k=0;k<30;k++){
    //iteratively search via bisectoin
    x=(upper+lower)/2.;
    val=x*x*x-a*x-b;
        if(val<0.){
            lower=x;
        }
        else{
            upper=x;
        }
    }

    float root=0.5*(upper+lower);
    return root;
}





//compute g2 invariant from its fourier series
vec2 g2(vec2 tau){

    vec2 val=vec2(0,0);

    //calculating the argument of the exponent q=exp(PI*i*tau)
    vec2 argQ=PI*vec2(-tau.y,tau.x);

    for(int k=0;k<25;k++){
        //add the kth term: sigma3(k)*exp(2k argQ)
        val+=sigma3[k]*cExp(2.*float(k)*argQ);
    }

    return g2Const*(vec2(1,0)+240.*val);
}



//compute the g3 invariant from its fourier series
vec2 g3(vec2 tau){

    vec2 val=vec2(0,0);

    //calculating the argument of the exponent q=exp(PI*i*tau)
    vec2 argQ=PI*vec2(-tau.y,tau.x);

    for(int k=0;k<25;k++){
        //add the kth term: sigma3(k)*exp(2k argQ)
        val+=sigma5[k]*cExp(2.*float(k)*argQ);
    }

    return g3Const*(vec2(1,0)-504.*val);
}


//compute g2 for a latitce given by a basis
vec2 g2(mat2 B){

    vec2 z=B[0];
    vec2 w=B[1];

    //get a tau where the lattice is homothetic to the one wiwht basis (1,tau)
    vec2 tau=cDiv(w,z);

    //compute g2 for this using Fourier series
    vec2 res=g2(tau);

    //now scale appropriately
    //convert to polar
    vec2 polar=fromZ(z);
    float r=polar.x;
    float t=polar.y;
    //take to the fourth power
    float r4=pow(r,4.);
    //convert back
    vec2 coef=toZ(vec2(r4,4.*t));

    //multiply this coeficient by the result
    return cMult(coef, res);

}


//compute g3 for a latitce given by a basis
vec2 g3(mat2 B){


    vec2 z=B[0];
    vec2 w=B[1];

    //get a tau where the lattice is homothetic to the one wiwht basis (1,tau)
    vec2 tau=cDiv(w,z);

    //compute g2 for this using Fourier series
    vec2 res=g3(tau);

    //now scale appropriately
    //convert to polar
    vec2 polar=fromZ(z);
    float r=polar.x;
    float t=polar.y;
    //take to the fourth power
    float r6=pow(r,6.);
    //convert back
    vec2 coef=toZ(vec2(r6,6.*t));


    //multiply this coeficient by the result
    return cMult(coef, res);

}



vec4 latticeCoords(mat2 B){
    //take in the basis of a lattice
    //return the point on S3 corresponding to it;

    //get the point in C2 parameterized by weierstrass invariants
    vec2 G2=g2(B);
    vec2 G3=g3(B);

    //get magnitude square of these
    float a=dot(G2,G2);
    float b=dot(G3,G3);

    //get the scaling factor to bring this lattice back to the 3 sphere
    float lambda=depressedCubicRoot(a,b);
    float lambda32=pow(abs(lambda),3./2.);

    return normalize(vec4(G2/lambda,G3/lambda32));
}




mat2 modFlow(mat2 B, float t){
    mat2 flow=mat2(exp(-t),0,0,exp(t));
    return flow*B;
}




//get the orthonormal frame for the flow at lattice B
mat4 modFlowFrame(mat2 B){
    float eps=0.05;

    mat2 B1=modFlow(B,eps);
    mat2 B2=modFlow(B,2.*eps);

    vec4 pos=latticeCoords(B);
    vec4 pos1=latticeCoords(B1);
    vec4 pos2=latticeCoords(B2);

    //tangent is just direction of infinitesimal separation
    vec4 tangent=normalize(pos1-pos);
    //make sure it is orthogonal to position
    tangent=normalize(tangent-dot(tangent,pos)*pos);

    //direction of curvature in R4 is the second derivative
    vec4 curve=normalize(pos2-2.*pos1+pos);
    //to get the normal vector from this, we subtract the position/tangential component
    vec4 normal=normalize(curve-dot(curve,pos)*pos-dot(curve,tangent)*tangent);

    //get binormal by solving for the vector orthogonal to the previous 3
    vec4 binormal=getBinormal(pos,tangent,normal);

    mat4 frame;
    frame[0]=pos;
    frame[1]=tangent;
    frame[2]=normal;
    frame[3]=binormal;

    return frame;

}


mat2 initialLattice=mat2(0.355051, 0.934847, -0.844949, 0.534847);
float flowTime=2.3;


mat2 adjustBasis(mat2 B){

    return B;
}

vec4 modFlowTube(float t, float s){

    float rad=0.05;

    //t is parameter along mod flow,
    //s is parameter around the tube

    //figure put where along the flow we are
    mat2 B=modFlow(initialLattice,t);

    //adjust the basis if it got way too long
    B=adjustBasis(B);

    //get the frame at this point
    mat4 frame=modFlowFrame(B);
    vec4 position=frame[0];
    vec4 normal=frame[2];
    vec4 binormal=frame[3];

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

    //params arive in (-0.5,0.5)^2: need to rescale
    params+=vec3(0.5,0.5,0.);
    //now in [0,1]^2: scale corrrectly for torus:
    float reach=flowTime*amplitude;
    float t=2.*reach*params.x-reach;
    float s=2.*PI*params.y;
    vec4 p;

    //get the point on the surface:
    p=modFlowTube(t, s);

    //project to R3:
    vec3 q=combinedProj(p);

    return q;
}