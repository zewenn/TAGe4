# Text Adventure Game (Engine) v4
This repo contains all the assets for my current Text Adventure Game project. These assets include real-time cross-platform input handling and rendering.

> [!IMPORTANT]
> This project is - very much - still a work in progress. It currently only supports **Windows** and **MacOS**, altought support for linux based is in the plans.

## The Engine
The Engine (TAG4) currently contains the following:

### Input System
The Engine usues system libraries to read input directly from the keyboard instead of `stdIn`. This means there is no cross platfrom support by default, we need to write the adapters by hand. 
> [!TIP]
> If the engine doesn't support your platform you can add a default `Inputter` like this:
> ```zig
// Get the Inputter Struct
const NCursesInputter = @import("./engine/input.zig").NCursesInputter;
const ASCIIKeyCodes = @import("./engine/input.zig").ASCIIKeyCodes;

const KeyCodes = e.Input.getKeyCodes(.{
    .override_correct = true, // Even with supported OS, still use the default.
    .use_default = true, // Enable Default instead of errors
    .default = ASCIIKeyCodes // Default KeyCodes
}) catch {
    std.debug.print("OS Not Supported", .{});
    return;
};
const Inputter = e.Input.getInputter(.{
    .override_correct = true, // Even with supported OS, still use the default.
    .use_default = true, // Enable Default instead of errors
    .default = NCursesInputter.get() // Default Inputter
}) catch {
    std.debug.print("OS Not Supported", .{});
    return;
};
```

### Renderer
The engine uses a Console Renderer (thus Text Adventure). This is still a work in progress and still needs a lot of features.

### Events
The event system makes it easy to bind scripts to calls, it's just like any other event system ever.