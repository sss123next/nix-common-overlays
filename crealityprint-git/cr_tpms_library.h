#ifndef CR_TPMS_LIBRARY_STUB_H
#define CR_TPMS_LIBRARY_STUB_H

// Stub header for the closed-source cr_tpms_library.
// The real library is proprietary Creality code. This stub returns
// zero (no-op) for all entry points so the slicer can compile and
// run without it. TPMS gradual infill will be disabled.

#ifdef __cplusplus
extern "C" {
#endif

static inline float scalar_function_test(
    float x, float y, float z,
    float bbox_min_x, float bbox_min_y, float bbox_min_z,
    float bbox_max_x, float bbox_max_y, float bbox_max_z,
    int axis, int celltype,
    float infill_density1, float infill_density2)
{
    (void)x; (void)y; (void)z;
    (void)bbox_min_x; (void)bbox_min_y; (void)bbox_min_z;
    (void)bbox_max_x; (void)bbox_max_y; (void)bbox_max_z;
    (void)axis; (void)celltype;
    (void)infill_density1; (void)infill_density2;
    return 0.0f;
}

#ifdef __cplusplus
}
#endif

#endif // CR_TPMS_LIBRARY_STUB_H
