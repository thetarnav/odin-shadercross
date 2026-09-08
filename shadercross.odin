/*
  Simple DirectMedia Layer Shader Cross Compiler
  Copyright (C) 2024 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

package sdl_shadercross

import "core:c"
import sdl "vendor:sdl3"

SDL_SHADERCROSS_SYSTEM :: #config(SDL_SHADERCROSS_SYSTEM, false)

when SDL_SHADERCROSS_SYSTEM {
	when ODIN_OS == .Windows {SDL_SHADERCROSS_LIB_PATH :: "system:SDL3_shadercross.lib"}
	else                     {SDL_SHADERCROSS_LIB_PATH :: "system:SDL3_shadercross"}
} else {
	when      ODIN_OS == .Windows {SDL_SHADERCROSS_LIB_PATH :: "lib/SDL3_shadercross.lib"}
	else when ODIN_OS == .Darwin  {SDL_SHADERCROSS_LIB_PATH :: "lib/libSDL3_shadercross.dylib"}
	else                          {SDL_SHADERCROSS_LIB_PATH :: "lib/libSDL3_shadercross.so"}
}

@(export) foreign import lib {SDL_SHADERCROSS_LIB_PATH}

MAJOR_VERSION :: 3
MINOR_VERSION :: 0
MICRO_VERSION :: 0

PROP_SPIRV_PSSL_COMPATIBILITY :: "SDL.shadercross.spirv.pssl.compatibility"
PROP_SPIRV_MSL_VERSION        :: "SDL.shadercross.spirv.msl.version"

IOVarType :: enum c.int {
    UNKNOWN,
    INT8,
    UINT8,
    INT16,
    UINT16,
    INT32,
    UINT32,
    INT64,
    UINT64,
    FLOAT16,
    FLOAT32,
    FLOAT64,
}

ShaderStage :: enum c.int {
   VERTEX,
   FRAGMENT,
   COMPUTE,
}

IOVarMetadata :: struct {
    name:        cstring,    // < The UTF-8 name of the variable.
    location:    sdl.Uint32, // < The location of the variable.
    vector_type: IOVarType,  // < The vector type of the variable.
    vector_size: sdl.Uint32, // < The number of components in the vector type of the variable.
}

GraphicsShaderMetadata :: struct {
    num_samplers:         sdl.Uint32,       // < The number of samplers defined in the shader.
    num_storage_textures: sdl.Uint32,       // < The number of storage textures defined in the shader.
    num_storage_buffers:  sdl.Uint32,       // < The number of storage buffers defined in the shader.
    num_uniform_buffers:  sdl.Uint32,       // < The number of uniform buffers defined in the shader.
    num_inputs:           sdl.Uint32,       // < The number of inputs defined in the shader.
    inputs:               [^]IOVarMetadata, // < The inputs defined in the shader.
    num_outputs:          sdl.Uint32,       // < The number of outputs defined in the shader.
    outputs:              [^]IOVarMetadata, // < The outputs defined in the shader.
}

ComputePipelineMetadata :: struct {
    num_samplers:                   sdl.Uint32,  // < The number of samplers defined in the shader.
    num_readonly_storage_textures:  sdl.Uint32,  // < The number of readonly storage textures defined in the shader.
    num_readonly_storage_buffers:   sdl.Uint32,  // < The number of readonly storage buffers defined in the shader.
    num_readwrite_storage_textures: sdl.Uint32,  // < The number of read-write storage textures defined in the shader.
    num_readwrite_storage_buffers:  sdl.Uint32,  // < The number of read-write storage buffers defined in the shader.
    num_uniform_buffers:            sdl.Uint32,  // < The number of uniform buffers defined in the shader.
    threadcount_x:                  sdl.Uint32,  // < The number of threads in the X dimension.
    threadcount_y:                  sdl.Uint32,  // < The number of threads in the Y dimension.
    threadcount_z:                  sdl.Uint32,  // < The number of threads in the Z dimension.
}

SPIRV_Info :: struct {
    bytecode:      [^]byte,          // < The SPIRV bytecode.
    bytecode_size: uint,             // < The length of the SPIRV bytecode.
    entrypoint:    cstring,          // < The entry point function name for the shader in UTF-8.
    shader_stage:  ShaderStage,      // < The shader stage to transpile the shader with.
    enable_debug:  bool,             // < Allows debug info to be emitted when relevant. Can be useful for graphics debuggers like RenderDoc.
    name:          Maybe(cstring),   // < A UTF-8 name to associate with the shader. Optional, can be NULL.
    props:         sdl.PropertiesID, // < A properties ID for extensions. Should be 0 if no extensions are needed.
}

HLSL_Define :: struct {
    name:         cstring,        // < The define name.
    value:        Maybe(cstring), // < An optional value for the define. Can be NULL.
}

HLSL_Info :: struct {
    source:       cstring,               // < The HLSL source code for the shader.
    entrypoint:   cstring,               // < The entry point function name for the shader in UTF-8.
    include_dir:  Maybe(cstring),        // < The include directory for shader code. Optional, can be NULL.
    defines:      Maybe([^]HLSL_Define), // < An array of defines. Optional, can be NULL. If not NULL, must be terminated with a fully NULL define struct.
    shader_stage: ShaderStage,           // < The shader stage to compile the shader with.
    enable_debug: bool,                  // < Allows debug info to be emitted when relevant. Can be useful for graphics debuggers like RenderDoc.
    name:         Maybe(cstring),        // < A UTF-8 name to associate with the shader. Optional, can be NULL.
    props:        sdl.PropertiesID,      // < A properties ID for extensions. Should be 0 if no extensions are needed.
}

@(default_calling_convention="c", link_prefix="SDL_ShaderCross_")
foreign lib {
	/*
	Initializes shadercross

	threadsafety: This should only be called once, from a single thread.
	returns: true on success, false otherwise.
	*/
	Init :: proc () -> bool ---
	/*
	De-initializes shadercross

	threadsafety: This should only be called once, from a single thread.
	*/
	Quit :: proc () ---
}


@(default_calling_convention="c", link_prefix="SDL_ShaderCross_", require_results)
foreign lib {
	/*
	Get the supported shader formats that SPIRV cross-compilation can output

	threadsafety: It is safe to call this function from any thread.
	returns: GPU shader formats supported by SPIRV cross-compilation.
	*/
	GetSPIRVShaderFormats :: proc () -> sdl.GPUShaderFormat ---

	/*
	Transpile to MSL code from SPIRV code.

	You must sdl.free the returned string once you are done with it.

	param: info a struct describing the shader to transpile.
	returns: an sdl.malloc'd string containing MSL code.
	*/
	TranspileMSLFromSPIRV :: proc (#by_ptr info: SPIRV_Info) -> cstring ---

	/*
	Transpile to HLSL code from SPIRV code.

	You must sdl.free the returned string once you are done with it.

	param: info a struct describing the shader to transpile.
	returns: an sdl.malloc'd string containing HLSL code.
	*/
	TranspileHLSLFromSPIRV :: proc (#by_ptr info: SPIRV_Info) -> cstring ---

	/*
	Compile DXBC bytecode from SPIRV code.

	You must sdl.free the returned buffer once you are done with it.

	param: info a struct describing the shader to transpile.
	param: size filled in with the bytecode buffer size.
	returns: an sdl.malloc'd buffer containing DXBC bytecode.
	*/
	CompileDXBCFromSPIRV :: proc (#by_ptr info: SPIRV_Info, size: ^uint) -> [^]byte ---

	/*
	Compile DXIL bytecode from SPIRV code.

	You must sdl.free the returned buffer once you are done with it.

	param: info a struct describing the shader to transpile.
	param: size filled in with the bytecode buffer size.
	returns: an sdl.malloc'd buffer containing DXIL bytecode.
	*/
	CompileDXILFromSPIRV :: proc (#by_ptr info: SPIRV_Info, size: ^uint) -> [^]byte ---

	/*
	Compile an SDL GPU shader from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL().

	param: device the SDL GPU device.
	param: info a struct describing the shader to transpile.
	param: metadata a struct describing shader metadata. Can be obtained from ReflectGraphicsSPIRV().
	param: props a properties object filled in with extra shader metadata.
	returns: a compiled sdl.GPUShader.

	threadsafety: It is safe to call this function from any thread.
	*/
	CompileGraphicsShaderFromSPIRV :: proc (
		        device:   ^sdl.GPUDevice,
		#by_ptr info:     SPIRV_Info,
		#by_ptr metadata: GraphicsShaderMetadata,
		        props:    sdl.PropertiesID,
	) -> ^sdl.GPUShader ---

	/*
	Compile an SDL GPU compute pipeline from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL().

	param: device the SDL GPU device.
	param: info a struct describing the shader to transpile.
	param: metadata a struct describing shader metadata. Can be obtained from ReflectComputeSPIRV().
	param: props a properties object filled in with extra shader metadata.
	returns: a compiled sdl.GPUComputePipeline.

	threadsafety: It is safe to call this function from any thread.
	*/
	CompileComputePipelineFromSPIRV :: proc (
		        device:   ^sdl.GPUDevice,
		#by_ptr info:     SPIRV_Info,
		#by_ptr metadata: ComputePipelineMetadata,
		        props:    sdl.PropertiesID,
	) -> ^sdl.GPUComputePipeline ---

	/*
	Reflect graphics shader info from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL(). This must be freed with sdl.free() when you are done with the metadata.

	param: bytecode the SPIRV bytecode.
	param: bytecode_size the length of the SPIRV bytecode.
	param: props a properties object filled in with extra shader metadata, provided by the user.
	returns: A metadata struct on success, NULL otherwise. The struct must be free'd when it is no longer needed.

	threadsafety: It is safe to call this function from any thread.
	*/
	ReflectGraphicsSPIRV :: proc (
		bytecode:      [^]byte,
		bytecode_size: uint,
		props:         sdl.PropertiesID,
	) -> ^GraphicsShaderMetadata ---

	/*
	Reflect compute pipeline info from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL(). This must be freed with sdl.free() when you are done with the metadata.

	param: bytecode the SPIRV bytecode.
	param: bytecode_size the length of the SPIRV bytecode.
	param: props a properties object filled in with extra shader metadata, provided by the user.
	returns: A metadata struct on success, NULL otherwise.

	threadsafety: It is safe to call this function from any thread.
	*/
	ReflectComputeSPIRV :: proc (
		bytecode:      [^]byte,
		bytecode_size: uint,
		props:         sdl.PropertiesID,
	) -> ^ComputePipelineMetadata ---

	/*
	Get the supported shader formats that HLSL cross-compilation can output

	returns: GPU shader formats supported by HLSL cross-compilation.

	threadsafety: It is safe to call this function from any thread.
	*/
	GetHLSLShaderFormats :: proc () -> sdl.GPUShaderFormat ---

	/*
	Compile to DXBC bytecode from HLSL code via a SPIRV-Cross round trip.

	You must sdl.free the returned buffer once you are done with it.

	param: info a struct describing the shader to transpile.
	param: size filled in with the bytecode buffer size.
	returns: an sdl.malloc'd buffer containing DXBC bytecode.

	threadsafety: It is safe to call this function from any thread.
	*/
	CompileDXBCFromHLSL :: proc (
		#by_ptr info: HLSL_Info,
		        size: ^uint,
	) -> [^]byte ---

	/*
	Compile to DXIL bytecode from HLSL code via a SPIRV-Cross round trip.

	You must sdl.free the returned buffer once you are done with it.

	param: info a struct describing the shader to transpile.
	param: size filled in with the bytecode buffer size.
	returns: an sdl.malloc'd buffer containing DXIL bytecode.

	threadsafety: It is safe to call this function from any thread.
	*/
	CompileDXILFromHLSL :: proc (
		#by_ptr info: HLSL_Info,
		        size: ^uint,
	) -> [^]byte ---

	/*
	Compile to SPIRV bytecode from HLSL code.

	You must sdl.free the returned buffer once you are done with it.

	param: info a struct describing the shader to transpile.
	param: size filled in with the bytecode buffer size.
	returns: an sdl.malloc'd buffer containing SPIRV bytecode.

	threadsafety: It is safe to call this function from any thread.
	*/
	CompileSPIRVFromHLSL :: proc (
		#by_ptr info: HLSL_Info,
		        size: ^uint,
	) -> [^]byte ---
}
