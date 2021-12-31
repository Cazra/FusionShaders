'use strict';

/**
 * This program transpiles fx files made in Clickteam Fusion 2.5's effects editor
 * to HLSL and then compiles those to fxc files.
 * This script assumes that you have a DirectX SDK installation and that the
 * directory containing the `fxc` utility is added to your `PATH` environment
 * variable.
 *
 * It takes 1 argument: The name of your effect file, without the extension.
 */

const fs = require('fs');
const cp = require('child_process');

// Get the name of the effect file from the command.
let effect = process.argv[2];
if (!effect)
  throw new Error('Expected 1 argument: name of effect file (without extension).');

// Read the fx file.
let fxContent = fs.readFileSync(`${effect}.fx`, {encoding: 'utf8'});

// Produce the hlsl file following the rules in the thread at
// https://community.clickteam.com/threads/105504-Converting-DX9-shaders-to-DX11
let hlslContent =
           // Replace COLOR0 and POSITION.
  fxContent.replace(/COLOR0/g, 'SV_TARGET')
           .replace(/Position\s*:\s*POSITION/g, 'Tint: COLOR0')

           // Replace sampler2D declarations.
           .replace(/sampler2D (\w+)(\s*:\s*register\(s(\d+)\))?;/g, (match, name, register, regIndex) => {
             regIndex = regIndex || 0;
             return `Texture2D<float4> ${name}: register(t${regIndex});\n` +
                    `sampler ${name}Sampler: register(s${regIndex});`
           })

           // Replace calls to tex2D. The calling function must take
           // an `In` parameter of type `PS_INPUT`.
           .replace(/tex2D\((\w+), ((\w|\.)+)\);/g, (match, name, coords) => {
             return `${name}\.Sample(${name}Sampler, ${coords}) * In.Tint;`;
           })

           // Convert parameters. They must be preceded by the line
           // `// PS_VARIABLES`
           // and they end after two line breaks.
           .replace(/\/\/ PS_VARIABLES((\s+.+;)+)/g, (match, params) => {
             return `cbuffer PS_VARIABLES : register(b0) {${params}\n}\n`;
           })

           // Remove the technique part. It's not needed.
           .replace(/\/\/ Effect technique(.|\s|\n)+/g, '')

           // ints will throw warnings, so use uints instead.
           .replace(/\bint\b/g, 'uint');
fs.writeFileSync(`${effect}.hlsl`, hlslContent);

// Compile the HLSL file with `fxc`.
let result = cp.spawnSync('fxc', ['/nologo', '/WX', '/Ges', '/Zi', '/Zpc', '/Qstrip_reflect', '/Qstrip_debug',
  '/Eps_main', '/Tps_4_0', `/Fo${effect}.fxc`, `${effect}.hlsl`]);

// Emit the output from the command to the console.
let stderr = result.stderr.toString('utf8').trim();
let stdout = result.stdout.toString('utf8').trim();
if (stderr)
  console.error(stderr);
if (stdout)
  console.log(stdout);
