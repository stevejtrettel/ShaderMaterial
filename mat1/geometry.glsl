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


vec3 stereographicProjX(vec4 p){

    if(p.x>-0.999){

        return p.yzw/(p.x+1.0);
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




//=============================================
//More 3-Sphere Stuff (For Knots)
//=============================================

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


//this is conformal: so can find tang/normal beforehand and then use deriv matrix
vec4 invStereo(vec3 p){
    float r2=dot(p,p);
    vec4 q = vec4(2.*p, r2-1.)/(r2+1.);
    return q;
}



vec3 polarCoords(float r, float theta, float phi){
    float x=cos(theta)*sin(phi);
    float y=sin(theta)*sin(phi);
    float z=cos(phi);
    return r*vec3(x,y,z);
}









//=============================================
//KNOTS IN R3
//=============================================



vec3 fig8(float t){
    float r=2.+cos(2.*t);
    vec3 p=vec3(r*cos(3.*t),r*sin(3.*t),sin(4.*t));
    return p;
}

vec3 fig8_2(float t){
    float x = 10.*(cos(t) + cos(3.*t)) + cos(2.*t) + cos(4.* t);
    float y = 6. * sin(t) + 10. * sin(3.* t);
    float z = 4. * sin(3.* t) * sin(5.* t / 2.) + 4. * sin(4. * t) - 2. * sin(6. * t);
    return vec3(x,y,z)/5.;
}


vec3 granny(float u){
    float x = -22. * cos(u) - 128. * sin(u) - 44. * cos(3. * u) - 78. * sin(3. * u);
    float y = -10. * cos(2. * u) - 27. * sin(2. * u) + 38. * cos(4. * u) + 46. * sin(4. * u);
    float z = 70. * cos(3. * u) - 40. * sin(3. * u);
    return vec3(x,y,z)/100.;
}

vec3 polarKnot(float t){
    float r= 0.8 + 1.6 * sin(3. * t);
    float theta=t;
    float phi=0.6 * PI * sin(6. * t);

    return polarCoords(r,theta,phi);
}


//=============================================
//KNOTS IN R4
//=============================================



vec4 torusKnot(float t){
    //the knot lying on the Clifford torus
    float freq1=3.;
    float freq2=2.;
    float r1=1.;
    float r2=6.;
    vec2 uCirc=vec2(cos(freq1*t), sin(freq1*t));
    vec2 vCirc=vec2(cos(freq2*t), sin(freq2*t));

    //rescaling to lie on the rU-rV torus
    vec4 p=normalize(vec4(r1*uCirc, r2*vCirc));

    return p;
}




//=============================================
//CHOOSING AND RENDERING A KNOT
//=============================================


vec3 KnotR3(float t){
    return fig8(t);
}



vec4 Knot(float t){

    // return torusKnot(t);

    vec3 p=KnotR3(t);
    vec4 q=invStereo(p);
    return normalize(q);
}


//get the orthonormal frame for the flow at lattice B
mat4 KnotFrame(float t){
    float eps=0.01;

    //get three positions
    vec4 pos=Knot(t-eps);
    vec4 pos1=Knot(t);
    vec4 pos2=Knot(t+eps);


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

    // vec4 binormal=normalize(bin-dot(bin,pos)*pos-dot(bin,tangent)*tangent-dot(bin,normal)*normal);

    mat4 frame;
    frame[0]=pos1;
    frame[1]=tangent;
    frame[2]=normal;
    frame[3]=binormal;

    return frame;
}





vec4 KnotSurface(float t, float s){
    //t is along the trefoil, s is around the tube

    float rad=0.2*amplitude;

    //get the frame at this point
    mat4 frame=KnotFrame(t);
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



vec3 KnotProj(vec4 p, float t){
    //project from the point Knot(t):
    //negation here is so knot point ends up at antipode of e1, which is proj point.
    mat4 B=-KnotFrame(2.*PI*t);

    //this is the inverse matrix
    vec4 q=transpose(B)*p;

    return stereographicProjX(q);

}




//=============================================
//Functions to Export
//=============================================




vec3 displace(vec3 params){

    //params arive in (-0.5,0.5)^2: need to rescale
    params+=vec3(0.5,0.5,0.);

    //float t=reach*(params.x-0.5);
    float t=2.*PI*params.x;
    float s=2.*PI*params.y;
    vec4 p;


    //TO DRAW A KNOT: UNCOMMENT THESE TWO LINES
    //get the point on the surface:
    //    p=KnotSurface(t,s);
    //    vec3 q=KnotProj(p,0.1*tumble*time);

    //TO DRAW A FLAT TORUS, UNCOMMENT THESE TWO
    //get the point on the surface:
    p=hopfSurface(t, s);
    //project to R3:
    vec3 q=combinedProj(p);




    return q;
}









//=============================================
//Functions to Export
//=============================================

//
//
//
//vec3 displace(vec3 params){
//
//    //params arive in (-0.5,0.5)^2: need to rescale
//    params+=vec3(0.5,0.5,0.);
//    //now in [0,1]^2: scale orrrectly for torus:
//    float t=2.*PI*params.x;
//    float s=2.*PI*params.y;
//    vec4 p;
//
//    //get the point on the surface:
//    p=hopfSurface(t, s);
//
//    //project to R3:
//    vec3 q=combinedProj(p);
//
//    return q;
//}