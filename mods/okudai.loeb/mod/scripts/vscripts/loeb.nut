struct DataStruct
{
    int headerIndex
    int buttonIndex
    string buttonName
    functionref(...) func
}

struct {
    array<DataStruct> buttonArray
    array<functionref(...)> modFunctions
} file


string prefix = "[LOEB]"


void function loebInit
{
    log("Initialized.")
    log("Loading default settings...")
    loebLoadDefault()

}

void function log (string content)
{
    printt(format("%s %s", prefix, content))
}

global void function loebAdd (int headerIndexParam, string buttonNameParam, functionref(...) funcParam)
{
    array<int> buttonIndexes
    foreach (DataStruct struct in file.buttonArray)
    {
        if (struct.headerIndex == headerIndexParam)
        {
            buttonIndexes.append(struct.buttonIndex)
        }
    }
    buttonIndexes.sort(SortHighest)
    DataStruct newButton
    {
        headerIndex = headerIndexParam
        buttonIndex = buttonIndexes.len() == 0 ? 0 + 1 : buttonIndexes[0] + 1
        buttonName = buttonNameParam
        func = funcParam
    }
    file.buttonArray.append(newButton)
}

global void function loebLogModFunc (functionref(...) funcParam)
{
    file.modFunctions.append(funcParam)
}

global int function loebParseHeaderIndex(int counter)
{
    return file.buttonArray[counter].headerIndex
}

global int function loebParseButtonIndex(int counter)
{
    return file.buttonArray[counter].buttonIndex
}

global string function loebParseButtonName(int counter)
{
    return file.buttonArray[counter].buttonName
}