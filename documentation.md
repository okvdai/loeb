# loeb - documentation
If you're reading this, you're probably thinking "well how exactly do I implement this in my own mod?" Fear not - it's very simple, and even simpler with these handy docs!

# fundamentals
## Adding a button to the lobby menu using loeb
To add a button to the lobby menu using loeb, you must first (preferably) create a `.nut` file that registers the button you want to create with the library.

`example.json`
```json
...
"Scripts" : [
    {
        "Path": "example-loeb-component.nut"
        "RunOn": "UI"
        "UICallback": {
            "After": "exampleRegisterWithLoeb"
        }
    }
]
```

`example-loeb-component.nut`
```squirrel
global function exampleRegisterWithLoeb

void function exampleRegisterWithLoeb()
{
    loebAdd(0, "Example", examplefunc())
}
```

This is the minimum amount of code required to create a button using loeb.
## Function overview

- `void function loebAdd( int headerIndexParam, string buttonNameParam, void functionref (var) funcParam )`

This function lets you add a button to the lobby menu.

`int headerIndexParam` defines under which header your button should pop up. As described in [this .nut file](https://github.com/okvdai/loeb/blob/main/mods/okudai.loeb/mod/scripts/vscripts/loeb_default_settings.nut), there are six of them: `PLAY` (0), `CUSTOMIZE` (1), `CALLSIGN` (2), `NETWORKS` (3), `STORE` (4) and `SETTINGS` (5).

`string buttonNameParam` is the text displayed on the button, for example: "Example".

`void functionref (var) funcParam` is the function executed on button press. Usually this is something along the lines of `AdvanceMenuEventHandler(GetMenu("example"))`.


- `void function loebSetLocked( string identifier, bool enabled )`

This function lets you set whether or not a button is locked.
`string identifier` is the same as the `string buttonNameParam` described above.

`bool enabled` is self explanatory: `true` is locked, `false` is unlocked.
