function Test_sfObjectIdFromUrl{

    . $PSScriptRoot/../../private/auxiliarfunctions.ps1

    $urlList = @(
        "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/view",
        "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/",
        "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB",
        "https://github.my.salesforce.com/0010V00002Q8r78QAB"
    )

    $urlList | ForEach-Object {
        $result = Get-SfObjectIdFromUrl $_
        Assert-AreEqual -Expected "0010V00002Q8r78QAB" -Presented $result
    }

}

function Test_sfObjectTypeFromUrl{

    . $PSScriptRoot/../../private/auxiliarfunctions.ps1

    $urlList = @(
        "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/view",
        "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB/",
        "https://github.lightning.force.com/lightning/r/Account/0010V00002Q8r78QAB"
    )

    $urlList | ForEach-Object {
        $result = Get-SfObjectTypeFromUrl $_
        Assert-AreEqual -Expected "Account" -Presented $result
    }

    $urlList = @(
        "https://github.my.salesforce.com/0010V00002Q8r78QAB"
    )
    $urlList | ForEach-Object {
        $result = Get-SfObjectTypeFromUrl $_
        Assert-IsNull -Object $result
    }

}