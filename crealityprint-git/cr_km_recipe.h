#ifndef CR_KM_RECIPE_STUB_H
#define CR_KM_RECIPE_STUB_H

// Stub header for the closed-source cr_km_recipe library.
// The real library is proprietary Creality code (K-M recipe engine).
// This stub provides no-op implementations so the slicer compiles
// without the closed-source library. Color decomposition features
// that depend on it will be unavailable at runtime.

#include <cstdint>
#include <cstddef>

#ifdef __cplusplus
extern "C" {
#endif

#define C3DKM_SPECTRUM_POINTS 43
#define C3DKM_CIE_POINTS      41

typedef struct { double v[C3DKM_SPECTRUM_POINTS]; } C3dkmSpectrum;
typedef struct { double x, y, z; } C3dkmXyz;
typedef struct { double L, a, b; } C3dkmLab;
typedef struct { unsigned char r, g, b; } C3dkmSrgb;

struct C3dRecipeComponent {
    int          ratio;
    unsigned int filament_index;
    char         color_hex[8];
    char         base_color[16];
    int          has_spectrum;
    double       spectrum[C3DKM_SPECTRUM_POINTS];
};

struct C3dRecipeResult {
    int  valid;
    int  mode;
    char matched_color_hex[8];
    unsigned int component_count;
    C3dRecipeComponent* components;
    unsigned int        components_capacity;
};

struct CRCloseFilament {
    const char* color_hex;
    const char* name;
    const char* type;
    unsigned int filament_index;
    int has_spectrum;
    const double* spectrum;
};

struct CRCloseComponent {
    const char* color_hex;
    const char* base_color;
    int          ratio;
    unsigned int filament_index;
    int          has_spectrum;
    const double* spectrum;
};

struct CRCloseRecipeResult {
    int           valid;
    int           mode;
    const char*   matched_color_hex;
    unsigned int  component_count;
    const CRCloseComponent* components;
};

// --- Stub implementations ---

static inline double c3dkm_function(double r_fraction) { (void)r_fraction; return 0.0; }
static inline double c3dkm_inverse(double ks) { (void)ks; return 0.0; }

static inline int c3dkm_mix_spectra(
    const C3dkmSpectrum* spectra, const int* weights,
    unsigned int count, double* out_spectrum)
{
    (void)spectra; (void)weights; (void)count;
    for (unsigned int i = 0; i < C3DKM_SPECTRUM_POINTS; i++)
        out_spectrum[i] = 0.0;
    return 0;
}

static inline C3dkmXyz c3dkm_reflectance_to_xyz(const double* spectrum) {
    (void)spectrum;
    C3dkmXyz r = {0,0,0};
    return r;
}
static inline C3dkmLab c3dkm_xyz_to_lab(C3dkmXyz xyz) {
    (void)xyz;
    C3dkmLab r = {0,0,0};
    return r;
}
static inline C3dkmSrgb c3dkm_lab_to_srgb(C3dkmLab lab) {
    (void)lab;
    C3dkmSrgb r = {0,0,0};
    return r;
}
static inline C3dkmLab c3dkm_srgb_to_lab(C3dkmSrgb rgb) {
    (void)rgb;
    C3dkmLab r = {0,0,0};
    return r;
}
static inline double c3dkm_delta_e76(C3dkmLab a, C3dkmLab b) {
    (void)a; (void)b;
    return 0.0;
}
static inline int c3dkm_rgb_to_hex(C3dkmSrgb rgb, char* out_hex) {
    (void)rgb;
    out_hex[0] = '#';
    out_hex[1] = '0';
    out_hex[2] = '0';
    out_hex[3] = '0';
    out_hex[4] = '0';
    out_hex[5] = '0';
    out_hex[6] = '0';
    out_hex[7] = 0;
    return 0;
}
static inline int c3dkm_hex_to_rgb(const char* hex, C3dkmSrgb* out_rgb) {
    (void)hex; (void)out_rgb;
    return 0;
}

#define C3D_RECIPE_MODE_MATERIAL_LIST 0
#define C3D_RECIPE_MODE_CMYW          1
#define C3D_RECIPE_MODE_RYBW          2

static inline int c3d_recipe_recommend_from_physical_filaments(
    C3dkmSrgb target_rgb,
    const C3dkmSrgb* filament_colors,
    const unsigned int* filament_indices,
    unsigned int filament_count,
    const char* preferred_material_type,
    C3dRecipeResult* out_result)
{
    (void)target_rgb; (void)filament_colors; (void)filament_indices;
    (void)filament_count; (void)preferred_material_type;
    out_result->valid = 0;
    out_result->component_count = 0;
    return 0;
}

static inline int c3d_recipe_lookup_standard_recipe(
    C3dkmSrgb target_rgb, int mode,
    const char* preferred_material_type,
    C3dRecipeResult* out_result)
{
    (void)target_rgb; (void)mode; (void)preferred_material_type;
    out_result->valid = 0;
    out_result->component_count = 0;
    return 0;
}

static inline int c3d_recipe_has_base_color_spectrum(
    int mode, const char* material, const char* base_color)
{
    (void)mode; (void)material; (void)base_color;
    return 0;
}

static inline void c3d_recipe_set_resources_dir(const char* path) { (void)path; }

static inline int cr_close_recommend_from_physical_filaments(
    unsigned char target_r, unsigned char target_g, unsigned char target_b,
    const CRCloseFilament* filaments, unsigned int filament_count,
    const char* preferred_material_type,
    CRCloseRecipeResult* out_result)
{
    (void)target_r; (void)target_g; (void)target_b;
    (void)filaments; (void)filament_count; (void)preferred_material_type;
    out_result->valid = 0;
    out_result->component_count = 0;
    return 0;
}

static inline int cr_close_lookup_standard_recipe(
    unsigned char target_r, unsigned char target_g, unsigned char target_b,
    int mode, const char* preferred_material_type,
    CRCloseRecipeResult* out_result)
{
    (void)target_r; (void)target_g; (void)target_b;
    (void)mode; (void)preferred_material_type;
    out_result->valid = 0;
    out_result->component_count = 0;
    return 0;
}

static inline int cr_close_has_base_color_spectrum(
    int mode, const char* material, const char* base_color)
{
    (void)mode; (void)material; (void)base_color;
    return 0;
}

static inline const char* cr_close_get_base_official_hex(
    int mode, const char* material, const char* base_color)
{
    (void)mode; (void)material; (void)base_color;
    return "#000000";
}

static inline int cr_close_km_blend_color_multi_hex(
    const char* const* hex_colors, const int* weights,
    unsigned int count, char* out_hex)
{
    (void)hex_colors; (void)weights; (void)count;
    out_hex[0] = '#';
    out_hex[1] = '0';
    out_hex[2] = '0';
    out_hex[3] = '0';
    out_hex[4] = '0';
    out_hex[5] = '0';
    out_hex[6] = '0';
    out_hex[7] = 0;
    return 0;
}

static inline void cr_close_set_resources_dir(const char* path) { (void)path; }

#ifdef __cplusplus
}
#endif

#endif // CR_KM_RECIPE_STUB_H
