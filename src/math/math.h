
#ifndef _MATH_H_

#include <nm_auto_config.h>
#include <nm_auto_headers.h>

#if (MSYS_NT)

#define GEO_API __declspec(dllimport) __stdcall

#ifdef __cplusplus
extern "C" {
#endif

double GEO_API area_of_rect(double, double);

#ifdef __cplusplus
}
#endif

#else

double area_of_rect(double, double);

#endif // MSYS_NT


#endif // _MATH_H_
