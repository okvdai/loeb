# loeb
A Titanfall 2 lobby library, allowing modders to add buttons to the lobby screen without causing incompatibility with other mods.

This mod is currently in early development stage, beware of any bugs and make an issue if you find any.

# How to add buttons

`example.json`
```json
...
"Scripts" : [
    {
        "Path": "example.nut"
        "RunOn": "UI"
        "UICallback": {
            "After": "example"
        }
    }
]
```
`example.nut`
```squirrel
void function example()
{
    loebAdd(0, "Example", exampleFunc()) // loebAdd(headerIndex, identifier, functionOnClick)
    // headerIndex can be any number from 0 to 5, corresponding to the headers in the lobby menu: PLAY, CUSTOMIZE, CALLSIGN, NETWORKS, STORE, SETTINGS.
}
```

Other functions:
`loebSetLockedButton (identifier, true/false)`
`loebSetNewButton (identifier, true/false)`

**BETTER DOCUMENTATION SOON**

# Technical limitations
As described in the `combo-buttons.res` file (`resource/ui/menus/combo_buttons.res`), the game currently supports only four buttons under each header. Adding more than 4 buttons under a given header will cause the game to crash out.

This could potentially be increased, but that requires further analysis and development.
