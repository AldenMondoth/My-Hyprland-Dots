# My Dotfiles for Arch Hyprland 0.57+

## About This Config
This serving of rice uses Hyprland 0.57+ on Arch with a focus on a more modern yet still minimalist implementation.
Almost all of the animations are springs, specifically tuned to be symmetric across various UI elements.


A lot of the hyprland dotfiles were originally in hyprlang, which I lua-fied after updating to 0.57.

### A Little Bit About This Project

This started off as an Ubuntu Hyprland config, set up a while ago from JaKooLit's Hyprland Dotfiles - so I guess it could be called an unofficial fork?
Over the course of my usage, though, I've added my own changes, which at this point I think is enough to call it my own.

However, I did retain a lot of the core functionalities from JaKoolit's configs, and most of his shell scripts, Keybinds, etc are mostly the same.

### three types of changes from JaKooLit:

+ -> No change whatsoever, keeping a lot of the bash scripts and making minor changes :)
+ -> directly converting from hyprlang to the Hyprland Lua API - all the UserConfig files are a direct port to lua, with a few modifications in code logic
+ -> Complete change in code and logic - the animations and system settings were designed and tuned by me
    
Make sure to double check if your system uses the same dependencies and packages, and also double check the [**hyprland wiki**](https://wiki.hypr.land/). 


### A List of General Changes from JaKoolit's Dots

NOT AN OFFICIAL CHANGELOG

In no particular order:

1. The obvious one: complete lua-ficiation wherever possible
2. Switched from swww to awww for the wallpaper daemon
3. Got rid of the waybar for a more discreet custom pleamar bar
4. moved from swaync to pleamar for notifications as well 
5. switched from bezier curves to uniform spring animations
6. Custom Window Rules and Decorations


## AI Usage

NO AGENTIC MODELS WERE USED IN THIS PROJECT.

99.9% of the Hyprland Lua code was handwritten without AI, reading straight from the Hyprland versioned wiki.
There were occasional syntax questions I had where I did consult AI, but these changes were made and tested by me.

Pleamar, on the other hand, is a bit more of an unconventional scenario.
The dev who created and is maintaining Pleamar uses Claude, 
and you can tell. There were two issues with actually writing Pleamar .plm code myself - one is that since it isn't as well established as Hyprland or QuickShell,
it can be difficult to find information on how the entire package works. On top of that, the docs are very difficult to read since they were written by AI. 
However, the dev has created skills for your own agent to learn pleamar, so I guess it was intended to be that way.

I had Github Copilot read the Pleamar repo while I prompted it questions about syntax and code snippets. 
Afterward, the code was modified by me for my requirements. Excuse the terrible formatting - as of now everything for the mini pleamar bar is sitting in one .plm file, 
which I plan on reformatting and making it more generalizable.


## Performance

I use a laptop with an Intel Core i9 13900H, 32GB of RAM, and an Nvidia RTX 4070 (which I usually keep off, opting for the Intel iGPU unless actively using for development). 
As a result, battery life and efficiency are pretty important to me.

As of yet, I have yet to come across any performance issues, stutters, lags, or frame drops, but it will likely vary from system to system. Upon booting into Hyprland with the current config,
RAM Usage is around 1.6-1.7 GB, which I am pretty happy with. With general use, moderate code compilation, etc, my computer stays relativley cool to the touch; the only time I ever hear my fans are when I'm plugged in, which is likely an asusctl setting I haven't delved into.

One of my concerns when initially choosing between QuickShell and Pleamar to base my desktop shell around was ram usage. I'm glad to say that when running, pleamar uses less than 40 MB of RAM. 
That being said, the scene that I was testing on was not exactly the most extensive or feature-rich (which is on design), so take that with a grain of salt.


## Credits and Attribution

##### JaKooLit:

This project is based on **JaKooLit/Hyprland-Dots**, which provided the foundation for my Hyprland configuration.

I have substantially modified the original configuration, including custom Lua configuration, keybindings, window rules, animations, scripts, and other personal customizations.

*Original project*: [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots)

*Original author*: JaKooLit

*License*: See the original project's license and the applicable license included in this repository.


##### Pleamar:

*Original repo*: [pleamar](https://github.com/k4ditano/pleamar)
*Original author*: k4ditano
*License*: See the original project's license and the applicable license included in this repository.


