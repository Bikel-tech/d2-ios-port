#ifndef TOUCH_ADAPTER_H
#define TOUCH_ADAPTER_H

#include <SDL2/SDL.h>

// Initialize the touch adapter. Pass the engine's logical window size
// (AbyssEngine uses SDL_RenderSetLogicalSize(800, 600)).
void TouchAdapter_Init(int window_width, int window_height);

// Call this from the SDL event loop BEFORE InputManager_ProcessSdlEvent.
// Translates a primary touch into the engine's existing mouse events so
// "tap = click" and "drag = move" work out of the box, and lets you wire
// secondary touches / virtual buttons later.
// Returns true if the event was consumed (a synthesized event was queued).
bool TouchAdapter_Process(SDL_Event *event);

#endif // TOUCH_ADAPTER_H
