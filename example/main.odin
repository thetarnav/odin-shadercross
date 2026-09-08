package example

import "core:fmt"
import sdl "vendor:sdl3"
import shadercross ".."

prop_id: sdl.PropertiesID

main :: proc () {
	if !init() do return
	defer quit()

	graphics_shader_compile("./vert.hlsl", .VERTEX)

	fmt.println("Done")
}

init :: proc () -> (ok: bool) {

	ok = sdl.Init({.VIDEO})
	fmt.assertf(ok, "unable to initialize sdl, error: %s", sdl.GetError())

	ok = shadercross.Init()
	fmt.assertf(ok, "unable to initialize shadercross, error: %s", sdl.GetError())

	prop_id = sdl.CreateProperties()

	return true
}

quit :: proc () {
	sdl.DestroyProperties(prop_id)
	shadercross.Quit()
	sdl.Quit()
}

graphics_shader_compile :: proc ($FILEPATH: string, stage: shadercross.ShaderStage) {

	SHADER     :: #load(FILEPATH, cstring)
	DEBUG_NAME :: cstring(FILEPATH)

	sdl.SetStringProperty(prop_id, shadercross.PROP_SHADER_DEBUG_NAME_STRING, DEBUG_NAME)
	defer sdl.ClearProperty(prop_id, shadercross.PROP_SHADER_DEBUG_NAME_STRING)

	STAGE_RUNE :: rune(FILEPATH[len(FILEPATH) - 1 - 5])

	size: uint
	spirv := shadercross.CompileSPIRVFromHLSL({SHADER, "main", nil, nil, stage, prop_id}, &size)
	fmt.assertf(spirv != nil, "unable to compile SPIRV from HLSL, error: %s", sdl.GetError())

	fmt.println("SPIRV", string(spirv[:size]))

	reflect := shadercross.ReflectGraphicsSPIRV(spirv, size, prop_id)

	fmt.println("reflect", reflect)
}
