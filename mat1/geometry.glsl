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
//Components for building the surface
//=============================================

vec3 sphCoords(float theta, float phi){
    float x=cos(theta)*sin(phi);
    float y=sin(theta)*sin(phi);
    float z=cos(phi);
    return vec3(x,y,z);
}



vec3 setInitialData(vec3 v){
    //turn v=(x,y,z) into a, alpha, c as in our paper
    v=normalize(v);
    float c=v.z;
    float a=sqrt(1.-c*c);
    float alpha=atan(v.y,v.x);
    return vec3(a,c,alpha);
}





vec3 nilGeodesic(float a, float c, float alpha,float t){
    float x=2.*a/c*sin(c*t/2.)*cos(c*t/2.+alpha);
    float y=2.*a/c*sin(c*t/2.)*sin(c*t/2.+alpha);
    float z=c*t+0.5*a*a/(c*c)*(c*t-sin(c*t));

    if(proj==0){
        return vec3(x,z+0.5*x*y,-y);
    }
    else{
        return vec3(x,z,-y);
    }

}

vec3 asymptoticExpansion(float a, float c, float alpha, float t){

        // factorize some computations...
        float cosa = cos(alpha);
        float sina = sin(alpha);
        float t1 = t;
        float t2 = t1 * t;
        float t3 = t2 * t;
        float t4 = t3 * t;
        float t5 = t4 * t;
        float t6 = t5 * t;
        float t7 = t6 * t;
        float t8 = t7 * t;
        float t9 = t8 * t;

        float c1 = c;
        float c2 = c1 * c;
        float c3 = c2 * c;
        float c4 = c3 * c;
        float c5 = c4 * c;
        float c6 = c5 * c;
        float c7 = c6 * c;

        float x=
        a * t1 * cosa
        - (1. / 2.) * a * t2 * c1 * sina
        - (1. / 6.) * a * t3 * c2 * cosa
        + (1. / 24.) * a * t4 * c3 * sina
        + (1. / 120.) * a * t5 * c4 * cosa
        - (1. / 720.) * a * t6 * c5 * sina
        - (1. / 5040.) * a * t7 * c6 * cosa
        + (1. / 40320.) * a * t8 * c7 * sina;

        float y=a * t * sina
        + (1. / 2.) * a * t2 * c1 * cosa
        - (1. / 6.) * a * t3 * c2 * sina
        - (1. / 24.) * a * t4 * c3 * cosa
        + (1. / 120.) * a * t5 * c4 * sina
        + (1. / 720.) * a * t6 * c5 * cosa
        - (1. / 5040.) * a * t7 * c6 * sina
        - (1. / 40320.) * a * t8 * c7 * cosa;

        float z=(1. / 12.) * (a * a * t3 + 12. * t1) * c1
        - (1. / 240.) * a * a * t5 * c3
        + (1. / 10080.) * a * a * t7 * c5
        - (1. / 725760.) * a * a * t9 * c7;

        if(proj==0){
            return vec3(x,z+0.5*x*y,-y);
        }
    else{
            return vec3(x,z,-y);
        }


}




vec3 flow(vec3 v, float t){
    vec3 ini=setInitialData(v);
    float a=ini.x;
    float c=ini.y;
    float alpha=ini.z;

    if(abs(c*t)<0.1){
        return asymptoticExpansion(a,c,alpha,t);
    }

    return nilGeodesic(a,c,alpha,t);

}


float areaDensity(vec3 v, float t){
    vec3 ini=setInitialData(v);
    float L=t*ini.x;
    float z=t*ini.y;
    float alpha=ini.z;
    float r=t*length(v);

    float z4=z*z*z*z;
    return 2.*r*r/z4*abs(sin(z/2.))*abs(L*L*z*cos(z/2.)-2.*r*r*sin(z/2.));
}


vec3 toHeisenberg(vec3 p){
    //this is after we have swapped the y and z axes
    float x=p.x;
    float z=p.z;
    float y=p.y+0.5*x*z;
    return vec3(x,y,z);
}

//=============================================
//Functions to Export
//=============================================




vec3 displace(vec3 params){

    //params arive in (-0.5,0.5)^2: need to rescale
    params+=vec3(0.5,0.5,0.);
    //now in [0,1]^2: scale orrrectly for torus:
    float theta=2.*rotx*PI*params.x;
    float phi=PI*params.y;

    vec3 v=sphCoords(theta,phi);
    float dist=50.*amplitude*(1.+sin(tumble*time));
    vec3 p=flow(v,dist);

    //apply the change to heisenberg model
    //p=toHeisenberg(p);

    //rescale the y coordinate
    float sgn=p.y/abs(p.y);
    p.y=sgn*pow(abs(p.y),0.7);

    return p;
}