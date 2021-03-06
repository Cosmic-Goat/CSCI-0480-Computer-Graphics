precision mediump float;

// MODIFY STRING TO ADD NUMBER OF SPHERES.
const int uNumSpheres = 5;
const int nL = 2;

// LIGHTS AND SPHERES DATA COMES FROM CPU.
uniform vec3 uLightsDir[nL];
uniform vec3 uLightCol[nL];

uniform vec4 uSpheres[uNumSpheres];
uniform mat4 uMats[uNumSpheres];

uniform float uTime;
varying vec3 vPos;

// YOU CAN CHANGE CAMERA FOCAL LENGTH.
// MAYBE YOU CAN TRY MAKING THIS A SLIDER.
float fl = 3.0;

const vec3 bgColor = vec3(.3, .4, .5);

// Number of reflection bounces
const int maxBounces = 3;

// INTERSECT A RAY WITH A SPHERE.
// IF NO INTERSECTION, RETURN NEGATIVE VALUE.
float raySphere(vec3 V, vec3 W, vec4 S) {
  V = V - S.xyz + .001 * W;
  float b = dot(V, W);
  float d = b * b - dot(V, V) + S.w * S.w;
  return d < 0. ? -1. : -b - sqrt(d);
}

// GOURAUD SHADING WITH CAST SHADOWS.
vec3 shadeSphere(vec3 P, vec3 W, vec3 N, vec4 S, mat4 m) {
  vec3 Ambient = m[0].rgb;
  vec3 Diffuse = m[1].rgb;
  vec4 Specular = m[2];

  vec3 c = Ambient;
  for (int l = 0; l < nL; l++) {

    // ARE WE SHADOWED BY ANY OTHER SPHERE?
    float t = -1.;
    for (int n = 0; n < uNumSpheres; n++)
      t = max(t, raySphere(P, uLightsDir[l], uSpheres[n]));

    // IF NOT, ADD LIGHTING FROM THIS LIGHT
    if (t < 0.) {
      vec3 R = 2. * dot(N, uLightsDir[l]) * N - uLightsDir[l];
      c += uLightCol[l] * Diffuse * max(0., dot(N, uLightsDir[l]));
      c += uLightCol[l] * Specular.rgb * pow(max(0., dot(R, -W)), Specular.w);
    }
  }

  return c;
}


vec3 trace(vec3 V, vec3 W) {
  vec3 color = vec3(0);
  float prop = 1.0;

  for (int bounce = 0; bounce <= maxBounces; bounce++) {

    float tMin = 10000.;
    vec3 P;
    vec4 sphere;
    mat4 mat;
    bool hit;

    for (int n = 0; n < uNumSpheres; n++) {
     float t = raySphere(V, W, uSpheres[n]);
      if (t > 0. && t < tMin) {
        hit = true;
        P = V + t * W;
        sphere = uSpheres[n];
        mat = uMats[n];
        tMin = t;
      }
    }

    if (hit) {

    vec3 N = normalize(P - sphere.xyz);
    color += prop * shadeSphere(P, W, N, sphere, mat);
    prop *= mat[3].w;

    V = P;
    W = 2. * N * dot(N, -W) + W;
    // color += 0.05 * uMats[n][2].rgb * trace(P, R, bounce);
    } else {
        break;
    }
  }
  return color;
}

void main() {

  // FORM THE RAY FOR THIS PIXEL.
  vec3 V = vec3(0., 0., fl);
  vec3 W = normalize(vec3(vPos.xy, -fl));

  // THEN SEE WHAT IT HITS FIRST.
  vec3 t = trace(V, W);
  vec3 color = (t == vec3(0)) ? bgColor : t;

  gl_FragColor = vec4(sqrt(color), 1.);
}
