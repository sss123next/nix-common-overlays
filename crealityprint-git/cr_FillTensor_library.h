#ifndef CR_FILLTENSOR_LIBRARY_STUB_H
#define CR_FILLTENSOR_LIBRARY_STUB_H

// Stub header for the closed-source cr_FillTensor_library.
// The real library is proprietary Creality code for tensor-driven
// infill generation. This stub returns no-op handles and values
// so the slicer compiles without it. Field/tensor fill will be
// disabled at runtime.

#ifdef __cplusplus
extern "C" {
#endif

typedef void* FillTensorHandle;

static inline FillTensorHandle FillTensor_Create(int cell_type) {
    (void)cell_type;
    return (FillTensorHandle)0; // NULL — disabled
}

static inline void FillTensor_Destroy(FillTensorHandle handle) { (void)handle; }

static inline void FillTensor_SetParams(FillTensorHandle handle,
    float surface_density, float interior_density, float scale_w_factor)
{
    (void)handle; (void)surface_density; (void)interior_density;
    (void)scale_w_factor;
}

static inline int FillTensor_SetFieldAndCompute(FillTensorHandle handle,
    const float* sdf_grid, int nx, int ny, int nz,
    float gap,
    float bbox_min_x, float bbox_min_y, float bbox_min_z)
{
    (void)handle; (void)sdf_grid; (void)nx; (void)ny; (void)nz;
    (void)gap;
    (void)bbox_min_x; (void)bbox_min_y; (void)bbox_min_z;
    return 1; // error — no real library
}

static inline float FillTensor_Query(FillTensorHandle handle,
    float x, float y, float z)
{
    (void)handle; (void)x; (void)y; (void)z;
    return 1.0f; // outside (void)
}

static inline void FillTensor_QueryBatch(FillTensorHandle handle,
    const float* points, float* results, int count)
{
    (void)handle; (void)points;
    for (int i = 0; i < count; i++)
        results[i] = 1.0f; // outside (void)
}

#ifdef __cplusplus
}
#endif

#endif // CR_FILLTENSOR_LIBRARY_STUB_H
