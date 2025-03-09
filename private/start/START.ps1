# Gate to be loaded only onces
if (! $LOADED_EARLYLOADED){
    $LOADED_EARLYLOADED = $true

    # Add all modules that requies to be loadd before the code modules.
    # This is useful when you have a dependency to run


    function Get-ModuleName{
        $local = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
        $moduleName = (Get-ChildItem -Path $local -Filter *.psd1 | Select-Object -First 1).BaseName
        
        return $moduleName
    }

}
