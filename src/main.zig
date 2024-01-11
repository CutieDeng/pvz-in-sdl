const std = @import("std");

const sdl = @cImport(@cInclude("SDL.h")); 

const mixer = @cImport(@cInclude("SDL_mixer.h")); 

var g_window : ?*sdl.SDL_Window = null; 
var g_screen_surface : ?*sdl.SDL_Surface = null; 
var g_hello_world : ?*sdl.SDL_Surface = null; 

var renderer : ?*sdl.SDL_Renderer = null; 

var music : ?*mixer.Mix_Music = null; 
var scratch : ?*mixer.Mix_Chunk = null; 
var high : ?*mixer.Mix_Chunk = null; 
var med : ?*mixer.Mix_Chunk = null; 
var low : ?*mixer.Mix_Chunk = null; 

pub fn init() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_AUDIO) < 0) {
        std.log.err("SDL_Init: {s}\n", .{ sdl.SDL_GetError() }); 
        return error.error_default; 
    }
    if (mixer.Mix_OpenAudio(44100, mixer.MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
        std.log.err("Mix_OpenAudio: {s}\n", .{ sdl.SDL_GetError() }); 
        return error.error_default; 
    }
    g_window = sdl.SDL_CreateWindow("SDL Tutorial", sdl.SDL_WINDOWPOS_UNDEFINED, sdl.SDL_WINDOWPOS_UNDEFINED, 1200, 750, sdl.SDL_WINDOW_SHOWN); 
    if (g_window == null) {
        std.log.err("SDL_CreateWindow: {s}\n", .{ sdl.SDL_GetError() }); 
        return error.error_default; 
    }
    // g_screen_surface = sdl.SDL_GetWindowSurface(g_window); 
    renderer = sdl.SDL_CreateRenderer(g_window, -1, sdl.SDL_RENDERER_ACCELERATED); 
    if (renderer == null) {
        std.log.err("SDL_CreateRenderer: {s}\n", .{ sdl.SDL_GetError() }); 
        return error.error_default;
    }
    _ = sdl.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff); 
}

pub fn loadMedia() !void {
    g_hello_world = sdl.SDL_LoadBMP("res/hello_world.bmp"); 
    if (g_hello_world == null) {
        std.log.err("SDL_LoadBMP: {s}\n", .{ sdl.SDL_GetError() }); 
        return error.error_default; 
    } 
    scratch = mixer.Mix_LoadWAV("dududu.wav");
    if (scratch == null) {
        std.log.err("Mix_LoadWAV: {s}\n", .{ mixer.Mix_GetError() }); 
        return error.error_default; 
    }
}

pub fn close() void {
    mixer.Mix_FreeChunk(scratch); 
    scratch = null; 
    sdl.SDL_FreeSurface(g_hello_world); 
    g_hello_world = null; 
    sdl.SDL_DestroyRenderer(renderer); 
    renderer = null; 
    sdl.SDL_DestroyWindow(g_window); 
    g_window = null; 
    sdl.SDL_Quit(); 
    mixer.Mix_Quit(); 
}

const SdlError = error {
    error_default, 
}; 

pub fn main() !void {
    try init(); 
    try loadMedia(); 
    defer close(); 
    var texture : ?*sdl.SDL_Texture = null; 
    texture = sdl.SDL_CreateTextureFromSurface(renderer, g_hello_world);
    defer sdl.SDL_DestroyTexture(texture); 
    var e : sdl.SDL_Event = undefined; 
    var quit = false; 
    var rect: sdl.SDL_Rect = .{ 
        .x = 300, 
        .y = 200, 
        .w = 600, 
        .h = 400, 
    }; 
    while (!quit) {
        while (sdl.SDL_PollEvent(&e) != 0) {
            if (e.type == sdl.SDL_QUIT) {
                quit = true; 
            }
            if (e.type == sdl.SDL_KEYDOWN) {
                _ = mixer.Mix_PlayChannel(-1, scratch, 0); 
            }
        }
        _ = sdl.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0xff, 0xff); 
        _ = sdl.SDL_RenderClear(renderer); 
        _ = sdl.SDL_SetRenderDrawColor(renderer, 0xff, 0xff, 0x00, 0xff); 
        _ = sdl.SDL_RenderFillRect(renderer, &rect); 
        _ = sdl.SDL_RenderPresent(renderer);  
    } 
}