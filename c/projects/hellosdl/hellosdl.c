// Opens a blue window: if you can see it on the desktop, graphics work.
// Close the window to end the program.
#include <SDL2/SDL.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

static void check(bool ok, const char *what) {
    if (!ok) {
        fprintf(stderr, "%s failed: %s\n", what, SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }
}

int main(void) {
    check(SDL_Init(SDL_INIT_VIDEO) == 0, "SDL_Init");
    SDL_Window *window =
        SDL_CreateWindow("Hello SDL2", SDL_WINDOWPOS_UNDEFINED,
                         SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_SHOWN);
    check(window != NULL, "SDL_CreateWindow");
    // Accelerated, like the course's display code: this needs OpenGL
    SDL_Renderer *renderer =
        SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    check(renderer != NULL, "SDL_CreateRenderer");

    SDL_Event event;
    do {
        SDL_SetRenderDrawColor(renderer, 90, 90, 255, 255);
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);
    } while (SDL_WaitEvent(&event) && event.type != SDL_QUIT);

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;
}
