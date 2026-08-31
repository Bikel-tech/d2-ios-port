// touch_adapter.c
// Bridges iOS multitouch into AbyssEngine's mouse-driven input model.
//
// IMPORTANT: SDL2 on iOS ALREADY maps a single touch to mouse events by
// default, so basic tap/drag works without this file. This adapter exists to
// (a) give you a clean hook for virtual on-screen buttons (skill bar, belt,
// inventory) and (b) support multi-touch (pinch-zoom, second stick) later.
//
// Integration (one line in src/AbyssEngine.c, inside the event loop):
//   if (TouchAdapter_Process(&sdl_event)) continue;
// placed right before the existing InputManager_ProcessSdlEvent call.

#include "touch_adapter.h"
#include <stdbool.h>
#include <string.h>

// Virtual on-screen buttons for Diablo II, in the engine's logical 800x600
// space. Stored normalized [0..1] so they scale to any device resolution.
typedef struct {
    float nx, ny, nw, nh; // normalized rect
    const char *id;
} VirtualButton;

static VirtualButton g_buttons[] = {
    {0.02f, 0.78f, 0.10f, 0.10f, "skill1"},
    {0.14f, 0.78f, 0.10f, 0.10f, "skill2"},
    {0.02f, 0.60f, 0.10f, 0.10f, "inventory"},
    {0.86f, 0.78f, 0.12f, 0.10f, "belt"},
};
static const int G_BUTTON_COUNT = 4;

static int g_win_w = 800, g_win_h = 600;

void TouchAdapter_Init(int window_width, int window_height) {
    g_win_w = window_width > 0 ? window_width : 800;
    g_win_h = window_height > 0 ? window_height : 600;
}

// Returns the id of the virtual button under (x,y) in logical pixels, or NULL.
static const char *hit_button(float x, float y) {
    for (int i = 0; i < G_BUTTON_COUNT; i++) {
        VirtualButton *b = &g_buttons[i];
        if (x >= b->nx * g_win_w && x <= (b->nx + b->nw) * g_win_w &&
            y >= b->ny * g_win_h && y <= (b->ny + b->nh) * g_win_h) {
            return b->id;
        }
    }
    return NULL;
}

bool TouchAdapter_Process(SDL_Event *event) {
    if (event->type != SDL_FINGERDOWN &&
        event->type != SDL_FINGERMOTION &&
        event->type != SDL_FINGERUP) {
        return false;
    }

    SDL_TouchFingerEvent *f = &event->tfinger;
    float x = f->x * g_win_w;
    float y = f->y * g_win_h;

    // Reserve a tap on a virtual button for future action binding.
    if (event->type == SDL_FINGERDOWN) {
        const char *btn = hit_button(x, y);
        if (btn != NULL) {
            // TODO: dispatch the bound action (open inventory, use skill, etc.)
            return true; // consumed: don't also treat it as a world click
        }
    }

    // Primary finger (id 0) drives the mouse so existing code "just works".
    if (f->fingerId == 0) {
        SDL_Event synth;
        memset(&synth, 0, sizeof(synth));
        if (event->type == SDL_FINGERDOWN) {
            synth.type = synth.button.type = SDL_MOUSEBUTTONDOWN;
            synth.button.button = SDL_BUTTON_LEFT;
        } else if (event->type == SDL_FINGERMOTION) {
            synth.type = synth.motion.type = SDL_MOUSEMOTION;
        } else {
            synth.type = synth.button.type = SDL_MOUSEBUTTONUP;
            synth.button.button = SDL_BUTTON_LEFT;
        }
        synth.button.x = synth.motion.x = (int)x;
        synth.button.y = synth.motion.y = (int)y;
        SDL_PushEvent(&synth);
        return true; // synthetic event will be handled on the next poll
    }

    return false;
}
