This repository contains a collection of effect shaders I've created for Clickteam Fusion 2.5.
It also contains a Node JS program `CompileFX.js` that compiles the FX files
for effects to FXC.

The program assumes that you have a DirectX SDK installation and that the directory
containing its `fxc` utility is added to your `PATH` environment variable.

To run it, invoke the command:
`node CompileFX.js MyEffectName`

Do not include the extension for MyEffectName.
