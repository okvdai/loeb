# Documentation

## The basics

`example.json`
```json
...
"Scripts" : [
    {
        "Path": "example.nut",
        "RunOn": "UI",
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

This is the minimum required code needed to create a button using loeb. 

## Function overview

- `void function loebAdd ( int headerIndexParam, string buttonNameParam, void functionref(var) funcParam)`

This is the function that adds a button to your lobby menu.

`headerIndexParam` is what dictates under which header your button will be placed. This can be any `int` from 0 to 5, correlating to the headers in the lobby menu. As described in [this nut file](https://github.com/okvdai/loeb/blob/main/mods/okudai.loeb/mod/scripts/vscripts/loeb_default_settings.nut), there are six of them: `PLAY`, `CUSTOMIZE`, `CALLSIGN`, `NETWORKS`, `STORE` and `SETTINGS`.

`buttonNameParam` is what decides the text on the button. This can be any string.

`funcParam` is the function called upon clicking given button. This can be any function.

- `void function loebSetLockedButton ( string identifier, bool enabled )`

This function decides whether a button with the `identifier` identifier (this should be the `buttonNameParam` we set before) should be locked or not. A locked button will not call any function upon clicking it.

- `void function loebSetNewButton ( string identifier, bool enabled )`

This function works similarly to the one described above, only instead of the button becoming locked, a "NEW" tag will appear next to the button.