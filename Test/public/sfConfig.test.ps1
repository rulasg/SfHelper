function Test_AddSfConfigAttribute{
    Reset-InvokeCommandMock
    Mock_Config

    # Emput config
    $result = Get-SfConfig
    Assert-IsNull -Object $result

    # Add acount
    Add-SfConfigAttribute -objectType "Account" -Attribute "acountattribute"
    $result = Get-SfConfig
    Assert-Count -Expected 1 -Presented $result.account_attributes
    Assert-Contains -Expected "acountattribute" -Presented $result.account_attributes
    Add-SfConfigAttribute -objectType "Account" -Attribute "acountattribute2"
    $result = Get-SfConfig
    Assert-Count -Expected 2 -Presented $result.account_attributes
    Assert-Contains -Expected "acountattribute" -Presented $result.account_attributes
    Assert-Contains -Expected "acountattribute2" -Presented $result.account_attributes

    # Add user
    Add-SfConfigAttribute -objectType "User" -Attribute "userattribute"
    $result = Get-SfConfig
    Assert-Count -Expected 1 -Presented $result.user_attributes
    Assert-Contains -Expected "userattribute" -Presented $result.user_attributes
    Add-SfConfigAttribute -objectType "User" -Attribute "userattribute2"
    $result = Get-SfConfig
    Assert-Count -Expected 2 -Presented $result.user_attributes
    Assert-Contains -Expected "userattribute" -Presented $result.user_attributes
    Assert-Contains -Expected "userattribute2" -Presented $result.user_attributes

    # Add Opportunity
    Add-SfConfigAttribute -objectType "Opportunity" -Attribute "opportunityattribute"
    $result = Get-SfConfig
    Assert-Count -Expected 1 -Presented $result.opportunity_attributes
    Assert-Contains -Expected "opportunityattribute" -Presented $result.opportunity_attributes
    Add-SfConfigAttribute -objectType "Opportunity" -Attribute "opportunityattribute2"
    $result = Get-SfConfig
    Assert-Count -Expected 2 -Presented $result.opportunity_attributes
    Assert-Contains -Expected "opportunityattribute" -Presented $result.opportunity_attributes
    Assert-Contains -Expected "opportunityattribute2" -Presented $result.opportunity_attributes

}

