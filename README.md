# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)


## /services/apexrest/webform/Register

Webservice to register inquiries from website, coming from the https://beta.capwell.nl/zoek-it-consultant -> Zoekprofiel doorgeven form
Apex Class: `webformRegistration`
`{
    "function" : "String",
    "description" : "String",
    "effort" : "5 dagen per week / 4 dagen per week / 3 dagen per week / 2 dagen per week / 1 dagen per week",
    "duration" : "korter dan 2 weken / 2 tot 4 weken / 1 tot 2 maanden / 3 tot 6 maanden / 6 tot 12 maanden / Meer dan 12 maanden",
    "startDate" : "String", //on website start date duplicate values from Effort field
    "location" : "String",  //filled to new lead City field which is compount Address field
    "question" : "String",
    
    "company" : "String", //required
    "firstName" : "String"
    "lastName" : "String", //required
    "title" : "String", 
    "phone" : "String",
    "email" : "String",
    "level" : "String",
    "experience" : "String",
    "requestType" : "String", //required - Zoekprofiel doorgeven / Uurtarief opvragen / Beschikbaarheid aanvragen / Freelance opdrachten / Vacatures / Freelance en Vacatures

    "requestContact" : "String", //required for Beschikbaarheid aanvragen - email to find Contact in Database
    "workLocation" : "String",
    "workDistance" : "String",

    "fileBase64" : "String", //Attached CV
    "fileExtension" : "String" , //File type 'doc' / 'pdf' etc... without '.'
    "jobLegacyID" : "String", //ref to job id from OPA
    "type" : "client / contact"   //system parameter to orchestrate inquiry flow - values:
                        // client - new request from potential client - from https://beta.capwell.nl/zoek-it-consultant -> Zoekprofiel doorgeven form and -> Uurtarief opvragen form and Beschikbaarheid aanvragen form
                        // contact - new request from potential freelance/candidate
                        // direct - new application to the posted job ad
}`

### example:
    `{
        "type" : "client",
        "firstName" : "John",
        "lastName" : "Smith",
        "company" : "Acme Corp.",
        "requestType" : "Zoekprofiel doorgeven",
        "email" : "roman.mikita@gmail.com"
    }`

### comments:
[ ] - i would add company name and KvK number to Freelance application form