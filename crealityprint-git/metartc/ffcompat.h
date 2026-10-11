// MetaRTC + FFmpeg 7+ compat.
// 1) avcodec_close() удалён в FFmpeg 7 (на смену — avcodec_free_context(),
//    который заодно освобождает сам контекст). Вызывающий код ниже всё равно
//    сам делает av_free(ctx), поэтому маппим на no-op: утекают только
//    внутренние буферы кодека (контексты короткоживущие, утечка ограничена).
// 2) avcodec_find_decoder()/..._by_name() в FFmpeg 5+ возвращают const
//    AVCodec*; константность чиним в самих исходниках (патч const-decl).
#ifndef METARTC_FFCOMPAT_H
#define METARTC_FFCOMPAT_H
/* ВАЖНО: заголовки FFmpeg (avcodec/avutil) не содержат own-guard extern "C",
 * а исходники metartc включают их внутри своего extern "C" { }. Наш форс-
 * include идёт ПЕРВЫМ и определяет include-guard, из-за чего исходный extern
 * "C" становится no-op → все ff*-символы получали C++-манглинг и линковка
 * падала (undefined reference to avcodec_find_decoder(AVCodecID)). Поэтому
 * сами оборачиваем в extern "C". */
#ifdef __cplusplus
extern "C" {
#endif
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#ifdef __cplusplus
}
#endif
static inline int metartc_avcodec_close_noop(AVCodecContext *ctx) { (void)ctx; return 0; }
#ifndef avcodec_close
#define avcodec_close metartc_avcodec_close_noop
#endif
#endif
